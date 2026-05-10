#!/usr/bin/env python3
"""
Create or update F-Droid metadata on a GitLab fork of fdroiddata and open an MR to upstream.

Required env:
  GITLAB_TOKEN              — GitLab PAT with api scope (repo write on fork)
  GITLAB_FORK_PROJECT_ID    — numeric project ID of *your* fdroiddata fork

Optional:
  GITLAB_API_URL            — default https://gitlab.com/api/v4
  GITLAB_UPSTREAM_PATH      — default fdroid/fdroiddata (resolved to numeric ID)
  FDROID_METADATA_PATH      — default metadata/pro.kwiatek.tune_tangler.yml
  GITHUB_SHA                — commit the tag points to (CI sets automatically)
  GITHUB_REF_NAME           — tag name (CI sets automatically)
  FDROID_FLUTTER_VERSION    — Flutter SDK version string for the build recipe (e.g. 3.29.0)
  GITHUB_WORKSPACE          — repo root (CI sets automatically)
  VERSION_OVERRIDE          — optional; workflow_dispatch MAJOR.MINOR.PATCH[+CODE]

Repo paths (under GITHUB_WORKSPACE):
  tools/fdroid/metadata_static.yml  — fdroiddata bootstrap (no Summary/Description/Name; see F-Droid docs)
  tools/fdroid/build_template.yml   — one Build entry with __PLACEHOLDERS__
"""

from __future__ import annotations

import base64
import json
import os
import re
import urllib.error
import urllib.parse
import urllib.request
import uuid
from pathlib import Path
from typing import Any

import yaml


class _QuotedScalar:
    """YAML scalar serialized quoted (AutoUpdateMode must not become a YAML null)."""

    __slots__ = ("value",)

    def __init__(self, value: str) -> None:
        self.value = value


class FdroidMetadataDumper(yaml.SafeDumper):
    """Indent list items under mapping keys (fdroid lint / rewritemeta style)."""

    def increase_indent(self, flow: bool = False, indentless: bool = False):
        return super().increase_indent(flow, indentless=False)


def _represent_quoted_scalar(dumper: yaml.SafeDumper, data: _QuotedScalar):
    return dumper.represent_scalar("tag:yaml.org,2002:str", data.value, style="'")


FdroidMetadataDumper.add_representer(_QuotedScalar, _represent_quoted_scalar)


_BUILD_KEY_ORDER = (
    "versionName",
    "versionCode",
    "commit",
    "subdir",
    "sudo",
    "init",
    "output",
    "prebuild",
    "build",
)


def _canonical_build(build: dict[str, Any]) -> dict[str, Any]:
    ordered: dict[str, Any] = {}
    for key in _BUILD_KEY_ORDER:
        if key in build:
            ordered[key] = build[key]
    for key, val in build.items():
        if key not in ordered:
            ordered[key] = val
    return ordered


def _coerce_archive_policy(doc: dict[str, Any]) -> None:
    ap = doc.get("ArchivePolicy")
    if ap is None:
        return
    if isinstance(ap, int):
        doc["ArchivePolicy"] = ap
        return
    if isinstance(ap, str):
        s = ap.strip()
        m = re.match(r"^(\d+)\s+versions?$", s, re.IGNORECASE)
        if m:
            doc["ArchivePolicy"] = int(m.group(1))
            return
        if s.isdigit():
            doc["ArchivePolicy"] = int(s)
            return


def _fix_categories(doc: dict[str, Any]) -> None:
    cats = doc.get("Categories")
    if not isinstance(cats, list):
        return
    out: list[str] = []
    for c in cats:
        if c == "Music & Audio":
            out.append("Multimedia")
        else:
            out.append(str(c))
    doc["Categories"] = out


def _normalize_metadata(doc: dict[str, Any], version_name: str, version_code: int) -> None:
    """Match fdroiddata schemas/metadata.json and fdroid lint."""
    _fix_categories(doc)
    _coerce_archive_policy(doc)
    doc["AutoUpdateMode"] = _QuotedScalar("None")
    um = doc.get("UpdateCheckMode")
    if um is None:
        doc["UpdateCheckMode"] = _QuotedScalar("None")
    elif isinstance(um, str):
        doc["UpdateCheckMode"] = _QuotedScalar(um)
    else:
        doc["UpdateCheckMode"] = _QuotedScalar(str(um))
    doc["CurrentVersion"] = version_name
    doc["CurrentVersionCode"] = int(version_code)
    builds = doc.get("Builds")
    if isinstance(builds, list):
        for i, b in enumerate(builds):
            if isinstance(b, dict):
                builds[i] = _canonical_build(b)


def _env(name: str, default: str | None = None) -> str:
    v = os.environ.get(name, default)
    if v is None or v == "":
        raise SystemExit(f"Missing required environment variable: {name}")
    return v


def _gitlab_request(
    method: str,
    api_base: str,
    token: str,
    path: str,
    body: dict[str, Any] | None = None,
) -> tuple[int, Any]:
    url = f"{api_base.rstrip('/')}/{path.lstrip('/')}"
    data = None
    headers = {"PRIVATE-TOKEN": token}
    if body is not None:
        data = json.dumps(body).encode("utf-8")
        headers["Content-Type"] = "application/json"
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            raw = resp.read().decode("utf-8")
            code = resp.getcode()
            if not raw:
                return code, None
            return code, json.loads(raw)
    except urllib.error.HTTPError as e:
        raw = e.read().decode("utf-8", errors="replace")
        try:
            parsed = json.loads(raw) if raw else None
        except json.JSONDecodeError:
            parsed = raw
        raise SystemExit(f"GitLab HTTP {e.code} for {method} {url}: {parsed}") from e


def _project_id_for_path(api_base: str, token: str, project_path: str) -> int:
    enc = urllib.parse.quote(project_path, safe="")
    _, data = _gitlab_request("GET", api_base, token, f"projects/{enc}")
    assert isinstance(data, dict)
    return int(data["id"])


def _get_file(api_base: str, token: str, project_id: int, file_path: str, ref: str) -> str | None:
    enc = urllib.parse.quote(file_path, safe="")
    url = f"{api_base}/projects/{project_id}/repository/files/{enc}?ref={urllib.parse.quote(ref)}"
    req = urllib.request.Request(url, headers={"PRIVATE-TOKEN": token})
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            data = json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return None
        raw = e.read().decode("utf-8", errors="replace")
        raise SystemExit(f"GitLab HTTP {e.code} GET {url}: {raw}") from e
    assert isinstance(data, dict)
    return base64.b64decode(data["content"]).decode("utf-8")


def _read_pubspec_version(root: Path) -> str:
    pub = root / "pubspec.yaml"
    for line in pub.read_text(encoding="utf-8").splitlines():
        if line.strip().startswith("version:"):
            return line.split(":", 1)[1].strip().strip('"').strip("'")
    raise SystemExit("Could not find version: in pubspec.yaml")


def _parse_version(spec: str) -> tuple[str, int]:
    """Return (versionName, versionCode)."""
    m = re.match(r"^(\d+)\.(\d+)\.(\d+)(?:\+(\d+))?$", spec.strip())
    if not m:
        raise SystemExit(
            f"Unsupported version string: {spec!r} "
            "(expected MAJOR.MINOR.PATCH or MAJOR.MINOR.PATCH+CODE)"
        )
    major, minor, patch, build = m.group(1), m.group(2), m.group(3), m.group(4)
    name = f"{major}.{minor}.{patch}"
    if build is not None:
        return name, int(build)
    code = int(major) * 1_000_000 + int(minor) * 1_000 + int(patch)
    return name, code


def _substitute_build_template(
    template_text: str,
    *,
    version_name: str,
    version_code: int,
    commit_sha: str,
    flutter_ver: str,
) -> dict[str, Any]:
    text = template_text
    text = text.replace("__VERSION_NAME__", version_name)
    text = text.replace("__VERSION_CODE__", str(version_code))
    text = text.replace("__COMMIT_SHA__", commit_sha)
    text = text.replace("__FLUTTER_VERSION__", flutter_ver)
    loaded = yaml.safe_load(text)
    if not isinstance(loaded, dict):
        raise SystemExit("build_template.yml must be a single YAML mapping")
    loaded["versionName"] = version_name
    loaded["versionCode"] = int(version_code)
    loaded["commit"] = commit_sha
    return loaded


def _dump_metadata(doc: dict[str, Any]) -> str:
    return yaml.dump(
        doc,
        Dumper=FdroidMetadataDumper,
        allow_unicode=True,
        default_flow_style=False,
        sort_keys=False,
        width=120,
    )


# If present in fdroiddata metadata YAML, these override Fastlane/Triple-T files in the app
# repo (see https://f-droid.org/en/docs/All_About_Descriptions_Graphics_and_Screenshots/ ).
_FDROID_YAML_LISTING_KEYS = ("Name", "AutoName", "Summary", "Description")


def _strip_listing_fields_for_fastlane(doc: dict[str, Any]) -> None:
    for k in _FDROID_YAML_LISTING_KEYS:
        doc.pop(k, None)


def _assert_fastlane_en_us(root: Path) -> None:
    base = root / "fastlane" / "metadata" / "android" / "en-US"
    required = ("short_description.txt", "full_description.txt")
    missing = [p for p in required if not (base / p).is_file()]
    if missing:
        rel = ", ".join(str(base / m) for m in missing)
        raise SystemExit(
            "F-Droid reads store text from Fastlane/Triple-T in the app repo at the release "
            f"revision. Missing required files: {rel}"
        )


def main() -> None:
    root = Path(os.environ.get("GITHUB_WORKSPACE", os.getcwd())).resolve()
    api_base = os.environ.get("GITLAB_API_URL", "https://gitlab.com/api/v4").rstrip("/")
    token = _env("GITLAB_TOKEN")
    fork_id = int(_env("GITLAB_FORK_PROJECT_ID"))
    upstream_path = os.environ.get("GITLAB_UPSTREAM_PATH", "fdroid/fdroiddata")
    metadata_path = os.environ.get("FDROID_METADATA_PATH", "metadata/pro.kwiatek.tune_tangler.yml")
    commit_sha = _env("GITHUB_SHA")
    ref_name = os.environ.get("GITHUB_REF_NAME", "")
    flutter_ver = os.environ.get("FDROID_FLUTTER_VERSION", "").strip()
    if not flutter_ver:
        raise SystemExit(
            "FDROID_FLUTTER_VERSION must be set (e.g. 3.29.0 matching the Flutter stable archive name)."
        )

    version_override = os.environ.get("VERSION_OVERRIDE", "").strip()

    pub_ver = _read_pubspec_version(root)
    if version_override:
        vname, vcode = _parse_version(version_override)
    elif ref_name and re.match(r"^v?\d+\.\d+\.\d+(\+\d+)?$", ref_name):
        vname, vcode = _parse_version(ref_name.lstrip("v"))
    else:
        vname, vcode = _parse_version(pub_ver)

    if not re.match(r"^[0-9a-f]{40}$", commit_sha.lower()):
        raise SystemExit(f"GITHUB_SHA must be a full 40-char commit hash, got {commit_sha!r}")

    _assert_fastlane_en_us(root)

    tpl_path = root / "tools" / "fdroid" / "build_template.yml"
    static_path = root / "tools" / "fdroid" / "metadata_static.yml"
    build_template_text = tpl_path.read_text(encoding="utf-8")
    new_build = _substitute_build_template(
        build_template_text,
        version_name=vname,
        version_code=vcode,
        commit_sha=commit_sha,
        flutter_ver=flutter_ver,
    )

    existing_yaml = _get_file(api_base, token, fork_id, metadata_path, ref="master")
    if existing_yaml is None:
        static_doc = yaml.safe_load(static_path.read_text(encoding="utf-8"))
        if not isinstance(static_doc, dict):
            raise SystemExit("metadata_static.yml must be a mapping")
        doc = static_doc
        doc["Builds"] = [new_build]
    else:
        doc = yaml.safe_load(existing_yaml)
        if not isinstance(doc, dict):
            raise SystemExit("Remote metadata must be a YAML mapping")
        builds = doc.get("Builds")
        if not isinstance(builds, list):
            raise SystemExit("Remote metadata has no Builds list")
        codes = {int(b["versionCode"]) for b in builds if isinstance(b, dict) and "versionCode" in b}
        if vcode in codes:
            print(f"Build with versionCode={vcode} already exists on master; nothing to do.", flush=True)
            return
        builds.append(new_build)
        doc["Builds"] = builds

    _strip_listing_fields_for_fastlane(doc)
    _normalize_metadata(doc, vname, vcode)

    body_yaml = _dump_metadata(doc)
    safe_tag = re.sub(r"[^0-9A-Za-z._-]+", "-", f"{vname}-{commit_sha[:8]}")
    branch = f"robot/tune-tangler-{safe_tag}-{uuid.uuid4().hex[:8]}"

    upstream_id = _project_id_for_path(api_base, token, upstream_path)

    commit_payload = {
        "branch": branch,
        "commit_message": f"Tune Tangler: {vname} ({vcode}) @ {commit_sha[:8]}",
        "start_branch": "master",
        "actions": [
            {
                "action": "update" if existing_yaml is not None else "create",
                "file_path": metadata_path,
                "content": body_yaml,
            }
        ],
    }

    _gitlab_request("POST", api_base, token, f"projects/{fork_id}/repository/commits", commit_payload)
    print(f"Created branch {branch} with metadata update.", flush=True)

    mr_payload = {
        "source_branch": branch,
        "target_branch": "master",
        "target_project_id": upstream_id,
        "title": f"Tune Tangler {vname} ({vcode})",
        "description": (
            "Automated metadata bump from tag/ref.\n\n"
            f"- **versionName:** {vname}\n"
            f"- **versionCode:** {vcode}\n"
            f"- **commit:** `{commit_sha}`\n"
            f"- **Flutter (recipe):** {flutter_ver}\n\n"
            "Store text and screenshots come from **Fastlane/Triple-T** in the app repo "
            "(`fastlane/metadata/android/` at the tagged revision). "
            "`Name` / `Summary` / `Description` were removed from the YAML if present so "
            "F-Droid does not override that source.\n"
        ),
        "remove_source_branch": True,
    }
    _, mr = _gitlab_request("POST", api_base, token, f"projects/{fork_id}/merge_requests", mr_payload)
    assert isinstance(mr, dict)
    print(f"Opened MR: {mr.get('web_url')}", flush=True)


if __name__ == "__main__":
    main()

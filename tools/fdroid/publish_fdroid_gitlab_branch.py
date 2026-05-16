#!/usr/bin/env python3
"""
Push F-Droid metadata YAML to a **single named branch** on your GitLab fork of fdroiddata (no version in the branch name).
This script only updates the fork branch; opening a merge request to upstream fdroiddata is a separate manual step in GitLab.

Repo layout and app identity are driven by environment variables (nothing app-specific is required inside this file).

Required env:
  GITLAB_TOKEN                 — GitLab PAT with api scope (repo write on fork)
  GITLAB_FORK_PROJECT_ID       — numeric project ID of *your* fdroiddata fork
  FDROID_METADATA_PATH         — path under fork repo (e.g. metadata/<applicationId>.yml)
  FDROID_GITLAB_BRANCH         — branch name on the fork to push commits to
  FDROID_GIT_COMMIT_SUBJECT_PREFIX — first segment of Git commit subject (before ": version …")
  FDROID_MAINTAINER_NOTES_PATH — repo-relative path to MaintainerNotes body (rewritemeta-style text file)
  FDROID_GITLAB_FORK_PARENT_REF — fork branch to branch from / read baseline metadata (usually master)

Optional:
  GITLAB_API_URL               — default https://gitlab.com/api/v4
  GITHUB_SHA                   — full 40-char app commit for Builds[].commit
  GITHUB_REF_NAME              — tag or branch (for version inference)
  GITHUB_WORKSPACE             — repo root (CI sets automatically)

Flutter SDK version for srclibs is read from `.metadata` at the release commit (version.revision → release tag).
  VERSION_OVERRIDE             — optional MAJOR.MINOR.PATCH[+CODE]
  FDROID_GITLAB_COMPARE_BASE_REF — left-hand side of GitLab compare URL (default: same as FDROID_GITLAB_FORK_PARENT_REF)
  FDROID_FASTLANE_METADATA_REL_PATH — default fastlane/metadata/android/en-US
  FDROID_UPSTREAM_MR_WEB_URL   — default https://gitlab.com/fdroid/fdroiddata (step summary MR hint)
  FDROID_TOOLING_REL_PATH      — default tools/fdroid (build_template.yml, metadata_static.yml)

Under GITHUB_WORKSPACE, templates live under FDROID_TOOLING_REL_PATH:
  metadata_static.yml  — fdroiddata bootstrap when fork file is missing
  build_template.yml   — one Build entry with __PLACEHOLDERS__
"""

from __future__ import annotations

import base64
import json
import os
import re
import urllib.error
import urllib.parse
import urllib.request
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


class _MaintainerNotesLiteral(str):
    """Serialize as YAML literal block (|) like `fdroid rewritemeta`."""


def _represent_maintainer_notes_literal(dumper: yaml.SafeDumper, data: _MaintainerNotesLiteral):
    return dumper.represent_scalar("tag:yaml.org,2002:str", str(data), style="|")


FdroidMetadataDumper.add_representer(_MaintainerNotesLiteral, _represent_maintainer_notes_literal)


def _repo_relative_path(root: Path, rel: str) -> Path:
    root_r = root.resolve()
    p = (root_r / rel).resolve()
    try:
        p.relative_to(root_r)
    except ValueError as e:
        raise SystemExit(f"Resolved path escapes repo root: {rel!r}") from e
    return p


_BUILD_KEY_ORDER = (
    "versionName",
    "versionCode",
    "commit",
    "subdir",
    "submodules",
    "output",
    "srclibs",
    "rm",
    "sudo",
    "init",
    "prebuild",
    "scanignore",
    "scandelete",
    "build",
)


def _normalize_subdir_value(sd: Any) -> str | None:
    """schemas/metadata.json #/definitions/path: NOT (const '.' OR pattern '^\\./'). Omit key for repo root."""
    if sd is None:
        return None
    if not isinstance(sd, str):
        return None
    s = sd.strip()
    if s in (".", "", "./"):
        return None
    if s.startswith("./"):
        inner = s[2:].lstrip("/")
        return inner or None
    return s.lstrip("/") or None


def _canonical_build(build: dict[str, Any]) -> dict[str, Any]:
    ordered: dict[str, Any] = {}
    for key in _BUILD_KEY_ORDER:
        if key in build:
            ordered[key] = build[key]
    for key, val in build.items():
        if key not in ordered:
            ordered[key] = val
    sub = _normalize_subdir_value(ordered.get("subdir"))
    if sub is None:
        ordered.pop("subdir", None)
    else:
        ordered["subdir"] = sub
    # Debian Trixie fdroid buildserver: no openjdk-17-jdk-headless; use 21.
    sudo = ordered.get("sudo")
    if isinstance(sudo, list):
        ordered["sudo"] = [
            line.replace("openjdk-17-jdk-headless", "openjdk-21-jdk-headless")
            if isinstance(line, str)
            else line
            for line in sudo
        ]
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


def _normalize_maintainer_notes(doc: dict[str, Any], body: str) -> None:
    """rewritemeta emits MaintainerNotes as a literal block (|), not folded single quotes."""
    doc["MaintainerNotes"] = _MaintainerNotesLiteral(body)


def _normalize_update_check_mode(doc: dict[str, Any]) -> None:
    """Store modes as strings; _postprocess_rewritemeta_yaml emits plain `None` like rewritemeta."""
    um = doc.get("UpdateCheckMode")
    if um is None or (isinstance(um, str) and um.strip() == "None"):
        doc["UpdateCheckMode"] = "None"
    elif isinstance(um, str):
        doc["UpdateCheckMode"] = _QuotedScalar(um)
    else:
        doc["UpdateCheckMode"] = _QuotedScalar(str(um))


def _canonical_github_repo_url(repo: str) -> str:
    """fdroiddata CI `git redirect` (e.g. on merge requests) uses `git ls-remote` with http.followRedirects=false.

    GitHub smart-HTTP without the `.git` suffix can fail or redirect from GitLab CI; upstream
    `tools/rewrite-git-redirects.py` rewrites to the `.git` URL — metadata must already match.
    """
    s = repo.strip().rstrip("/")
    if s.endswith(".git") or "github.com/" not in s:
        return repo.strip()
    if re.match(r"^https://github\.com/[^/]+/[^/]+/?$", s):
        return s + ".git"
    return repo.strip()


def _normalize_metadata(
    doc: dict[str, Any], version_name: str, version_code: int, maintainer_notes_body: str
) -> None:
    """Match fdroiddata schemas/metadata.json, fdroid lint, and `fdroid rewritemeta` output."""
    _fix_categories(doc)
    _coerce_archive_policy(doc)
    doc["AutoUpdateMode"] = "None"
    _normalize_update_check_mode(doc)
    _normalize_maintainer_notes(doc, maintainer_notes_body)
    r = doc.get("Repo")
    if isinstance(r, str) and r.strip():
        doc["Repo"] = _canonical_github_repo_url(r)
    doc["CurrentVersion"] = version_name
    doc["CurrentVersionCode"] = int(version_code)
    builds = doc.get("Builds")
    if isinstance(builds, list):
        for i, b in enumerate(builds):
            if isinstance(b, dict):
                builds[i] = _canonical_build(b)


def _insert_rewritemeta_blank_lines(lines: list[str]) -> list[str]:
    """Blank line after IssueTracker before RepoType; after Repo before Builds (rewritemeta style)."""
    out: list[str] = []
    for i, line in enumerate(lines):
        prev_non_empty = ""
        j = i - 1
        while j >= 0:
            if lines[j].strip():
                prev_non_empty = lines[j]
                break
            j -= 1
        if line.startswith("RepoType:") and prev_non_empty.startswith("IssueTracker:"):
            if out and out[-1].strip():
                out.append("")
        if line.startswith("Builds:") and prev_non_empty.startswith("Repo:"):
            if out and out[-1].strip():
                out.append("")
        out.append(line)
    return out


def _postprocess_rewritemeta_yaml(text: str) -> str:
    """PyYAML differs from `fdroid rewritemeta` on None quoting and section spacing."""
    lines = text.splitlines()
    body = "\n".join(_insert_rewritemeta_blank_lines(lines)) + "\n"
    body = re.sub(r"(?m)^AutoUpdateMode: ['\"]None['\"]\s*$", "AutoUpdateMode: None", body)
    body = re.sub(r"(?m)^UpdateCheckMode: ['\"]None['\"]\s*$", "UpdateCheckMode: None", body)
    # Blank line after last build: command before MaintainerNotes (rewritemeta style).
    body = re.sub(
        r"^(      - flutter build apk --release)\n(MaintainerNotes:)",
        r"\1\n\n\2",
        body,
        flags=re.MULTILINE,
    )
    # PyYAML uses |+ for trailing newlines in literal blocks; fdroid rewritemeta uses |.
    body = body.replace("MaintainerNotes: |+\n", "MaintainerNotes: |\n")
    return body


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


def _repository_commit_with_retry(
    api_base: str, token: str, fork_id: int, commit_payload: dict[str, Any]
) -> None:
    """POST repository/commits; flip create↔update once on common GitLab 400 errors."""
    path = f"projects/{fork_id}/repository/commits"
    action = commit_payload["actions"][0]["action"]
    try:
        _gitlab_request("POST", api_base, token, path, commit_payload)
        return
    except SystemExit as e:
        msg = str(e).lower()
        if "http 400" not in msg:
            raise
        if action == "create" and "already exists" in msg:
            commit_payload["actions"][0]["action"] = "update"
            _gitlab_request("POST", api_base, token, path, commit_payload)
            return
        if action == "update" and (
            "doesn't exist" in msg
            or "does not exist" in msg
            or "couldn't find" in msg
            or "not found" in msg
        ):
            commit_payload["actions"][0]["action"] = "create"
            _gitlab_request("POST", api_base, token, path, commit_payload)
            return
        raise


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


def _branch_exists(api_base: str, token: str, project_id: int, branch: str) -> bool:
    enc = urllib.parse.quote(branch, safe="")
    url = f"{api_base}/projects/{project_id}/repository/branches/{enc}"
    req = urllib.request.Request(url, headers={"PRIVATE-TOKEN": token})
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            return resp.status == 200
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return False
        raw = e.read().decode("utf-8", errors="replace")
        raise SystemExit(f"GitLab HTTP {e.code} GET {url}: {raw}") from e


def _fork_project_tree_url(api_base: str, token: str, fork_id: int, branch: str) -> str:
    _, data = _gitlab_request("GET", api_base, token, f"projects/{fork_id}")
    assert isinstance(data, dict)
    web = str(data.get("web_url", "")).rstrip("/")
    if not web:
        pwn = str(data["path_with_namespace"])
        web = f"https://gitlab.com/{pwn}"
    enc_br = urllib.parse.quote(branch, safe="")
    return f"{web}/-/tree/{enc_br}"


def _fork_compare_url(tree_url: str, branch: str, fork_id: int, base_ref: str) -> str:
    """GitLab UI: compare a base ref on fdroiddata to the fork automation branch."""
    if "/-/tree/" not in tree_url:
        raise SystemExit(f"Unexpected tree URL (no /-/tree/): {tree_url!r}")
    web_base = tree_url.split("/-/tree/", 1)[0]
    enc_br = urllib.parse.quote(branch, safe="")
    enc_base = urllib.parse.quote(base_ref, safe="")
    return f"{web_base}/-/compare/{enc_base}...{enc_br}?from_project_id={fork_id}"


def _write_github_output(name: str, value: str) -> None:
    outp = os.environ.get("GITHUB_OUTPUT")
    if not outp:
        return
    with open(outp, "a", encoding="utf-8") as fo:
        fo.write(f"{name}={value}\n")


def _yaml_mapping_equal(a: str, b: str) -> bool:
    try:
        ya = yaml.safe_load(a)
        yb = yaml.safe_load(b)
    except yaml.YAMLError as e:
        raise SystemExit(f"Invalid YAML while comparing metadata: {e}") from e
    return isinstance(ya, dict) and isinstance(yb, dict) and ya == yb


def _dedupe_builds_keep_last(builds: list[Any]) -> list[Any]:
    """One dict per versionCode; later entries in the list win."""
    order: list[int] = []
    by_vc: dict[int, dict[str, Any]] = {}
    for b in builds:
        if not isinstance(b, dict) or "versionCode" not in b:
            continue
        vc = int(b["versionCode"])
        if vc not in by_vc:
            order.append(vc)
        by_vc[vc] = b
    return [by_vc[vc] for vc in order]


_FLUTTER_RELEASES_URL_DEFAULT = (
    "https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json"
)


def _read_pubspec_version(root: Path) -> str:
    pub = root / "pubspec.yaml"
    for line in pub.read_text(encoding="utf-8").splitlines():
        if line.strip().startswith("version:"):
            return line.split(":", 1)[1].strip().strip('"').strip("'")
    raise SystemExit("Could not find version: in pubspec.yaml")


def _read_flutter_metadata_revision(root: Path) -> tuple[str, str]:
    """Return (git revision, channel) from Flutter's `.metadata` at the release tree."""
    meta_path = root / ".metadata"
    if not meta_path.is_file():
        raise SystemExit(
            "Missing .metadata at repo root. Run `flutter pub get` (or upgrade) with the target "
            "Flutter SDK, then commit .metadata before publishing F-Droid metadata."
        )
    try:
        doc = yaml.safe_load(meta_path.read_text(encoding="utf-8"))
    except yaml.YAMLError as e:
        raise SystemExit(f"Invalid .metadata: {e}") from e
    if not isinstance(doc, dict):
        raise SystemExit(".metadata must be a YAML mapping")
    version = doc.get("version")
    if not isinstance(version, dict):
        raise SystemExit(".metadata is missing version.revision (run flutter pub get and commit .metadata)")
    revision = version.get("revision")
    if not isinstance(revision, str) or not re.match(r"^[0-9a-f]{40}$", revision.lower()):
        raise SystemExit(f".metadata version.revision must be a 40-char git hash, got {revision!r}")
    channel = version.get("channel", "stable")
    if not isinstance(channel, str) or not channel.strip():
        channel = "stable"
    return revision.lower(), channel.strip()


def _fetch_flutter_releases_index(url: str) -> list[dict[str, Any]]:
    req = urllib.request.Request(url, headers={"User-Agent": "tune-tangler-fdroid-publish/1"})
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            data = json.loads(resp.read().decode("utf-8"))
    except (urllib.error.URLError, json.JSONDecodeError) as e:
        raise SystemExit(f"Could not fetch Flutter releases index from {url!r}: {e}") from e
    releases = data.get("releases") if isinstance(data, dict) else None
    if not isinstance(releases, list):
        raise SystemExit(f"Unexpected Flutter releases JSON at {url!r} (no releases list)")
    out: list[dict[str, Any]] = [r for r in releases if isinstance(r, dict)]
    return out


def _flutter_version_for_revision(revision: str, channel: str, releases: list[dict[str, Any]]) -> str:
    """Map `.metadata` revision to an F-Droid srclib version tag (e.g. 3.27.2)."""
    rev = revision.lower()
    by_hash = [r for r in releases if str(r.get("hash", "")).lower() == rev]
    if not by_hash:
        raise SystemExit(
            f"Flutter revision {revision} from .metadata was not found in the releases index. "
            "Upgrade Flutter, run `flutter pub get`, commit .metadata, and retry."
        )
    for r in by_hash:
        if r.get("channel") == channel and r.get("version"):
            return str(r["version"])
    for r in by_hash:
        if r.get("version"):
            return str(r["version"])
    raise SystemExit(f"No Flutter release version for revision {revision} in the releases index.")


def _resolve_flutter_version(root: Path) -> str:
    revision, channel = _read_flutter_metadata_revision(root)
    releases = _fetch_flutter_releases_index(_FLUTTER_RELEASES_URL_DEFAULT)
    version = _flutter_version_for_revision(revision, channel, releases)
    print(
        f"Flutter srclib version {version} (revision {revision[:12]}…, channel {channel}) from .metadata",
        flush=True,
    )
    return version


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
    raw = yaml.dump(
        doc,
        Dumper=FdroidMetadataDumper,
        allow_unicode=True,
        default_flow_style=False,
        sort_keys=False,
        width=120,
    )
    return _postprocess_rewritemeta_yaml(raw)


# If present in fdroiddata metadata YAML, these override Fastlane/Triple-T files in the app
# repo (see https://f-droid.org/en/docs/All_About_Descriptions_Graphics_and_Screenshots/ ).
_FDROID_YAML_LISTING_KEYS = ("Name", "AutoName", "Summary", "Description")


def _strip_listing_fields_for_fastlane(doc: dict[str, Any]) -> None:
    for k in _FDROID_YAML_LISTING_KEYS:
        doc.pop(k, None)


def _assert_fastlane_en_us(root: Path, rel_dir: str) -> None:
    base = _repo_relative_path(root, rel_dir)
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
    metadata_path = _env("FDROID_METADATA_PATH").strip()
    fork_parent_ref = _env("FDROID_GITLAB_FORK_PARENT_REF").strip()
    branch = _env("FDROID_GITLAB_BRANCH").strip()
    commit_subject_prefix = _env("FDROID_GIT_COMMIT_SUBJECT_PREFIX").strip()
    maintainer_notes_rel = _env("FDROID_MAINTAINER_NOTES_PATH").strip()
    for label, val in (
        ("FDROID_METADATA_PATH", metadata_path),
        ("FDROID_GITLAB_FORK_PARENT_REF", fork_parent_ref),
        ("FDROID_GITLAB_BRANCH", branch),
        ("FDROID_GIT_COMMIT_SUBJECT_PREFIX", commit_subject_prefix),
        ("FDROID_MAINTAINER_NOTES_PATH", maintainer_notes_rel),
    ):
        if not val:
            raise SystemExit(f"{label} must be non-empty")

    tooling_rel = (os.environ.get("FDROID_TOOLING_REL_PATH") or "tools/fdroid").strip() or "tools/fdroid"
    fastlane_rel = (os.environ.get("FDROID_FASTLANE_METADATA_REL_PATH") or "").strip() or (
        "fastlane/metadata/android/en-US"
    )
    upstream_mr_web = (os.environ.get("FDROID_UPSTREAM_MR_WEB_URL") or "").strip() or (
        "https://gitlab.com/fdroid/fdroiddata"
    )

    maintainer_body = _repo_relative_path(root, maintainer_notes_rel).read_text(encoding="utf-8")

    commit_sha = _env("GITHUB_SHA")
    ref_name = os.environ.get("GITHUB_REF_NAME", "")
    flutter_ver = _resolve_flutter_version(root)

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

    _assert_fastlane_en_us(root, fastlane_rel)

    tooling = _repo_relative_path(root, tooling_rel)
    tpl_path = tooling / "build_template.yml"
    static_path = tooling / "metadata_static.yml"
    build_template_text = tpl_path.read_text(encoding="utf-8")
    new_build = _substitute_build_template(
        build_template_text,
        version_name=vname,
        version_code=vcode,
        commit_sha=commit_sha,
        flutter_ver=flutter_ver,
    )

    existing_yaml = _get_file(api_base, token, fork_id, metadata_path, ref=fork_parent_ref)
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
        skip_new_build_merge = False
        for b in builds:
            if isinstance(b, dict) and int(b.get("versionCode", -1)) == vcode:
                if str(b.get("commit", "")).lower() == commit_sha.lower():
                    skip_new_build_merge = True
                break

        if not skip_new_build_merge:
            builds = [
                b
                for b in builds
                if not (isinstance(b, dict) and int(b.get("versionCode", -1)) == vcode)
            ]
            builds.append(new_build)
            doc["Builds"] = builds

    if isinstance(doc.get("Builds"), list):
        doc["Builds"] = _dedupe_builds_keep_last(doc["Builds"])

    _strip_listing_fields_for_fastlane(doc)
    _normalize_metadata(doc, vname, vcode, maintainer_body)

    body_yaml = _dump_metadata(doc)

    print(f"Target fork branch: {branch}", flush=True)

    skip_commit = False
    if _branch_exists(api_base, token, fork_id, branch):
        cur = _get_file(api_base, token, fork_id, metadata_path, ref=branch)
        if cur is not None and _yaml_mapping_equal(cur, body_yaml):
            skip_commit = True
            print("Fork branch already has identical metadata YAML; skipping new commit.", flush=True)

    if not skip_commit:
        if _branch_exists(api_base, token, fork_id, branch):
            file_on_commit_branch = _get_file(api_base, token, fork_id, metadata_path, ref=branch)
        else:
            file_on_commit_branch = existing_yaml
        commit_action = "update" if file_on_commit_branch is not None else "create"

        commit_payload: dict[str, Any] = {
            "branch": branch,
            "commit_message": f"{commit_subject_prefix}: {vname} ({vcode}) @ {commit_sha[:8]}",
            "actions": [
                {
                    "action": commit_action,
                    "file_path": metadata_path,
                    "content": body_yaml,
                }
            ],
        }
        if not _branch_exists(api_base, token, fork_id, branch):
            commit_payload["start_branch"] = fork_parent_ref

        _repository_commit_with_retry(api_base, token, fork_id, commit_payload)
        print(f"Pushed metadata commit to branch {branch}.", flush=True)

    tree_url = _fork_project_tree_url(api_base, token, fork_id, branch)
    compare_raw = (os.environ.get("FDROID_GITLAB_COMPARE_BASE_REF") or "").strip()
    compare_base = compare_raw or fork_parent_ref
    compare_url = _fork_compare_url(tree_url, branch, fork_id, compare_base)
    print(f"::notice::GitLab fork branch (pipelines): {tree_url}", flush=True)
    print(f"::notice::GitLab compare vs {compare_base}: {compare_url}", flush=True)
    _write_github_output("gitlab_tree_url", tree_url)
    _write_github_output("gitlab_branch", branch)
    _write_github_output("gitlab_compare_url", compare_url)

    summary = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary:
        with open(summary, "a", encoding="utf-8") as sf:
            sf.write("\n## fdroiddata fork branch\n\n")
            sf.write(f"- **branch:** `{branch}`\n")
            sf.write(f"- **tree (watch CI):** [{tree_url}]({tree_url})\n")
            sf.write(f"- **compare vs `{compare_base}`:** [{compare_url}]({compare_url})\n")
            sf.write(
                f"\nCreate a merge request to [`fdroid/fdroiddata`]({upstream_mr_web}) "
                "from this branch in GitLab when you are ready.\n"
            )


if __name__ == "__main__":
    main()

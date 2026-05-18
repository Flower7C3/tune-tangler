#!/usr/bin/env python3
"""
Serialize F-Droid app metadata YAML the same way as fdroidserver ``write_yaml`` /
``fdroid rewritemeta`` (ruamel.yaml round-trip, section blank lines, literal blocks).

Logic mirrors fdroidserver/metadata.py (AGPL-3.0+); keep in sync when CI formatting breaks.
See https://f-droid.org/en/docs/Build_Metadata_Reference/ and fdroiddata ``schemas/metadata.json``.
"""

from __future__ import annotations

from io import StringIO
from typing import Any

import ruamel.yaml
from ruamel.yaml.comments import CommentedMap, CommentedSeq

# fdroidserver/metadata.py — field order; ``\\n`` entries become a blank line before the next key.
YAML_APP_FIELD_ORDER: tuple[str, ...] = (
    "Disabled",
    "AntiFeatures",
    "Categories",
    "License",
    "AuthorName",
    "AuthorEmail",
    "AuthorWebSite",
    "WebSite",
    "SourceCode",
    "IssueTracker",
    "Translation",
    "Changelog",
    "Donate",
    "Liberapay",
    "OpenCollective",
    "Bitcoin",
    "Litecoin",
    "\n",
    "Name",
    "AutoName",
    "Summary",
    "Description",
    "\n",
    "RequiresRoot",
    "\n",
    "RepoType",
    "Repo",
    "Binaries",
    "\n",
    "Builds",
    "\n",
    "AllowedAPKSigningKeys",
    "\n",
    "MaintainerNotes",
    "\n",
    "ArchivePolicy",
    "AutoUpdateMode",
    "UpdateCheckMode",
    "UpdateCheckIgnore",
    "VercodeOperation",
    "UpdateCheckName",
    "UpdateCheckData",
    "CurrentVersion",
    "CurrentVersionCode",
    "\n",
    "NoSourceSince",
)

BUILD_FLAGS: tuple[str, ...] = (
    "versionName",
    "versionCode",
    "disable",
    "commit",
    "timeout",
    "subdir",
    "submodules",
    "sudo",
    "init",
    "patch",
    "gradle",
    "maven",
    "output",
    "binary",
    "srclibs",
    "oldsdkloc",
    "encoding",
    "forceversion",
    "forcevercode",
    "rm",
    "extlibs",
    "prebuild",
    "androidupdate",
    "target",
    "scanignore",
    "scandelete",
    "build",
    "buildjni",
    "ndk",
    "preassemble",
    "gradleprops",
    "antcommands",
    "postbuild",
    "novcheck",
    "antifeatures",
)

TYPE_STRING = 2
TYPE_BOOL = 3
TYPE_LIST = 4
TYPE_SCRIPT = 5
TYPE_MULTILINE = 6
TYPE_BUILD = 7
TYPE_INT = 8
TYPE_STRINGMAP = 9

FIELD_TYPES: dict[str, int] = {
    "Description": TYPE_MULTILINE,
    "MaintainerNotes": TYPE_MULTILINE,
    "Categories": TYPE_LIST,
    "AntiFeatures": TYPE_STRINGMAP,
    "RequiresRoot": TYPE_BOOL,
    "AllowedAPKSigningKeys": TYPE_LIST,
    "Builds": TYPE_BUILD,
    "VercodeOperation": TYPE_LIST,
    "CurrentVersionCode": TYPE_INT,
    "ArchivePolicy": TYPE_INT,
}

FLAG_TYPES: dict[str, int] = {
    "versionCode": TYPE_INT,
    "extlibs": TYPE_LIST,
    "srclibs": TYPE_LIST,
    "patch": TYPE_LIST,
    "rm": TYPE_LIST,
    "buildjni": TYPE_LIST,
    "preassemble": TYPE_LIST,
    "androidupdate": TYPE_LIST,
    "scanignore": TYPE_LIST,
    "scandelete": TYPE_LIST,
    "gradle": TYPE_LIST,
    "antcommands": TYPE_LIST,
    "gradleprops": TYPE_LIST,
    "sudo": TYPE_SCRIPT,
    "init": TYPE_SCRIPT,
    "prebuild": TYPE_SCRIPT,
    "build": TYPE_SCRIPT,
    "postbuild": TYPE_SCRIPT,
    "submodules": TYPE_BOOL,
    "oldsdkloc": TYPE_BOOL,
    "forceversion": TYPE_BOOL,
    "forcevercode": TYPE_BOOL,
    "novcheck": TYPE_BOOL,
    "antifeatures": TYPE_STRINGMAP,
    "timeout": TYPE_INT,
}


def _field_type(name: str) -> int:
    return FIELD_TYPES.get(name, TYPE_STRING)


def _flag_type(name: str) -> int:
    return FLAG_TYPES.get(name, TYPE_STRING)


def _format_multiline(value: Any) -> Any:
    if value is None:
        return None
    text = str(value)
    if "\n" in text:
        return ruamel.yaml.scalarstring.preserve_literal(text)
    return text


def _format_list(value: Any) -> list[Any]:
    return [v for v in value if v]


def _format_script(value: Any) -> Any:
    if isinstance(value, str):
        return value
    value = [v for v in value if v]
    if len(value) == 1:
        return value[0]
    return value


def _format_stringmap(stringmap: dict[str, Any]) -> Any:
    """In-fdroiddata path only; no localized metadata/ files on the publish host."""
    if not stringmap:
        return None
    make_list = True
    for name in sorted(stringmap):
        descdict = stringmap.get(name)
        if descdict and any(descdict.values()):
            make_list = False
            break
    if make_list:
        return sorted(stringmap.keys(), key=str.lower)
    return stringmap


def _blank_line_before_key(cm: CommentedMap, key: str) -> None:
    cm.yaml_set_comment_before_after_key(key, "bogus")
    cm.ca.items[key][1][-1].value = "\n"


def _blank_line_before_build_index(builds: CommentedSeq, index: int) -> None:
    builds.yaml_set_comment_before_after_key(index, "bogus")
    builds.ca.items[index][1][-1].value = "\n"


def _remove_blank_build_flags(builds: list[dict[str, Any]]) -> list[dict[str, Any]]:
    out: list[dict[str, Any]] = []
    for build in builds:
        new: dict[str, Any] = {}
        for key in BUILD_FLAGS:
            val = build.get(key)
            if val is None or val is False or val == "" or val == {} or val == []:
                continue
            new[key] = val
        out.append(new)
    return out


def _builds_to_yaml(builds: list[dict[str, Any]]) -> CommentedSeq:
    seq = CommentedSeq()
    for build in builds:
        row = CommentedMap()
        for field in BUILD_FLAGS:
            val = build.get(field)
            if val is None or val is False or val == "" or val == {} or val == []:
                continue
            ft = _flag_type(field)
            if ft == TYPE_MULTILINE:
                val = _format_multiline(val)
            elif ft == TYPE_LIST:
                val = _format_list(val)
            elif ft == TYPE_SCRIPT:
                val = _format_script(val)
            elif ft == TYPE_STRINGMAP and isinstance(val, dict):
                val = _format_stringmap(val)
            if val or val == 0:
                row[field] = val
        seq.append(row)
    for i in range(1, len(seq)):
        _blank_line_before_build_index(seq, i)
    return seq


def _app_to_yaml(app: dict[str, Any]) -> CommentedMap:
    cm = CommentedMap()
    insert_newline = False
    for field in YAML_APP_FIELD_ORDER:
        if field == "\n":
            insert_newline = True
            continue
        value = app.get(field)
        if not (value or field in ("Builds", "ArchivePolicy")):
            continue
        ft = _field_type(field)
        if field == "Builds":
            builds = app.get("Builds")
            if builds:
                cm["Builds"] = _builds_to_yaml(builds)
        elif field == "Categories" and isinstance(value, list):
            cm[field] = sorted(value, key=str.lower)
        elif field == "AntiFeatures" and isinstance(value, dict):
            formatted = _format_stringmap(value)
            if formatted:
                cm[field] = formatted
        elif field == "AllowedAPKSigningKeys" and isinstance(value, list):
            keys = [str(i).lower() for i in value]
            cm[field] = keys[0] if len(keys) == 1 else keys
        elif field == "ArchivePolicy":
            if value is not None:
                cm[field] = value
        elif ft == TYPE_MULTILINE:
            formatted = _format_multiline(value)
            if formatted:
                cm[field] = formatted
        elif ft == TYPE_SCRIPT:
            formatted = _format_script(value)
            if formatted:
                cm[field] = formatted
        else:
            if value:
                cm[field] = value
        if insert_newline and field in cm:
            insert_newline = False
            _blank_line_before_key(cm, field)
    return cm


def dump_fdroid_metadata_yml(app: dict[str, Any]) -> str:
    """Return metadata YAML bytes as written by ``fdroid rewritemeta``."""
    app = dict(app)
    builds = app.get("Builds")
    if isinstance(builds, list) and builds:
        app["Builds"] = sorted(
            _remove_blank_build_flags([b for b in builds if isinstance(b, dict)]),
            key=lambda b: int(b["versionCode"]),
        )
    cm = _app_to_yaml(app)
    yaml_writer = ruamel.yaml.YAML(typ="rt")
    yaml_writer.indent(mapping=2, sequence=4, offset=2)
    # Default width (80) wraps long prebuild/build script lines; rewritemeta keeps them on one line.
    yaml_writer.width = 4096
    buf = StringIO()
    yaml_writer.dump(cm, buf)
    return buf.getvalue()

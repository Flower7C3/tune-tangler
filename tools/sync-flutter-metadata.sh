#!/usr/bin/env bash
set -euo pipefail

# Sync `.metadata` version.revision (and matching migration hashes) to the
# installed Flutter SDK. `flutter upgrade` / `pub get` do not always update this file.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_DIR"
META="$PROJECT_DIR/.metadata"

if [[ ! -f "$META" ]]; then
  echo "❌ Missing $META"
  exit 1
fi

if ! command -v flutter >/dev/null 2>&1; then
  echo "❌ flutter not found in PATH"
  exit 1
fi

read -r NEW OLD <<<"$(python3 - <<'PY'
import json
import re
import subprocess
import sys
from pathlib import Path

meta_path = Path(".metadata")
text = meta_path.read_text(encoding="utf-8")
m = re.search(
    r"^version:\s*\n\s*revision:\s*\"([0-9a-f]{40})\"",
    text,
    re.MULTILINE,
)
if not m:
    sys.exit("❌ .metadata has no version.revision (40-char git hash)")
old = m.group(1)

proc = subprocess.run(
    ["flutter", "--version", "--machine"],
    capture_output=True,
    text=True,
    check=True,
    cwd=meta_path.parent,
)
info = json.loads(proc.stdout)
new = info.get("frameworkRevision", "").strip()
if not re.fullmatch(r"[0-9a-f]{40}", new):
    sys.exit(f"❌ Unexpected frameworkRevision from flutter: {new!r}")

channel = info.get("channel", "stable")
version = info.get("flutterVersion", info.get("frameworkVersion", "?"))
dart = info.get("dartSdkVersion", "?")

if old == new:
    print(f"{new} {old}")
    print(f"✓ .metadata already matches Flutter {version} (Dart {dart}, channel {channel})", file=sys.stderr)
    sys.exit(0)

print(f"{new} {old}")
print(
    f"ℹ Updating .metadata: {old[:12]}… → {new[:12]}… "
    f"(Flutter {version}, Dart {dart}, channel {channel})",
    file=sys.stderr,
)
PY
)"

if [[ "$OLD" == "$NEW" ]]; then
  exit 0
fi

if [[ "$(uname -s)" == Darwin ]]; then
  sed -i '' "s/${OLD}/${NEW}/g" "$META"
else
  sed -i "s/${OLD}/${NEW}/g" "$META"
fi

echo "✓ Wrote $META — commit this file with your Flutter SDK upgrade (F-Droid reads version.revision)."

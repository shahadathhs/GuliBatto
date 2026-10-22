#!/usr/bin/env bash
# Bump the product version.
#
#   make version v=0.2.0    write the version into every file that carries it (no git)
#   make release v=0.2.0    the same, then commit and push (you run this; it is never automatic)
#
# VERSION is the source of truth. The script also updates the Godot project, the export
# preset (Android) and the web package so they never drift. On the next merge to main, CI sees a VERSION
# with no release yet and publishes vX.Y.Z with the APK (docs/CI.md).
set -euo pipefail

cd "$(dirname "$0")/.."

mode="${1:-version}"
v="${v:-}"

[[ "$v" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || {
  echo "Usage: make ${mode} v=0.2.0   (a plain MAJOR.MINOR.PATCH version)" >&2
  exit 1
}

current="$(tr -d '[:space:]' < VERSION)"
[[ "$v" != "$current" ]] || { echo "VERSION is already ${v}." >&2; exit 1; }
[[ "$(printf '%s\n%s\n' "$current" "$v" | sort -V | tail -n 1)" == "$v" ]] || {
  echo "Refusing to go backwards: ${current} -> ${v}." >&2
  exit 1
}

if [[ "$mode" == "release" ]] && { ! git diff --quiet || ! git diff --cached --quiet; }; then
  echo "Working tree has uncommitted changes. Commit or stash them first." >&2
  exit 1
fi

printf '%s\n' "$v" > VERSION
sed -i.bak "s|^config/version=.*|config/version=\"${v}\"|" game/project.godot && rm game/project.godot.bak
sed -i.bak -e "s|^version/name=.*|version/name=\"${v}\"|" game/export_presets.cfg && rm game/export_presets.cfg.bak
sed -i.bak "s|^  \"version\": .*|  \"version\": \"${v}\",|" web/package.json && rm web/package.json.bak

echo "Version ${current} -> ${v}"

if [[ "$mode" == "release" ]]; then
  git add VERSION game/project.godot game/export_presets.cfg web/package.json
  git commit -m "chore: bump version to ${v}"
  git push
fi

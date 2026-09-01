#!/usr/bin/env bash
# Validate this plugin folder against the checks the Omarchy shell enforces
# before it will load a plugin (see omarchy-plugin-validate / PluginRegistry.qml).
#
# Kept dependency-free (bash + jq) so CI can run it without an Omarchy install.
#
# Usage: ./scripts/validate-plugin.sh [plugin-folder]   (default: repo root)
set -euo pipefail

DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
MANIFEST="$DIR/manifest.json"
status=0

fail() { echo "validate-plugin: $*" >&2; status=1; }
ok()   { echo "  ok  $*"; }

[[ -f "$MANIFEST" ]] || { echo "validate-plugin: no manifest.json in $DIR" >&2; exit 1; }
jq -e . "$MANIFEST" >/dev/null 2>&1 || { echo "validate-plugin: manifest.json is not valid JSON" >&2; exit 1; }
ok "manifest.json is valid JSON"

# schemaVersion must be the JSON number 1 — the string "1" is rejected, exactly
# as the shell's `schemaVersion !== 1` check rejects it.
jq -e '.schemaVersion == 1' "$MANIFEST" >/dev/null \
    && ok "schemaVersion is 1" \
    || fail "schemaVersion must be the number 1"

for field in id name version description author; do
    value="$(jq -r --arg f "$field" '.[$f] // ""' "$MANIFEST")"
    [[ -n "$value" ]] && ok "$field = $value" || fail "missing or empty field: $field"
done

# Reverse-DNS id, as the marketplace requires.
id="$(jq -r '.id // ""' "$MANIFEST")"
[[ "$id" =~ ^[A-Za-z0-9]([A-Za-z0-9_-]*)(\.[A-Za-z0-9][A-Za-z0-9_-]*)+$ ]] \
    && ok "id is a well-formed reverse-DNS identifier" \
    || fail "id is not a well-formed reverse-DNS identifier: $id"

jq -e '(.kinds // []) | length > 0' "$MANIFEST" >/dev/null \
    && ok "kinds = $(jq -rc '.kinds' "$MANIFEST")" \
    || fail "kinds must be a non-empty array"

# A bar-widget plugin must declare a barWidget entry point.
if jq -e '(.kinds // []) | index("bar-widget")' "$MANIFEST" >/dev/null; then
    jq -e '.entryPoints.barWidget // "" | length > 0' "$MANIFEST" >/dev/null \
        || fail 'kinds includes "bar-widget" but entryPoints.barWidget is missing'
fi

# Entry points must be safe relative paths that exist and are not symlinks.
while IFS= read -r entry; do
    [[ -n "$entry" ]] || continue
    case "$entry" in
        /*|*..*) fail "entry point must be a relative path without '..': $entry"; continue ;;
    esac
    if [[ ! -f "$DIR/$entry" ]]; then
        fail "entry point does not exist: $entry"
    elif [[ -L "$DIR/$entry" ]]; then
        fail "entry point is a symlink: $entry"
    else
        ok "entry point exists: $entry"
    fi
done < <(jq -r '(.entryPoints // {}) | .[]' "$MANIFEST")

# The shell refuses a plugin folder containing symlinks.
if find "$DIR" -path "$DIR/.git" -prune -o -type l -print | grep -q .; then
    fail "plugin folder contains symlinks"
else
    ok "no symlinks in the plugin folder"
fi

for f in README.md LICENSE preview.png; do
    [[ -f "$DIR/$f" ]] && ok "$f present" || fail "missing $f"
done

if (( status == 0 )); then
    echo "validate-plugin: OK"
else
    echo "validate-plugin: FAILED" >&2
fi
exit $status

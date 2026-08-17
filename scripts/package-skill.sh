#!/usr/bin/env bash
# =============================================================================
# web-builder — package the agent skill artifact  (web-builder.skill)
# -----------------------------------------------------------------------------
# Builds web-builder.skill DETERMINISTICALLY from scripts/skill-manifest.txt:
# the same source always yields the same archive CONTENT. Ships exactly the
# manifest paths — nothing more (no .DS_Store, temp, local state, or docs shell).
#
#   Deterministic:  sorted file order, normalized timestamps, stored (no deflate).
#   Explicit:       every shipped path comes from skill-manifest.txt.
#   Honest:         prints version + file count + content-hash + archive sha256.
#
# Verify what you built with:  bash scripts/verify-package.sh
# Usage:  bash scripts/package-skill.sh [output.skill]   (default: web-builder.skill)
# =============================================================================
set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT" || exit 1

MANIFEST="scripts/skill-manifest.txt"
OUT="${1:-web-builder.skill}"
# Absolute output path used as-is; relative is resolved against the repo root.
case "$OUT" in /*) OUTPATH="$OUT" ;; *) OUTPATH="$ROOT/$OUT" ;; esac
CSS="web-builder/assets/web-builder.css"

[ -f "$MANIFEST" ] || { echo "ERROR: missing $MANIFEST" >&2; exit 1; }
command -v zip >/dev/null 2>&1 || { echo "ERROR: 'zip' not found" >&2; exit 1; }

# --- Expand the manifest to a concrete, sorted, de-duped file list --------------
files="$(
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%%#*}"; line="$(printf '%s' "$line" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
    [ -z "$line" ] && continue
    if [ "$line" != "${line#*"*"}" ]; then   # contains '*' -> glob rule (bash-3.2-safe test)
      # shellcheck disable=SC2086
      ls $line 2>/dev/null
    else
      [ -e "$line" ] && printf '%s\n' "$line"
    fi
  done < "$MANIFEST" | LC_ALL=C sort -u
)"

[ -n "$files" ] || { echo "ERROR: manifest expanded to zero files" >&2; exit 1; }

# Refuse to ship junk even if a future manifest glob catches it.
if printf '%s\n' "$files" | grep -qE '(^|/)\.DS_Store$|\.log$|\.skill$|\.zip$|(^|/)\.git/'; then
  echo "ERROR: manifest would ship a forbidden artifact (.DS_Store/.log/.skill/.zip/.git)" >&2; exit 1
fi

count="$(printf '%s\n' "$files" | grep -c .)"

# --- Stage into a temp dir, preserving the web-builder/... path structure --------
STAGE="$(mktemp -d "${TMPDIR:-/tmp}/wb-pkg.XXXXXX")"
trap 'rm -rf "$STAGE"' EXIT
while IFS= read -r f; do
  mkdir -p "$STAGE/$(dirname "$f")"
  cp "$f" "$STAGE/$f"
done <<< "$files"

# Normalize timestamps so the archive is reproducible (fixed epoch, not "now").
find "$STAGE" -exec touch -t 200001010000.00 {} + 2>/dev/null || true

# --- Content-hash: independent of zip byte layout (path + sha256 per file) -------
content_hash="$(
  while IFS= read -r f; do
    h="$(shasum -a 256 "$f" | awk '{print $1}')"
    printf '%s  %s\n' "$h" "$f"
  done <<< "$files" | LC_ALL=C sort | shasum -a 256 | awk '{print $1}'
)"

# --- Build the archive deterministically ----------------------------------------
rm -f "$OUTPATH"
( cd "$STAGE" && find web-builder -type f | LC_ALL=C sort | zip -X -D -0 -q "$OUTPATH" -@ ) \
  || { echo "ERROR: zip failed" >&2; exit 1; }

ver="$(grep -oE -- '--wb-version:[[:space:]]*"[0-9]+\.[0-9]+"' "$CSS" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -1)"
archive_sha="$(shasum -a 256 "$OUTPATH" | awk '{print $1}')"
size="$(wc -c < "$OUTPATH" | tr -d ' ')"

echo "packaged: $OUT"
echo "  version:       v${ver:-?}"
echo "  files:         $count"
echo "  size:          $size bytes"
echo "  content-hash:  $content_hash"
echo "  archive-sha256:$archive_sha"
echo "Next: bash scripts/verify-package.sh"

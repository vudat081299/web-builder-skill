#!/usr/bin/env bash
# =============================================================================
# web-builder — verify the packaged skill artifact  (web-builder.skill)
# -----------------------------------------------------------------------------
# Unpacks web-builder.skill into a temp dir and checks it is HONEST:
#   1. No forbidden junk shipped (.DS_Store / *.log / *.skill / *.zip / .git).
#   2. Two-way manifest parity: archive contents == skill-manifest.txt expansion
#      (nothing extra shipped, nothing the manifest promises is missing).
#   3. STALE detection: every packaged file matches current source byte-for-byte.
#   4. Content-hash + version reported.
#
# Exit 0 = package is fresh, complete, and honest. Exit 2 = a problem (a stale
# or drifted artifact is the classic failure — rebuild with package-skill.sh).
# Usage:  bash scripts/verify-package.sh [artifact.skill]   (default: web-builder.skill)
# =============================================================================
set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT" || exit 1

MANIFEST="scripts/skill-manifest.txt"
ART="${1:-web-builder.skill}"
CSS="web-builder/assets/web-builder.css"
fail=0

[ -f "$ART" ] || { echo "BLOCK · no artifact '$ART' — build it first: bash scripts/package-skill.sh" >&2; exit 2; }
[ -f "$MANIFEST" ] || { echo "BLOCK · missing $MANIFEST" >&2; exit 2; }
command -v unzip >/dev/null 2>&1 || { echo "BLOCK · 'unzip' not found" >&2; exit 2; }

# --- Expand the manifest the same way package-skill.sh does ----------------------
expected="$(
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

# --- Unpack into temp -----------------------------------------------------------
TMP="$(mktemp -d "${TMPDIR:-/tmp}/wb-verify.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT
unzip -q "$ART" -d "$TMP" || { echo "BLOCK · '$ART' is not a valid zip archive" >&2; exit 2; }

actual="$(cd "$TMP" && find . -type f | sed 's|^\./||' | LC_ALL=C sort)"

# --- CHECK: no forbidden junk ---------------------------------------------------
junk="$(printf '%s\n' "$actual" | grep -E '(^|/)\.DS_Store$|\.log$|\.skill$|\.zip$|(^|/)\.git/' || true)"
if [ -n "$junk" ]; then
  { echo "BLOCK · artifact ships forbidden file(s):"; printf '%s\n' "$junk" | sed 's/^/    /'; } >&2; fail=1
fi

# --- CHECK: two-way manifest parity --------------------------------------------
extra="$(comm -13 <(printf '%s\n' "$expected") <(printf '%s\n' "$actual"))"
missing="$(comm -23 <(printf '%s\n' "$expected") <(printf '%s\n' "$actual"))"
if [ -n "$extra" ]; then
  { echo "BLOCK · artifact contains file(s) NOT in the manifest (over-shipping):"; printf '%s\n' "$extra" | sed 's/^/    /'; } >&2; fail=1
fi
if [ -n "$missing" ]; then
  { echo "BLOCK · manifest promises file(s) the artifact is MISSING:"; printf '%s\n' "$missing" | sed 's/^/    /'; } >&2; fail=1
fi

# --- CHECK: staleness (packaged content must equal current source) --------------
stale=""
while IFS= read -r f; do
  [ -z "$f" ] && continue
  if [ -f "$ROOT/$f" ]; then
    cmp -s "$TMP/$f" "$ROOT/$f" || stale="${stale}${f}"$'\n'
  fi
done <<< "$actual"
if [ -n "$stale" ]; then
  { echo "BLOCK · STALE artifact — packaged file(s) differ from current source (repackage):"
    printf '%s' "$stale" | sed 's/^/    /'; } >&2; fail=1
fi

# --- Report ---------------------------------------------------------------------
ver="$(grep -oE -- '--wb-version:[[:space:]]*"[0-9]+\.[0-9]+"' "$CSS" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -1)"
content_hash="$(
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    h="$(shasum -a 256 "$TMP/$f" | awk '{print $1}')"
    printf '%s  %s\n' "$h" "$f"
  done <<< "$actual" | LC_ALL=C sort | shasum -a 256 | awk '{print $1}'
)"
n="$(printf '%s\n' "$actual" | grep -c .)"

if [ "$fail" -ne 0 ]; then
  echo "" >&2
  echo "^ Package problem(s) above. Rebuild: bash scripts/package-skill.sh" >&2
  exit 2
fi
echo "package OK · $ART · v${ver:-?} · $n files · content-hash $content_hash · fresh (matches source) · manifest parity clean"
exit 0

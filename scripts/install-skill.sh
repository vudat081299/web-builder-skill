#!/usr/bin/env bash
# =============================================================================
# web-builder — install the packaged skill into a skills directory
# -----------------------------------------------------------------------------
# DRY-RUN BY DEFAULT. It never touches an install target unless you pass --apply,
# and it refuses to install a stale/invalid package (runs verify-package first).
#
# Target resolution (first that is set wins):
#   1. --target <dir>
#   2. $WB_SKILL_INSTALL_DIR
#   3. scripts/install-config.local.sh   (gitignored; `WB_SKILL_INSTALL_DIR=...`)
#      — copy scripts/install-config.example.sh to it and edit.
# No personal absolute path is ever hardcoded here.
#
# Usage:
#   bash scripts/install-skill.sh                 # dry-run: resolve + report only
#   bash scripts/install-skill.sh --target DIR    # dry-run into DIR
#   bash scripts/install-skill.sh --apply         # actually copy (your explicit act)
#
# NOTE: an agent must NOT run --apply on the user's behalf without explicit
# in-session permission — it writes outside this repo.
# =============================================================================
set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT" || exit 1

ART="web-builder.skill"
CSS="web-builder/assets/web-builder.css"
APPLY=0
TARGET=""

while [ $# -gt 0 ]; do
  case "$1" in
    --apply) APPLY=1 ;;
    --target) shift; TARGET="${1:-}" ;;
    --target=*) TARGET="${1#*=}" ;;
    -h|--help) grep -E '^#( |$)' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 1 ;;
  esac
  shift
done

# Resolve target if not given on the CLI.
if [ -z "$TARGET" ]; then
  if [ -n "${WB_SKILL_INSTALL_DIR:-}" ]; then
    TARGET="$WB_SKILL_INSTALL_DIR"
  elif [ -f scripts/install-config.local.sh ]; then
    # shellcheck disable=SC1091
    . scripts/install-config.local.sh
    TARGET="${WB_SKILL_INSTALL_DIR:-}"
  fi
fi

[ -f "$ART" ] || { echo "ERROR: no '$ART' — build it first: bash scripts/package-skill.sh" >&2; exit 1; }

# Never install a stale/invalid package.
if ! bash scripts/verify-package.sh "$ART" >/dev/null 2>&1; then
  echo "ERROR: '$ART' failed verification (stale or invalid). Run: bash scripts/verify-package.sh" >&2
  exit 1
fi

ver="$(grep -oE -- '--wb-version:[[:space:]]*"[0-9]+\.[0-9]+"' "$CSS" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -1)"
sha="$(shasum -a 256 "$ART" | awk '{print $1}')"

echo "web-builder skill install"
echo "  artifact:  $ART"
echo "  version:   v${ver:-?}"
echo "  checksum:  $sha"
echo "  target:    ${TARGET:-<unset>}"

if [ -z "$TARGET" ]; then
  echo ""
  echo "No target set. Set one of:"
  echo "  • WB_SKILL_INSTALL_DIR=/path/to/skills bash scripts/install-skill.sh --apply"
  echo "  • bash scripts/install-skill.sh --target /path/to/skills --apply"
  echo "  • cp scripts/install-config.example.sh scripts/install-config.local.sh  (then edit)"
  exit 0
fi

DEST="$TARGET/web-builder"
if [ "$APPLY" -ne 1 ]; then
  echo ""
  echo "DRY RUN — would install to: $DEST"
  echo "  (replacing any existing web-builder/ there with the packaged skill)"
  echo "Re-run with --apply to perform the copy. Verified fresh; safe to apply."
  exit 0
fi

# --apply: perform the install (the invoker's explicit act).
command -v unzip >/dev/null 2>&1 || { echo "ERROR: 'unzip' not found" >&2; exit 1; }
mkdir -p "$TARGET" || { echo "ERROR: cannot create target '$TARGET'" >&2; exit 1; }
TMP="$(mktemp -d "${TMPDIR:-/tmp}/wb-install.XXXXXX")"; trap 'rm -rf "$TMP"' EXIT
unzip -q "$ART" -d "$TMP" || { echo "ERROR: unpack failed" >&2; exit 1; }
rm -rf "$DEST"
mkdir -p "$DEST"
cp -R "$TMP/web-builder/." "$DEST/" || { echo "ERROR: copy failed" >&2; exit 1; }
echo ""
echo "INSTALLED v${ver:-?} -> $DEST"

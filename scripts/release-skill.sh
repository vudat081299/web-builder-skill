#!/usr/bin/env bash
# =============================================================================
# web-builder — release orchestrator (validate → package → verify package)
# -----------------------------------------------------------------------------
# One command to produce a verified release candidate of web-builder.skill.
# It NEVER commits, pushes, or installs — those are separate, explicit acts that
# require the user's in-session permission (see install-skill.sh --apply).
#
# Usage:  bash scripts/release-skill.sh
# Exit 0 = a fresh, verified web-builder.skill is ready. Non-zero = a step failed.
# =============================================================================
set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT" || exit 1
CSS="web-builder/assets/web-builder.css"

step() { printf '\n== %s ==\n' "$1"; }

step "1/3 · verify source (scripts/verify.sh)"
if ! out="$(bash scripts/verify.sh 2>&1)"; then
  printf '%s\n' "$out" >&2
  echo "release aborted: source verification failed." >&2; exit 1
fi
echo "source OK"

step "2/3 · package (scripts/package-skill.sh)"
bash scripts/package-skill.sh || { echo "release aborted: packaging failed." >&2; exit 1; }

step "3/3 · verify package (scripts/verify-package.sh)"
bash scripts/verify-package.sh || { echo "release aborted: package verification failed." >&2; exit 1; }

ver="$(grep -oE -- '--wb-version:[[:space:]]*"[0-9]+\.[0-9]+"' "$CSS" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -1)"
sha="$(shasum -a 256 web-builder.skill | awk '{print $1}')"
printf '\n'
echo "RELEASE CANDIDATE READY"
echo "  version:   v${ver:-?}"
echo "  artifact:  web-builder.skill"
echo "  checksum:  $sha"
echo "  next (explicit, needs your OK): commit · push · bash scripts/install-skill.sh --apply"

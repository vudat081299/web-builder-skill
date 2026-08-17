#!/usr/bin/env bash
# =============================================================================
# web-builder — validate-sync ADAPTER (.claude thin wrapper, NOT the logic)
# -----------------------------------------------------------------------------
# The agent-agnostic verification core lives OUTSIDE .claude at scripts/verify.sh
# so ANY harness — Claude Code, CI, a bare shell — runs the same checks with
# `bash scripts/verify.sh`. This adapter exists only so the .claude wiring
# (pre-commit-gate.sh) and long-standing muscle memory
# (`bash .claude/hooks/validate-sync.sh`) keep working: it just forwards.
#
# Do not add checks here. Add them to scripts/verify.sh (the single source of
# truth for the guardrails); this file must stay a pass-through.
# =============================================================================
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
CORE="$ROOT/scripts/verify.sh"
# Core absent (or not this repo) -> do nothing, never block an unrelated tree.
[ -f "$CORE" ] || exit 0
exec bash "$CORE" "$@"

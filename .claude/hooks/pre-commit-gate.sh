#!/usr/bin/env bash
# =============================================================================
# web-builder — PreToolUse(Bash) commit/push gate
# -----------------------------------------------------------------------------
# Only gates `git commit` / `git push`: runs the deterministic guardrails first
# and blocks (exit 2) if an invariant is broken, so drift can never be shipped.
# Every other Bash command passes straight through (exit 0).
# =============================================================================
input="$(cat)"
cmd="$(printf '%s' "$input" | python3 -c 'import sys,json
try:
    print(json.load(sys.stdin).get("tool_input",{}).get("command",""))
except Exception:
    print("")' 2>/dev/null)"

case "$cmd" in
  *"git commit"*|*"git push"*|*"git "*" commit"*|*"git "*" push"*)
    # matches `git commit`, `git push`, and flag forms like `git -C dir commit`
    exec "$(dirname "$0")/validate-sync.sh"
    ;;
esac
exit 0

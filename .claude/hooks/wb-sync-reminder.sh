#!/usr/bin/env bash
# =============================================================================
# web-builder — PostToolUse(Edit|Write) nudge
# -----------------------------------------------------------------------------
# The moment web-builder.css is edited, inject the 6-place sync checklist. This is
# the closest a deterministic hook gets to "editing the library auto-triggers the
# docs update": a hook can't WRITE the docs (that's model work), but it guarantees
# the cascade isn't forgotten. validate-sync.sh is the hard backstop at commit.
# =============================================================================
input="$(cat)"
path="$(printf '%s' "$input" | python3 -c 'import sys,json
try:
    print(json.load(sys.stdin).get("tool_input",{}).get("file_path",""))
except Exception:
    print("")' 2>/dev/null)"

case "$path" in
  *web-builder/assets/web-builder.css)
    msg="✎ You edited web-builder.css. If you added or changed a component, sync all 6 places (CLAUDE.md · /wb-change):
  1) demo page  web-builder/assets/pages/<id>.html   (markup only — NO <style> block)
  2) NAV entry  web-builder/assets/app.js            ({ id, label } in the right intent group)
  3) catalog    web-builder/references/components-catalog.md   (section + decision-guide row)
  4) SKILL.md   web-builder/SKILL.md                 (add to the right scope group)
  5) if relevant: design-principles.md · integration.md · bootstrap-comparison.md
  6) run  .claude/hooks/validate-sync.sh             (routes==pages, no stray <style>, app.js parses)"
    python3 -c 'import json,sys
print(json.dumps({"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":sys.argv[1]}}))' "$msg"
    ;;
esac
exit 0

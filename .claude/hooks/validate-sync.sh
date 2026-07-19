#!/usr/bin/env bash
# =============================================================================
# web-builder — deterministic guardrails (the "standards review", in shell)
# -----------------------------------------------------------------------------
# The repo's DELIVERABLE is the web-builder skill, so this validates BOTH:
#   • the docs site   — route<->page parity, markup-only pages, app.js syntax
#   • the skill itself — SKILL.md frontmatter, references exist, catalog<->CSS
#                        coherence, and structural validity of the shipping CSS
# All checks are model-free, so they're ~free and can gate every commit.
#
# Used by:  .claude/hooks/pre-commit-gate.sh  (blocks a broken `git commit`/`push`)
#           and by hand:  .claude/hooks/validate-sync.sh
#
# Exit 2 -> a HARD invariant is broken; as a gate this blocks and the reason is
#           fed back so the fix continues in place (never a delete-and-restart).
# Exit 0 -> invariants hold (advisory notes may still print to stderr).
# =============================================================================
set -uo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT" || exit 0
A="web-builder/assets"
fail=0

# Not the web-builder repo / layout? Do nothing (never block an unrelated tree).
[ -d "$A/pages" ] || exit 0

# --- CHECK 1 (hard): NAV routes == pages/<id>.html, 1:1, unique, no orphans ---
# Match only NAV-shaped lines (id followed by label) so a stray demo object
# literal like { id: "row-1" } elsewhere in app.js can't invent a phantom route.
# Pages come from the *.html glob only (ignores subdirs, .bak, README, …).
routes_raw="$(grep -oE 'id: "[a-z0-9-]+", *label:' "$A/app.js" | sed -E 's/id: "([a-z0-9-]+)".*/\1/')"
routes="$(printf '%s\n' "$routes_raw" | sort -u)"
pages="$(ls "$A"/pages/*.html 2>/dev/null | sed 's|.*/||; s/\.html$//' | sort -u)"
dup_ids="$(printf '%s\n' "$routes_raw" | sort | uniq -d)"
if [ -n "$dup_ids" ]; then
  { echo "BLOCK · duplicate NAV id(s) in app.js (each id must map to exactly one page):"
    printf '%s\n' "$dup_ids" | sed 's/^/    /'; } >&2
  fail=1
fi
if [ "$routes" != "$pages" ]; then
  {
    echo "BLOCK · route<->page parity broken (app.js NAV vs pages/*.html):"
    diff <(printf '%s\n' "$routes") <(printf '%s\n' "$pages") | sed 's/^/    /'
    echo "    (< = NAV id with no page file · > = page file with no NAV entry)"
  } >&2
  fail=1
fi

# --- CHECK 2 (hard): demo pages are markup-only (no per-page <style> blocks) --
style_pages="$(grep -lE '<style' "$A"/pages/*.html 2>/dev/null || true)"
if [ -n "$style_pages" ]; then
  {
    echo "BLOCK · per-page <style> block(s) found — pages must be markup-only."
    echo "        Move demo chrome into docs.css (design-principles §16):"
    printf '%s\n' "$style_pages" | sed 's/^/    /'
  } >&2
  fail=1
fi

# --- CHECK 3 (hard): app.js parses (the "compile error" class in a zero-build repo) -
if command -v node >/dev/null 2>&1; then
  if ! err="$(node --check "$A/app.js" 2>&1)"; then
    { echo "BLOCK · app.js JS syntax error:"; printf '%s\n' "$err" | sed 's/^/    /'; } >&2
    fail=1
  fi
fi

# --- CHECK 4 (advisory, manual runs only): raw-hex painting a component inline -
# Excludes the sanctioned --wb-*-color token API; text ids / colour-input values
# won't carry a background|color|border prefix. TTY-gated so the commit gate stays
# quiet — it's a code-smell scan for `validate-sync.sh` by hand, not a per-commit nag.
if [ -t 1 ]; then
  hex="$(grep -rnoE 'style="[^"]*(background|color|border)[^"]*#[0-9a-fA-F]{3,8}' "$A"/pages/*.html 2>/dev/null \
          | grep -vE -- '--wb-[a-z-]+-color' || true)"
  if [ -n "$hex" ]; then
    { echo "note · raw-hex appearance in inline styles (prefer a token or --wb-*-color):"
      printf '%s\n' "$hex" | head -15 | sed 's/^/    /'; } >&2
  fi
fi

# --- CHECK 5 (advisory): the 6-place cascade — CSS changed but docs didn't ----
changed="$(git status --porcelain 2>/dev/null | cut -c4-)"
if printf '%s\n' "$changed" | grep -q 'web-builder/assets/web-builder.css' \
   && ! printf '%s\n' "$changed" | grep -qE 'assets/pages/|assets/app.js|components-catalog.md|SKILL.md'; then
  { echo "note · web-builder.css changed but no demo page / NAV / catalog / SKILL.md is staged."
    echo "       Adding or changing a component is a 6-place sync (CLAUDE.md / /wb-change)."; } >&2
fi

# =============================================================================
#  SKILL DELIVERABLE — the repo ships the web-builder skill; validate the skill
#  artifact, not just the docs site.
# =============================================================================
SKILL="web-builder/SKILL.md"
CAT="web-builder/references/components-catalog.md"

# --- CHECK 6 (hard): SKILL.md frontmatter present; trigger description healthy --
if [ -f "$SKILL" ] && command -v python3 >/dev/null 2>&1; then
  fmout="$(python3 - "$SKILL" <<'PY'
import re,sys
t=open(sys.argv[1],encoding="utf-8").read()
m=re.match(r"^---\n(.*?)\n---",t,re.S)
if not m: print("HARD:no YAML frontmatter"); sys.exit()
fm=m.group(1)
if not re.search(r"^name:\s*\S",fm,re.M): print("HARD:missing name:")
dm=re.search(r"description:\s*>-?\s*\n(.*?)(?=\n[A-Za-z_]+:|\Z)",fm,re.S) or re.search(r"description:\s*(.+)",fm)
desc=" ".join(l.strip() for l in dm.group(1).splitlines()).strip() if dm else ""
print("HARD:missing description" if not desc else f"LEN:{len(desc)}")
PY
)"
  if printf '%s' "$fmout" | grep -q '^HARD:'; then
    { echo "BLOCK · SKILL.md frontmatter:"; printf '%s\n' "$fmout" | grep '^HARD:' | sed 's/^HARD:/    /'; } >&2
    fail=1
  fi
  len="$(printf '%s' "$fmout" | sed -n 's/^LEN://p')"
  [ -n "$len" ] && [ "$len" -gt 1024 ] && echo "note · SKILL.md description is ${len} chars (>1024) — the skill listing truncates it; keep it tighter for reliable triggering." >&2
fi

# --- CHECK 7 (hard): every references/*.md the SKILL points at exists -----------
if [ -f "$SKILL" ]; then
  while IFS= read -r ref; do
    [ -n "$ref" ] && { [ -f "web-builder/$ref" ] || { echo "BLOCK · SKILL.md references a missing file: web-builder/$ref" >&2; fail=1; }; }
  done < <(grep -oE 'references/[a-z0-9-]+\.md' "$SKILL" | sort -u)
fi

# --- CHECK 8 (hard): the catalog must not document a wb-* class the CSS lacks ----
if [ -f "$CAT" ]; then
  phantom="$(comm -23 <(grep -oE '\.wb-[a-z0-9-]+' "$CAT" | sort -u) <(grep -oE '\.wb-[a-z0-9-]+' "$A/web-builder.css" | sort -u))"
  if [ -n "$phantom" ]; then
    { echo "BLOCK · components-catalog.md documents wb-* class(es) not defined in web-builder.css:"
      printf '%s\n' "$phantom" | sed 's/^/    /'; } >&2
    fail=1
  fi
fi

# --- CHECK 9 (hard): the shipping CSS is structurally valid (balanced braces) ---
opens="$(grep -o '{' "$A/web-builder.css" | wc -l | tr -d ' ')"
closes="$(grep -o '}' "$A/web-builder.css" | wc -l | tr -d ' ')"
if [ "$opens" != "$closes" ]; then
  { echo "BLOCK · web-builder.css brace mismatch: { = $opens vs } = $closes (structural error in the shipping CSS)."; } >&2
  fail=1
fi

# --- CHECK 10 (hard): SKILL.md 'Current scope' names every app.js NAV group ----
# The intent-group list is the classic drift victim: hand-copied into prose it goes
# stale (README + /wb-change both grew a phantom "Biểu đồ" group that NAV never had).
# NAV in app.js is the source of truth; the SHIPPING SKILL.md is the copy the next AI
# trusts, so enforce that one against NAV. Each NAV group label must appear as a bold
# scope header `**<label>**` (parentheticals incl., e.g. `**Lớp phủ (Overlay)**`).
# Other prose (README, /wb-change, CLAUDE.md) may abbreviate — don't repeat the list;
# point at NAV. (Lesson banked in /wb-change SKILL.md step 3.)
if [ -f "$SKILL" ]; then
  miss_groups=""
  while IFS= read -r g; do
    [ -z "$g" ] && continue
    grep -qF "**$g**" "$SKILL" || miss_groups="${miss_groups}    ${g}"$'\n'
  done < <(grep -oE 'group: "[^"]+"' "$A/app.js" | sed -E 's/group: "(.*)"/\1/')
  if [ -n "$miss_groups" ]; then
    { echo "BLOCK · SKILL.md 'Current scope' is missing NAV group(s) from app.js (group list drifted):"
      printf '%s' "$miss_groups"
      echo "    NAV (app.js) is the source of truth — add each as a bold header **<label>** or fix the rename."; } >&2
    fail=1
  fi
fi

if [ "$fail" -ne 0 ]; then
  echo "" >&2
  echo "^ Fix the BLOCK item(s) and keep editing (don't restart). Guardrail: .claude/hooks/validate-sync.sh" >&2
  exit 2
fi

# Quiet as a hook (stdout is piped); informative when run by hand in a terminal.
if [ -t 1 ]; then
  n="$(printf '%s\n' "$routes" | grep -c .)"
  echo "web-builder guardrails OK · docs: ${n} routes == ${n} pages · no stray <style> · app.js parses · skill: SKILL.md + references + catalog<->CSS + CSS braces + scope==NAV-groups coherent."
fi
exit 0

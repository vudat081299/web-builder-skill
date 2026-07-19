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

# For each principle N in $1 (realset, nl-separated) absent from the candidate set $2, emit " §N".
# Shared by CHECK 11(b) overview-index and (c) principles-render so the two coverage checks can't drift.
missing_secs() {
  local real="$1" cand="$2" out="" n
  for n in $real; do
    printf '%s\n' "$cand" | grep -qx "$n" || out="$out §$n"
  done
  printf '%s' "$out"
}

# --- CHECK 11 (hard): every "§N" resolves; overview indexes them; principles renders them in full
# The docs sprinkle "§N" (design-principle N) across many pages, but nothing resolves them.
# design-principles.md's `## N.` headings are the source of truth. Enforce: (a) no §N cited
# anywhere points past/outside that set (caught a stale §27 once); (b) overview.html carries a
# COMPLETE in-site §-index (§1…§max); (c) principles.html RENDERS every §1…§max in full (not just the
# index) — the human-facing docs stay self-contained on the site (§23), never a teaser to a raw .md.
DP="web-builder/references/design-principles.md"
OV="$A/pages/overview.html"
PR="$A/pages/principles.html"
if [ -f "$DP" ] && [ -f "$OV" ]; then
  realset="$(grep -oE '^## [0-9]+\.' "$DP" | grep -oE '[0-9]+' | sort -un)"
  maxp="$(printf '%s\n' "$realset" | tail -1)"
  # (a) dangling references — a §N with no matching principle
  dangling=""
  while IFS= read -r n; do
    [ -z "$n" ] && continue
    printf '%s\n' "$realset" | grep -qx "$n" || dangling="$dangling §$n"
  done < <(grep -rhoE '§[0-9]+' "$A"/pages/*.html web-builder/references/*.md "$SKILL" README.md CLAUDE.md 2>/dev/null | grep -oE '[0-9]+' | sort -un)
  if [ -n "$dangling" ]; then
    { echo "BLOCK · dangling design-principle reference(s) — no such §N in design-principles.md (max §${maxp}):"
      echo "   $dangling"; } >&2
    fail=1
  fi
  # (b) overview.html must index every principle §1…§max (keep the in-site §-map complete).
  # Extract overview's §-set the same robust way as (a) — avoids multibyte/trailing-char grep traps
  # and the §1-vs-§10 ambiguity.
  ov_set="$(grep -oE '§[0-9]+' "$OV" | grep -oE '[0-9]+' | sort -un)"
  miss_idx="$(missing_secs "$realset" "$ov_set")"
  if [ -n "$miss_idx" ]; then
    { echo "BLOCK · overview.html '§1 → §N' map is missing principle(s) (add them so every §N resolves in-site):"
      echo "   $miss_idx"; } >&2
    fail=1
  fi
  # (c) principles.html must RENDER every principle §1…§max in full (not merely index it) — §23.
  if [ ! -f "$PR" ]; then
    { echo "BLOCK · pages/principles.html is missing — the full in-site §1…§${maxp} rendering (§23) must exist."; } >&2
    fail=1
  else
    pr_set="$(grep -oE '§[0-9]+' "$PR" | grep -oE '[0-9]+' | sort -un)"
    miss_full="$(missing_secs "$realset" "$pr_set")"
    if [ -n "$miss_full" ]; then
      { echo "BLOCK · principles.html does not render principle(s) in full (docs site is self-contained — §23):"
        echo "   $miss_full"; } >&2
      fail=1
    fi
  fi
fi

# --- CHECK 12 (advisory): a docs-site page must not DEFER its content to a raw reference .md (§23) ----
# The human-facing site is self-contained; "read the full version in X.md" is the incomplete-docs trap.
# Precise + phrasing-based: a completeness word next to a `.md` filename on ONE line. Legit §8 behaviour
# pointers ("… xem integration.md") carry no completeness word → spared; naming a .md as the AI-facing twin
# keeps its distance from "đầy đủ" → spared. The two meta pages that must QUOTE the anti-pattern to explain it
# — principles.html (§23) and tooling.html (this very check) — are excluded (CHECK 11c already hard-guarantees
# principles renders in full). Advisory: prints only on a match, never blocks — the hard guarantee is CHECK 11(c).
defer="$(grep -HnoE '(đầy đủ|roster|full version|complete roster).{0,80}\.md' "$A"/pages/*.html 2>/dev/null \
          | grep -vE '/(principles|tooling)\.html:' || true)"
if [ -n "$defer" ]; then
  { echo "note · page(s) may defer content to a raw .md — docs site should be self-contained (§23): render in-site, or use an accordion / a dedicated page and link in-site:"
    printf '%s\n' "$defer" | head -15 | sed 's/^/    /'; } >&2
fi

# --- CHECK 13 (hard): every README trade-off "T#" is rendered on the decisions docs page (§23) ----
# README § "Deliberate trade-offs" is the human source, but a reader who only browses the docs SITE was
# missing the whole list — nothing enforced the mirror (the gap that put this check here). So, exactly like
# the §N system (CHECK 11c renders every principle), enforce both directions between README and the dedicated
# pages/decisions.html: (a) every T# defined in README is rendered on the page; (b) no stale T# on the page
# that README no longer defines. decisions.html existing as a route is already guaranteed by CHECK 1.
DEC="$A/pages/decisions.html"
if [ -f README.md ] && [ -f "$DEC" ]; then
  rd_t="$(grep -oE '\*\*T[0-9]+ ' README.md | grep -oE 'T[0-9]+' | sort -u)"   # bold-lead bullets **T# ·
  dec_t="$(grep -oE 'T[0-9]+' "$DEC" | sort -u)"
  miss_t=""; for t in $rd_t; do printf '%s\n' "$dec_t" | grep -qx "$t" || miss_t="$miss_t $t"; done
  stale_t=""; for t in $dec_t; do printf '%s\n' "$rd_t" | grep -qx "$t" || stale_t="$stale_t $t"; done
  if [ -n "$miss_t" ]; then
    { echo "BLOCK · decisions.html is missing README trade-off(s) — the docs site must mirror them in full (§23):"
      echo "   $miss_t"
      echo "   Render each on web-builder/assets/pages/decisions.html (README § Deliberate trade-offs is the source)."; } >&2
    fail=1
  fi
  if [ -n "$stale_t" ]; then
    { echo "BLOCK · decisions.html renders trade-off tag(s) README no longer defines (stale mirror):"
      echo "   $stale_t"
      echo "   Remove them from decisions.html, or restore the matching **T# ·** bullet in README."; } >&2
    fail=1
  fi
elif [ -f README.md ] && grep -qE '\*\*T[0-9]+ ' README.md; then
  { echo "BLOCK · README defines trade-off T#(s) but pages/decisions.html is missing — the site can't mirror them (§23)."; } >&2
  fail=1
fi

if [ "$fail" -ne 0 ]; then
  echo "" >&2
  echo "^ Fix the BLOCK item(s) and keep editing (don't restart). Guardrail: .claude/hooks/validate-sync.sh" >&2
  exit 2
fi

# Quiet as a hook (stdout is piped); informative when run by hand in a terminal.
if [ -t 1 ]; then
  n="$(printf '%s\n' "$routes" | grep -c .)"
  echo "web-builder guardrails OK · docs: ${n} routes == ${n} pages · no stray <style> · app.js parses · skill: SKILL.md + references + catalog<->CSS + CSS braces + scope==NAV-groups + §-refs resolve & overview indexes & principles renders §1..§${maxp:-?} + README trade-offs (T#) mirrored on #/decisions coherent."
fi
exit 0

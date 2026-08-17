#!/usr/bin/env bash
# =============================================================================
# web-builder — forward tests for the AI-native architecture capability
# -----------------------------------------------------------------------------
# Proves the model behaves as specified across the required scenarios. Run
# standalone (bash tests/forward-tests.sh) or folded into the commit gate
# (scripts/verify.sh runs it if present). Fast, deterministic, no side effects
# on the repo. Exit 0 = all pass; non-zero = a scenario regressed.
#
# Coverage map (FT1..FT16). A few scenarios are verified OUT-OF-BAND and noted:
#   FT15 real-stale-detection — demonstrated by scripts/verify-package.sh on the
#        actual artifact (release flow); here we prove the REJECT path is live.
#   FT16 byte-level protected-file check — done via the SHA-256 baseline during
#        the upgrade; here we assert the component SURFACE is intact.
# =============================================================================
set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT" || exit 1

pass=0; fail=0
ok()   { pass=$((pass+1)); printf '  PASS  %s\n' "$1"; }
bad()  { fail=$((fail+1)); printf '  FAIL  %s\n' "$1"; }
CP="bash scripts/classify-project.sh"
CPR="bash scripts/classify-problem.sh"

result_of() { printf '%s\n' "$1" | awk -F': ' '/^RESULT:/{print $2; exit}'; }
migrate_of(){ printf '%s\n' "$1" | awk -F': ' '/^MIGRATE:/{print $2; exit}'; }

echo "== Project complexity gate (FT1–FT9 + FT17/FT18 doc-vs-classifier parity) =="
for j in tests/fixtures/project/*.json; do
  exp="$(python3 -c "import json;print(json.load(open('$j')).get('expect',''))")"
  expm="$(python3 -c "import json;print(json.load(open('$j')).get('expect_migrate',''))")"
  out="$($CP "$j" 2>&1)"; got="$(result_of "$out")"; gm="$(migrate_of "$out")"
  label="$(basename "$j") → $got${expm:+ (migrate=$gm)}"
  if [ "$got" = "$exp" ] && { [ -z "$expm" ] || [ "$gm" = "$expm" ]; }; then ok "$label"; else bad "$label (expected $exp${expm:+/migrate=$expm})"; fi
done

echo "== Local vs upstream routing (FT12–FT13 + upstream path) =="
for j in tests/fixtures/problem/*.json; do
  exp="$(python3 -c "import json;print(json.load(open('$j')).get('expect',''))")"
  got="$(result_of "$($CPR "$j" 2>&1)")"
  label="$(basename "$j") → $got"
  [ "$got" = "$exp" ] && ok "$label" || bad "$label (expected $exp)"
done

echo "== Invocation boundary (FT10 routine=no-WB · FT11 major=WB) =="
S="web-builder/SKILL.md"; PP="web-builder/references/project-protocol.md"
# Assert on the FLATTENED text: these are prose properties, so re-wrapping a paragraph
# must not fail the test (it did once — a line break landed mid-phrase and the literal
# grep reported the boundary rule "missing" when the rule was intact).
flat() { tr '\n' ' ' < "$1" | tr -s ' '; }
S_FLAT="$(flat "$S")"
has() { printf '%s' "$1" | grep -qF "$2"; }
has "$S_FLAT" "Routine work does" && ok "FT10 SKILL.md: routine work does not need Web Builder" || bad "FT10 SKILL.md routine-no-WB missing"
grep -q "copy/content edits" "$PP" && ok "FT10 project-protocol: routine work list present" || bad "FT10 project-protocol routine list missing"
has "$S_FLAT" "screen flow" && ok "FT11 SKILL.md: major screen flow / capability -> Web Builder" || bad "FT11 SKILL.md major-capability trigger missing"
grep -q "screen flow or a large capability" "$PP" && ok "FT11 project-protocol: major-capability trigger present" || bad "FT11 project-protocol major trigger missing"

echo "== Level-0 vs Level-2 contrast (FT1/FT4 structural) =="
L0=tests/examples/level0-landing; L2=tests/examples/level2-course
n_html="$(find "$L0" -maxdepth 1 -name '*.html' | grep -c .)"
[ "$n_html" -eq 1 ] && ok "L0 example is a single .html file" || bad "L0 example should be one .html (found $n_html)"
[ ! -d "$L0/.agent" ] && ok "L0 example has NO .agent/ (no architecture ceremony)" || bad "L0 example must not carry .agent/"
grep -q 'web-builder.css' "$L0/index.html" && ok "L0 example links web-builder.css (design system only)" || bad "L0 example must link web-builder.css"

echo "== Level-2 downstream contract (FT7 + FT14 decision/handoff persistence) =="
[ -f "$L2/AGENTS.md" ] && ok "L2 example has AGENTS.md (discovery map)" || bad "L2 example missing AGENTS.md"
[ -f "$L2/content/manifest.json" ] && ok "L2 example has a content manifest (source of truth)" || bad "L2 example missing content manifest"
ls "$L2"/.agent/decisions/*.md >/dev/null 2>&1 && ok "L2 example records a decision (ADR)" || bad "L2 example missing a decision record"
[ -f "$L2/.agent/handoff.md" ] && ok "L2 example has a handoff snapshot" || bad "L2 example missing handoff"
# FT14: a resuming session must NOT re-ask — the decision is settled and the handoff points to the next step.
dfile="$(ls "$L2"/.agent/decisions/*.md 2>/dev/null | head -1)"
{ [ -n "$dfile" ] && grep -qi 'accepted' "$dfile" && grep -qi 'Decided by' "$dfile"; } \
  && ok "FT14 decision is durable (accepted + decided-by) — not re-litigated next session" || bad "FT14 decision not durable"
{ grep -qi 'Next concrete step' "$L2/.agent/handoff.md" && grep -qi 'Do NOT re-decide' "$L2/.agent/handoff.md"; } \
  && ok "FT14 handoff carries next-step + do-not-re-decide (resume without re-asking)" || bad "FT14 handoff missing resume cues"

echo "== Package integrity (FT15 reject path) =="
if command -v zip >/dev/null 2>&1 && command -v unzip >/dev/null 2>&1; then
  TMP="$(mktemp -d "${TMPDIR:-/tmp}/wb-ft.XXXXXX")"
  printf 'junk' > "$TMP/not-a-skill.txt"
  ( cd "$TMP" && zip -q -0 bad.skill not-a-skill.txt )
  if bash scripts/verify-package.sh "$TMP/bad.skill" >/dev/null 2>&1; then
    bad "FT15 verify-package accepted a non-conforming artifact (should reject)"
  else
    ok "FT15 verify-package rejects a non-conforming/stale artifact"
  fi
  rm -rf "$TMP"
else
  ok "FT15 skipped (no zip/unzip) — real stale-detection proven in release flow"
fi

echo "== Component surface intact (FT16 smoke; byte-level via checksum baseline) =="
tpl="$(ls web-builder/assets/templates/*.html 2>/dev/null | grep -c .)"
[ "$tpl" -eq 7 ] && ok "7 templates present (dashboard·list·form·detail·settings·auth·landing)" || bad "template count drifted (found $tpl, expected 7)"
grep -q -- '--wb-version' web-builder/assets/web-builder.css && ok "web-builder.css carries --wb-version" || bad "web-builder.css missing --wb-version"
sel="$(grep -oE '\.wb-[a-z0-9-]+' web-builder/assets/web-builder.css | sort -u | grep -c .)"
[ "$sel" -ge 200 ] && ok "web-builder.css component surface intact ($sel unique wb-* selectors)" || bad "wb-* selector count suspiciously low ($sel)"

echo ""
echo "forward-tests: $pass passed, $fail failed"
[ "$fail" -eq 0 ] || exit 1
exit 0

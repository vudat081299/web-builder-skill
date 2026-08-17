#!/usr/bin/env bash
# =============================================================================
# web-builder — local vs upstream problem classifier
# -----------------------------------------------------------------------------
# A DETERMINISTIC read of web-builder/references/problem-routing.md: given the
# evidence from a minimal reproduction, route a downstream finding to a class.
# It never edits any repo — routing a finding upstream means REPORTING it.
#
# Input: a JSON file of evidence (see tests/fixtures/problem).
# Output: RESULT (skill-bug | project-local | upstream-candidate |
#         skill-integration | needs-triage) + reason.
#
# Usage:  bash scripts/classify-problem.sh <fixture.json>
#         bash scripts/classify-problem.sh --classes    # emittable set, for CHECK 22
# =============================================================================
set -uo pipefail

# --- THE CLASS REGISTRY ------------------------------------------------------
# Every class problem-routing.md's table declares must be REACHABLE here, or the
# reference promises a routing outcome the code can never produce. That drifted:
# `project-architecture` was in the doc's table with nothing to emit it, so an
# architecture-forced workaround fell through to `needs-triage` ("not enough
# evidence") when the evidence was complete. CHECK 22 in scripts/verify.sh diffs
# this list against the doc's table, both ways.
CLASSES='skill-bug
project-local
upstream-candidate
skill-integration
project-architecture
needs-triage'

if [ "${1:-}" = "--classes" ]; then printf '%s\n' "$CLASSES"; exit 0; fi

f="${1:-}"
[ -n "$f" ] && [ -f "$f" ] || { echo "usage: classify-problem.sh <fixture.json> | --classes" >&2; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "ERROR: python3 required" >&2; exit 1; }

python3 - "$f" <<'PY'
import json, sys
d = json.load(open(sys.argv[1], encoding="utf-8"))
def g(k): return bool(d.get(k, False))

repro   = g("reproduces_on_shipped")       # stock wb-* + latest CSS, no custom code
vanish  = g("disappears_without_custom")   # remove project CSS/JS -> symptom gone
biz     = g("is_business_rule")            # business rule / content / data / branding
reuse   = g("is_reusable_primitive")       # a primitive/pattern many projects want
integ   = g("is_framework_integration")    # broad framework-integration gap
arch    = g("is_architecture_workaround")  # forced by THIS project's architecture

if repro:
    res, why = "skill-bug", "reproduces on the latest shipped web-builder.css/template with no custom code -> the library is wrong. REPORT upstream."
elif vanish or biz:
    res, why = "project-local", "vanishes without the project's custom code, or it's a project-specific business rule/content/branding -> fix locally."
elif arch:
    # Before `reuse`: the evidence says the constraint is THIS project's shape, not a
    # gap in the library, so it must not be reported upstream as a missing primitive.
    res, why = "project-architecture", "a workaround forced by this project's own architecture, not by the library -> solve it locally (consider /wb-architect if the structure itself is the problem)."
elif reuse:
    res, why = "upstream-candidate", "a reusable primitive/pattern the library lacks -> REPORT upstream; keep a local version meanwhile."
elif integ:
    res, why = "skill-integration", "a broadly-applicable framework-integration gap -> REPORT upstream with the fix."
else:
    res, why = "needs-triage", "not enough evidence yet -> reduce with a minimal repro before classifying."

print(f"RESULT: {res}")
name = d.get("name")
if name: print(f"finding: {name}")
print(f"  - {why}")
if res in ("skill-bug", "upstream-candidate", "skill-integration"):
    print("  - action: emit the WEB-BUILDER UPSTREAM REQUIRED block (see problem-routing.md); do NOT auto-edit the upstream repo.")
PY

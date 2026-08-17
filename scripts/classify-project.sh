#!/usr/bin/env bash
# =============================================================================
# web-builder — project complexity classifier (the Level 0/1/2 gate, in code)
# -----------------------------------------------------------------------------
# A DETERMINISTIC read of the complexity gate in
# web-builder/references/project-architecture.md (§ The complexity gate). It is
# an AID for the clear-cut signals and a way to keep the gate TESTABLE — NOT a
# rigid law. The agent still applies judgment; size alone never forces a split.
#
# Input: a JSON file describing a project's signals (see tests/fixtures/project).
# Output: RESULT (L0 | L0-cohesive | L1 | L2), optional MIGRATE hint, + reasons.
#
# Usage:  bash scripts/classify-project.sh <fixture.json>
# =============================================================================
set -uo pipefail
f="${1:-}"
[ -n "$f" ] && [ -f "$f" ] || { echo "usage: classify-project.sh <fixture.json>" >&2; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "ERROR: python3 required" >&2; exit 1; }

python3 - "$f" <<'PY'
import json, sys
d = json.load(open(sys.argv[1], encoding="utf-8"))
def g(k, dv=False): return d.get(k, dv)

routes   = int(g("routes", 1))
loc      = int(g("loc", 0))
kb       = int(g("kb", 0))
behav    = int(g("behaviors", 0))
backend  = bool(g("backend_api"))
auth     = bool(g("auth"))
db       = bool(g("database"))
router   = bool(g("router"))
build    = bool(g("build"))
ssr      = bool(g("ssr"))
units    = bool(g("content_units"))          # many independently-updated units
state    = bool(g("complex_state"))
maint    = bool(g("recurring_maintenance"))
multi    = bool(g("multi_contributor"))
cohesive = bool(g("cohesive", True))
lag      = bool(g("tool_lag"))

reasons = []

l0_ok = (routes <= 1 and behav <= 3 and not backend and not auth and not db
         and not router and not build and not ssr and not units and not state
         and not maint and loc <= 1000 and kb <= 100)

structural = (routes > 1 or backend or auth or db or router or build or ssr
              or units or state or maint or multi or behav > 3)

result = None; migrate = False

if l0_ok:
    result = "L0"
    reasons.append("all fast-path conditions hold: one page, small, no backend/auth/db, no router/build/ssr, no independent units, simple state.")
elif not structural and (loc > 1000 or kb > 100) and cohesive and not lag:
    result = "L0-cohesive"
    reasons.append(f"over the fast-path size heuristic (loc={loc}, kb={kb}) but ONE cohesive body with no structural signals — keep one file; EVALUATE before splitting, size alone is not a reason.")
else:
    # escalate — L1 (compact long-lived) vs L2 (structured/complex)
    l2 = (units or (backend and state) or behav > 3 or multi or db
          or (loc >= 5000 and (units or maint)))
    result = "L2" if l2 else "L1"
    trg = []
    if routes > 1: trg.append("multiple routes")
    if backend: trg.append("backend/API")
    if auth: trg.append("auth")
    if db: trg.append("database")
    if router or build or ssr: trg.append("router/build/SSR")
    if units: trg.append("many independently-updated content units")
    if state: trg.append("complex state/persistence")
    if maint: trg.append("recurring maintenance across sessions")
    if multi: trg.append("multiple contributors/handoff")
    if behav > 3: trg.append(f"{behav} independent behaviours")
    reasons.append("not Level 0 — signals: " + ", ".join(trg) + ".")
    if result == "L2":
        reasons.append("Level 2: independently-changing units / real data+state / many features / handoff — needs ownership map + verification (AGENTS.md, and .agent/ only as needed).")
    else:
        reasons.append("Level 1: long-lived but still small — a short AGENTS.md + existing verify commands usually suffice; don't create multi-file .agent/ if one file answers where-to-edit.")

# Big single-file monolith with many units / tool lag -> incremental migration
if loc > 1000 and (units or lag) and routes <= 1:
    migrate = True
    reasons.append("MIGRATION: large single file with independent units/tool-lag -> migrate INCREMENTALLY (baseline -> extract content -> styling -> behaviour -> routes last), never big-bang. See large-static-sites.md.")

print(f"RESULT: {result}")
print(f"MIGRATE: {'incremental' if migrate else 'no'}")
name = d.get("name")
if name: print(f"project: {name}")
for r in reasons:
    print(f"  - {r}")
PY

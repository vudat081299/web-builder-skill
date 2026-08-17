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
#         bash scripts/classify-project.sh --signals   # the registry, for CHECK 21
# =============================================================================
set -uo pipefail

# --- THE SIGNAL REGISTRY -----------------------------------------------------
# The doc is prose and this is code, so nothing stopped them from disagreeing —
# and they did: `multi_contributor` and `tool_lag` were named in the reference as
# "stop being Level 0" signals while l0_ok never gated on them, so a one-page site
# with a handoff need classified L0. Every signal is declared ONCE here, as
#   <json key>|<python var in this script>|<phrase that must appear in the doc>
# and CHECK 21 in scripts/verify.sh proves, for each row, that l0_ok really gates
# on the var AND that the reference really names the signal. Add an input to this
# classifier -> add a row here, gate l0_ok on it, and say so in the reference; any
# one of the three missing is a blocked commit, not a silent divergence.
#
# `cohesive` is deliberately absent: it is the one INVERTED input (cohesive=true is
# the healthy state), so it belongs to the L0-cohesive branch, not to l0_ok.
SIGNALS='routes|routes|More than one route
backend_api|backend|backend
auth|auth|authentication
database|db|database
router|router|client router
build|build|build pipeline
ssr|ssr|server rendering
content_units|units|updated independently
complex_state|state|complex state
recurring_maintenance|maint|across many sessions
multi_contributor|multi|who will need a handoff
tool_lag|lag|starts to lag
behaviors|behav|feature behaviours that change independently'

if [ "${1:-}" = "--signals" ]; then printf '%s\n' "$SIGNALS"; exit 0; fi

f="${1:-}"
[ -n "$f" ] && [ -f "$f" ] || { echo "usage: classify-project.sh <fixture.json> | --signals" >&2; exit 1; }
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

# Every "when it stops being Level 0" signal in project-architecture.md must appear
# here, or the classifier contradicts the doc it encodes. `multi` (a contributor who
# needs a handoff) and `lag` (tooling struggling with the file) were missing once —
# a one-page site with a handoff need classified L0 while the doc called it a
# stop-Level-0 signal. Keep this list and the doc's list in lockstep.
l0_ok = (routes <= 1 and behav <= 3 and not backend and not auth and not db
         and not router and not build and not ssr and not units and not state
         and not maint and not multi and not lag and loc <= 1000 and kb <= 100)

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
    # "One signal != maximal architecture — pick the smallest level that solves the real
    # need" (project-architecture.md § When it stops being Level 0). So a lone handoff
    # need does NOT buy Level 2: Level 1's one short AGENTS.md IS the handoff artifact
    # for a compact project. `multi` escalates to L2 only alongside another force.
    l2 = (units or (backend and state) or behav > 3 or db
          or (multi and (maint or routes > 1 or loc > 1000))
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
    if lag: trg.append("tooling lagging on the file")
    # `trg` is empty in exactly one case: no structural signal, but the body is over the
    # size heuristic AND not cohesive — i.e. one file mixing responsibilities. That is
    # decomposition evidence (§ File decomposition), not a fast path, and it must not be
    # reported as "no signals" or described as small.
    if trg:
        reasons.append("not Level 0 — signals: " + ", ".join(trg) + ".")
    else:
        reasons.append(f"no structural signal, but the single body is over the fast-path heuristic (loc={loc}, kb={kb}) and NOT cohesive — one file mixing responsibilities is split evidence (§ File decomposition), not a fast path.")
    if result == "L2":
        reasons.append("Level 2: independently-changing units / real data+state / many features / handoff — needs ownership map + verification (AGENTS.md, and .agent/ only as needed).")
    elif trg:
        reasons.append("Level 1: long-lived but still small — a short AGENTS.md + existing verify commands usually suffice; don't create multi-file .agent/ if one file answers where-to-edit.")
    else:
        reasons.append("Level 1: the project stays compact (a short AGENTS.md is usually enough) — the work here is decomposing the file by RESPONSIBILITY, not adding project scaffolding.")

# Big single file that must be broken up gradually -> incremental migration.
# Non-cohesive counts alongside units/lag: a large body mixing responsibilities is the
# large-static-sites.md case even when nothing else structural is flagged.
if loc > 1000 and (units or lag or not cohesive) and routes <= 1:
    migrate = True
    why = []
    if units: why.append("independently-updated units")
    if lag: why.append("tooling lag")
    if not cohesive: why.append("mixed responsibilities in one body")
    reasons.append("MIGRATION: large single file (" + ", ".join(why) + ") -> migrate INCREMENTALLY (baseline -> extract content -> styling -> behaviour -> routes last), never big-bang. See large-static-sites.md.")

print(f"RESULT: {result}")
print(f"MIGRATE: {'incremental' if migrate else 'no'}")
name = d.get("name")
if name: print(f"project: {name}")
for r in reasons:
    print(f"  - {r}")
PY

# Project protocol — the contract a build leaves behind

When Web Builder creates or grows a Level 1/2 project, it leaves a **contract** so a *routine* agent can keep
working **without loading Web Builder every time.** The contract is a small set of durable facts, not a copy
of this skill. Level 0 needs none of it.

> **Principle:** downstream independence. A routine content edit, data update, or small local fix should be
> answerable from the project's own `AGENTS.md` — the agent should not need Web Builder at all. Web Builder is
> for *major* UI/architecture/upstream work (see the invocation boundary below).

## Table of contents

- [What the contract must let a routine agent find](#what-the-contract-must-let-a-routine-agent-find)
- [AGENTS.md — the entrypoint](#agentsmd--the-entrypoint)
- [.agent/ — state, created only on need](#agent--state-created-only-on-need)
- [When to create decision / learning / task / handoff](#when-to-create-decision--learning--task--handoff)
- [Invocation boundary (downstream)](#invocation-boundary-downstream)
- [Working inside an existing project](#working-inside-an-existing-project)
- [What NOT to do](#what-not-to-do)

## What the contract must let a routine agent find

For a Level 1/2 project, an agent arriving cold must be able to find:

- **Project purpose** — what this is.
- **Agent entrypoint** — where to start (this file: `AGENTS.md`).
- **Architecture / ownership map** — what each part does and where an edit goes.
- **Source-of-truth locations** — content, data, config, domain rules.
- **Commands & verification** — how to run, build, test, verify.
- **Decisions / handoff** — if any exist.
- **Local conventions & component-reuse policy** — how this project uses the design system / local components.
- **Local vs upstream routing** — where a finding goes (`problem-routing.md`).
- **When Web Builder is *not* needed, and when to call it back.**

Physical paths are the project's own choice; the **contract is semantic** (`project-architecture.md` — *The architecture model*).

## AGENTS.md — the entrypoint

One short file at the project root. Keep it a **map, not a manual** — link to real files, don't restate them.
A compact template:

```markdown
# <Project> — agent guide

**What this is.** <one or two sentences>. Complexity level: <0|1|2>.

## Where things live
- UI / shell: <path> (built with the web-builder design system — reuse wb-* + local components)
- Content / source of truth: <path(s)>
- Behaviour / features: <path(s)>
- State / data / API: <path(s)>

## Run & verify
- Dev: `<command>`
- Build: `<command>`
- Verify: `<command>`  # what "working" means for this project

## Conventions
- Reuse local components first; styling comes from the design system (no hand-rolled CSS).
- <locale / a11y / naming rules specific to this project>

## Decisions & state
- Durable decisions: docs/decisions/ (if present)
- Handoff / active work: .agent/ (if present)

## Web Builder boundary
- Routine work here (content, data, small fixes, local reuse) does NOT need Web Builder.
- Call Web Builder back for: major UI/screens, architecture/restructure, a suspected shipped-component bug
  (see problem-routing).

## Selected / omitted capabilities   # Level 2, or Level 1 where it earns its keep
- In: <capabilities>
- Out (on purpose): <capability> — <why>; add when <trigger>.
- Split/restructure when: <trigger>.
```

At **Level 1**, most of this is two or three lines each; the "capabilities" block is often unnecessary. At
**Level 2**, the capability and evolution notes (`project-architecture.md` — *Evolution rules*) earn their place.

## .agent/ — state, created only on need

`.agent/` holds durable *working state* that outlives a session. Create a subfile **only when a real need
exists** — never as scaffolding:

- `.agent/decisions/` — ADR-style records (see triggers below).
- `.agent/handoff.md` — a resume snapshot (see below).
- `.agent/tasks.md` — active multi-session work.
- `.agent/learnings/` — reusable root-cause/solution notes.

If a single `AGENTS.md` already answers "where do I edit and how do I verify," **don't create `.agent/` at
all** (that's the Level 1 default).

## When to create decision / learning / task / handoff

Create these **only** on a real trigger — they are cheap to read and expensive to rot, so an empty or
speculative one is worse than none:

- **Decision (ADR)** — the choice is **durable**, had **several reasonable options**, or was the **user's
  call**. Record: context, the options, what was chosen, why, and what would reverse it. *Don't* record
  obvious or easily-reversible choices.
- **Learning** — a root cause + solution that is **likely to recur**. Record the symptom, the cause, and the
  fix so the next occurrence is fast. *Don't* log one-off trivia.
- **Active work (task)** — work that **spans multiple sessions**. Keep it current; delete when done.
- **Handoff** — a **resume snapshot**: current state, what's in flight, the next concrete step. It is **not** a
  backlog, a research archive, or a changelog. Keep it short and truthful; overwrite it as state moves.

## Invocation boundary (downstream)

A routine agent should **do the work directly** for: copy/content edits, lesson/data updates, small local bug
fixes, reusing an existing local component, changing behaviour inside an existing boundary, adding a local
test, resuming from a handoff, and small refactors that don't change the architecture.

It should **bring in Web Builder** for: starting a new site/page, assembling or designing significant UI,
designing/refactoring architecture, adding a screen flow or a large capability, adding UI/a component with no
local equivalent, changing the shell/layout/design system, refactoring a monolith/large site, investigating a
bug that might be upstream, and updating/packaging/releasing Web Builder itself.

## Working inside an existing project

1. Read the local `AGENTS.md` / contract first.
2. Inspect the architecture, framework conventions, and existing components.
3. **Reuse the local solution.**
4. Do **not** restructure just to match a Web Builder profile.
5. Pull in Web Builder architecture context only when the task genuinely exceeds the local boundary.

## What NOT to do

- **Don't copy the whole Web Builder skill** into a downstream repo. Reference it; don't clone it.
- **Don't create a universal tree** or a maximal `.agent/` "to be safe." Structure follows need.
- **Don't duplicate a source of truth** across the contract and the code.
- **Don't leave a stale contract** — a wrong `AGENTS.md` is worse than none. Update it when the shape changes.
- **Don't auto-edit another repository.** A finding that belongs upstream is *reported*, not silently patched
  (`problem-routing.md`).
</content>

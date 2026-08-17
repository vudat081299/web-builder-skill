# Project architecture — choosing and shaping how a web build is organized

Web Builder makes the **UI** beautiful and consistent (`SKILL.md` + the component catalog). This file is
the *other* half: **how the project itself is organized** so a coding agent can keep maintaining it. It is
an **adaptive capability, not a mandatory output** — most builds are small and need *none* of it.

> **Read the complexity gate first, then stop if the answer is Level 0.** The single most common mistake this
> file exists to prevent is wrapping a 200-line landing page in folders, ADRs, and a handoff protocol it will
> never use. Architecture you don't need is not "future-proofing" — it is friction the next agent pays for on
> every edit. Spend structure the way the design system spends colour: the lowest level that does the job.

## Table of contents

1. [The complexity gate](#1-the-complexity-gate) — run this **before** any architecture thinking
   - [Level 0 — one-file fast path](#level-0--one-file-fast-path) (the default)
   - [When it stops being Level 0](#when-it-stops-being-level-0)
   - [Level 1 — compact long-lived project](#level-1--compact-long-lived-project)
   - [Level 2 — structured / complex project](#level-2--structured--complex-project)
2. [The architecture model](#2-the-architecture-model) — constraint-based synthesis, not a universal tree
3. [Synthesis workflow](#3-synthesis-workflow) — the numbered steps for Level 1/2
4. [Capability vocabulary](#4-capability-vocabulary) — the axes to reason about (not a folder list)
5. [Patterns](#5-patterns) — problem → structure, with trade-offs and evolution
6. [File decomposition](#6-file-decomposition) — size is a signal, not a rule
7. [Evolution rules](#7-evolution-rules) — what a significant architecture records
8. [How architecture is judged](#8-how-architecture-is-judged)
9. [Where to go next](#9-where-to-go-next)

Sibling references (load only the one you need): `site-profiles.md` (priors per site type),
`learning-sites.md` (the deep profile), `large-static-sites.md` (the big-monolith case),
`project-protocol.md` (the downstream contract an agent leaves behind), `problem-routing.md`
(local-vs-upstream triage), `verification.md` (how to prove a build works). This file is the hub; each
sibling is one topic. In a large file, `rg -n "^## "` lists the sections.

---

## 1. The complexity gate

Every build starts here. The gate answers one question: **how much project organization does this actually
need?** Answer it from the request + the existing repo, in seconds, before writing structure.

### Level 0 — one-file fast path

**Default to a single authored source file `index.html`** (HTML + CSS-via-`<link>` to `web-builder.css` +
inline `<script>`) when **all** of these hold:

- **One** route / page.
- Hand-written HTML + CSS + JS is **≤ ~1,000 lines and ≤ ~100 KB** total.
- **≤ 3** small client-side behaviours (menu toggle, theme toggle, simple tabs, light validation).
- **No** backend, authentication, authorization, or database.
- **No** client router, build pipeline, or server rendering.
- **No** collection of many lessons / articles / records updated independently.
- **No** complex state or persistence.
- **Not** expected to grow through repeated feature/content work across many sessions.
- One agent can **read the whole file in a single pass** and locate any edit with one or two searches.

Binary assets (images, fonts) or one already-present CSS dependency (`web-builder.css` is exactly that) do
**not** cost you Level 0 — the test is *one authored application source file*, not zero dependencies.

**At Level 0, do NOT create:**

- `.agent/`, `AGENTS.md`, or any project contract.
- Architecture docs, an ADR / decision log, a handoff file, or a verification framework.
- Folders "in case it grows later."
- A `css/` + `js/` split done only to *look* architected.

Just ship: **semantic HTML, a beautiful Web-Builder UI, responsive, accessible, and a minimal check that it
renders** (open it, no console errors, the one or two behaviours work). That is the whole deliverable.

> The 1,000-line / 100 KB numbers are a **safe-fast-path heuristic, not a split law.** Under them, staying
> one file is almost always right. Over them, you *evaluate* (below) — you do **not** auto-split. A cohesive
> 10,000-line file can be correct; a 700-line file that tangles layout + content + CSS + state + several
> independent behaviours may already want splitting. Lines measure nothing on their own; **responsibilities
> do** (see *File decomposition* below).

### When it stops being Level 0

Move to architecture assessment when **one or more strong signals** appear:

- More than one route or page.
- A backend / API / auth / database.
- Several feature behaviours that change independently.
- Content made of many units authored/updated on their own (lessons, posts, records).
- Expected periodic updates across many sessions.
- More than one agent/contributor who will need a handoff.
- Source-of-truth, testing, or deployment rules that must be remembered.
- The agent can't reliably predict where an edit goes.
- The IDE/tooling starts to lag on the file.
- A small change routinely forces reading or touching most of the project.

**One signal ≠ maximal architecture.** Pick the **smallest level that solves the real need.** A second page
alone is often still Level 1, not Level 2.

### Level 1 — compact long-lived project

For a project that stays **small but is maintained regularly.** Prefer:

- A small source tree that follows the framework's existing convention (don't invent one).
- **One short `AGENTS.md`** as the discovery map (purpose · where things live · how to run/verify · reuse
  policy). See `project-protocol.md`.
- A README or a short architecture note *only if* something isn't obvious from the tree.
- The project's existing verification commands.
- **No** multi-file `.agent/` if a single `AGENTS.md` already answers "where do I edit and how do I check it."

### Level 2 — structured / complex project

Only when there are genuinely **multiple independently-changing units**, many sessions, many features, a
non-trivial source-of-truth, real API/state/persistence, or a clear handoff need. You *may* use:

- `AGENTS.md` (still the entrypoint).
- `.agent/` (task/handoff/decision/learning state — created per need, see `project-protocol.md`).
- `docs/architecture/` and `docs/decisions/` (ADRs).
- Task / handoff files.
- Scripts / tests fitting the stack.

**Nothing on that list is mandatory just because a project is Level 2.** What *is* mandatory: agent
discoverability, clear ownership of each part, and appropriate verification. Create each artifact when a
real need exists for it — never as a checklist.

---

## 2. The architecture model

**There is no universal application tree.** Do not reach for a remembered folder layout. Synthesize the
structure from the forces in front of you:

```
requirements
  + responsibilities
  + units of change
  + source-of-truth needs
  + framework conventions
  + the current repository
  + runtime / deployment constraints
  + agent discoverability
  + verification needs
  ─────────────────────────────────
  = this project's architecture
```

**Standardize the *semantic discovery contract*, not the physical tree.** Two projects can put files in
completely different places and both be correct, as long as an agent can quickly answer: *what is this, where
does responsibility X live, what is the source of truth, how do I run and verify it.* That set of answers —
not a canonical directory layout — is what Web Builder standardizes. The contract lives in `AGENTS.md`
(`project-protocol.md`); the physical paths are whatever the framework and the forces above make natural.

The knowledge you apply here has four layers, each with its own home:

- **Vocabulary** — the capability axes to reason across (*Capability vocabulary* below).
- **Patterns** — reusable problem→structure moves with trade-offs (*Patterns* below).
- **Profiles** — starting priors per site type (`site-profiles.md`; the deepest is `learning-sites.md`).
- **Evolution rules** — what to record and what triggers a change (*Evolution rules* below).

---

## 3. Synthesis workflow

For Level 1/2 (skip entirely for Level 0):

1. **Inspect** the prompt, the repository, and any local instructions (`AGENTS.md`, framework config).
2. **Identify the project type** and your confidence in it (consult `site-profiles.md`).
3. **List the responsibilities** and the **units that change independently.**
4. **Locate the source(s) of truth** (content, data, config, domain rules).
5. **Trace data / dependency flow** (who reads whom; where remote data enters).
6. **Keep** any framework / runtime / deployment convention that already fits — do not fight the stack.
7. **Assess** context locality, discoverability, and verification.
8. **Choose patterns** (*Patterns* below) that match the forces.
9. **Consult the nearest profile** as a prior — but you are *not* bound by it; synthesizing a new tree is
   normal when no profile fits.
10. **Produce a concrete, minimal tree** — the smallest structure that carries the responsibilities.
11. **Explain** the purpose and ownership of each boundary that isn't self-evident.
12. **Record** intentionally-omitted capabilities and evolution triggers **when they have durable value**.
13. **Record a durable decision only when forgetting it would cause rework** (see `project-protocol.md`).

**Ask the user only when** the missing information (a) can't be inferred from prompt or repo, (b) materially
changes the architecture, and (c) guessing wrong causes large rework. Otherwise pick the sensible default,
state it, and proceed. Don't force every output into a table or a separate document — inline it in `AGENTS.md`
when that's clear enough.

---

## 4. Capability vocabulary

Reason about a project as a set of **capabilities**, each of which may be present, absent, or deferred. This
is a thinking checklist — **not** a list of folders to create.

| Capability | The question it answers |
|---|---|
| Shell / layout / components | What frames every screen? (Web Builder owns this — `wb-shell`, scaffold, `wb-*`.) |
| Content | Where does prose/copy live, and who edits it? |
| Structured content | Are there many like-shaped units (lessons, posts, products)? Where's the manifest? |
| Routing / navigation | One page, hash routes, a real router, or file-based routes? |
| Feature behaviour | What interactive features exist, and do they change independently? |
| State / persistence | Ephemeral, `localStorage`, IndexedDB, server-synced? |
| API / remote data | What's fetched, from where, and how is failure handled? |
| Domain logic | Are there business rules worth isolating from UI? |
| Auth | Who signs in; what's gated? (Forces ≥ Level 1 — never Level 0.) |
| Forms / validation | Input shape, validation, submission, error surface. |
| Search / filter | Client-side over a manifest, or server-backed? |
| SEO / prerendering | Does it need crawlable HTML / meta / sitemap? |
| Offline / PWA | Must it work offline or install? |
| Localization | One locale or many? (Copy is data — see design-principles §20.) |
| Analytics | What's measured, and where does it load? |
| Media / charts | Images, video, data-viz (Web Builder ships chart primitives). |
| Testing / deployment | How is correctness proven and how does it ship? |
| Documentation / migration / version compatibility | What must a future agent be told; how do versions coexist? |

For each: is it **needed now**, **omitted on purpose**, or **deferred with a trigger**? The answers drive the
tree — and the omissions are worth recording at Level 2 (*Evolution rules* below).

---

## 5. Patterns

Each pattern is a **problem → structure** move. Apply the ones whose *context* matches; skip the rest. Format:
**Problem · Context · Use when · Avoid when · Structure · Trade-offs · Verification · Evolution.**

### Static shell
- **Problem:** every screen repeats the same frame.
- **Context / use when:** any multi-screen site. **Avoid when:** single page (inline it).
- **Structure:** one shell built from `wb-shell` + slots; screens fill `__main`. Start from
  `assets/templates/*.html`.
- **Trade-offs:** one place to change the frame vs a tiny indirection.
- **Verification:** the frame is identical across screens; only `__main` differs.
- **Evolution:** grows into a layout component when the framework has one.

### External content
- **Problem:** prose/data is edited far more often than layout, and by different hands.
- **Use when:** content changes on its own cadence. **Avoid when:** a paragraph or two that never moves.
- **Structure:** content in its own files (`.md`/`.json`/CMS); the view renders it. Content is a source of
  truth, not markup.
- **Trade-offs:** a render step vs content edits that never risk the layout.
- **Verification:** editing content touches no view file, and vice versa.
- **Evolution:** many units → **content manifest**.

### Content manifest
- **Problem:** many like-shaped units (lessons, posts, products) need listing, ordering, linking, searching.
- **Use when:** a collection grows unit by unit. **Avoid when:** a fixed handful.
- **Structure:** a manifest (index of units + metadata) is the single source of truth; pages derive from it.
  Central to `learning-sites.md`.
- **Trade-offs:** one indirection vs add-a-unit-without-touching-code and free list/search/next-prev.
- **Verification:** adding a unit = one manifest entry + its content file; nothing else edited.
- **Evolution:** manifest → a real data layer / CMS when authoring outgrows a file.

### Feature-based behaviour
- **Problem:** several behaviours change independently and tangle when co-located.
- **Use when:** 3+ independent behaviours, or any that a test would isolate. **Avoid when:** one or two tiny
  toggles (keep inline — Level 0).
- **Structure:** one module per feature, each owning its own DOM wiring; a thin entry initializes them.
- **Trade-offs:** more files vs edit-one-feature-without-reading-the-others.
- **Verification:** each feature testable / disable-able alone.
- **Evolution:** modules → framework components when a framework arrives.

### Domain / data separation
- **Problem:** business rules smeared through UI code can't be tested or reused.
- **Use when:** real rules (money maths, scheduling, validation beyond "required"). **Avoid when:** display-only.
- **Structure:** pure domain functions with no DOM; UI calls them.
- **Trade-offs:** a boundary to cross vs unit-testable rules and reuse across screens.
- **Verification:** domain tests run with no DOM.

### Local persistence
- **Problem:** state must survive reload without a backend.
- **Use when:** user data, drafts, preferences, offline. **Avoid when:** nothing needs to persist.
- **Structure:** one storage adapter (get/set/migrate) wrapping `localStorage`/IndexedDB; the app never
  touches storage directly.
- **Trade-offs:** an adapter vs scattered `localStorage` calls that can't be migrated.
- **Verification:** clear storage → app rebuilds cleanly; a version bump migrates old data.

### API adapter
- **Problem:** remote calls scattered through the UI make failure and change unmanageable.
- **Use when:** any real remote data. **Avoid when:** no backend.
- **Structure:** one module owns fetching, headers, error shape, retries; the UI consumes typed results.
- **Trade-offs:** a layer vs one place to change endpoints and handle failure consistently.
- **Verification:** endpoint/shape changes touch only the adapter; UI shows loading/error/empty states.

### Progressive enhancement
- **Problem:** heavy JS for behaviour that HTML/CSS can do (accordion, tabs, dialog).
- **Use when:** always, as the default. Web Builder is built for it — many components are `<details>` / native
  inputs first. **Avoid when:** genuinely needs JS (drag reorder, live charts).
- **Structure:** semantic HTML works with no JS; JS layers extras on top.
- **Trade-offs:** occasionally more markup vs resilience, a11y, and SSR for free.
- **Verification:** the core still works with JS disabled.

### Server / client boundary
- **Problem:** unclear what renders on the server vs the client (Next/Remix/Astro).
- **Use when:** an SSR/SSG framework is in play. **Avoid when:** a static one-file page.
- **Structure:** follow the framework's boundary (server components / loaders / islands); keep client JS to
  what needs interactivity.
- **Trade-offs:** the framework's rules vs its performance and SEO.
- **Verification:** view source shows real content; client bundle carries only interactive code.

### Import / export boundary
- **Problem:** data crosses the app edge (file upload, CSV/JSON export, share links).
- **Use when:** any user-supplied or user-taken data. **Avoid when:** nothing crosses the edge.
- **Structure:** one parse/serialize boundary that validates on the way in and shapes on the way out; the
  core trusts only validated data.
- **Trade-offs:** a gate to pass vs never trusting unvalidated input.
- **Verification:** malformed input is rejected at the edge, not deep in the app.

---

## 6. File decomposition

> **File size is a diagnostic signal, not an architectural rule. Split by responsibility, unit of change,
> lookup locality, independent testability and tool performance. A cohesive 10,000-line content file may be
> acceptable. A 1,000-line file mixing layout, content, styling and behavior may not be.**

**Split when you have concrete evidence:**

- Mixed responsibilities in one file.
- Unclear ownership (who edits what).
- Poor lookup locality (finding an edit means scanning the whole file).
- IDE / tooling lag.
- Expensive agent context (the file can't be read in a reasonable pass).
- Multiple independent units living together.
- Hard to test a part in isolation.
- Frequent edit conflicts.
- A duplicated source of truth.
- A dependency-direction violation.

**Do NOT split when** the new boundary only creates forwarding files, adds navigation overhead, or
*duplicates a source of truth.* A split that makes you jump between three files to understand one thing is a
regression, not an improvement.

For a large cohesive monolith (e.g. a ~20,000-line single-file site), migration is **incremental**, never a
big-bang rewrite — see `large-static-sites.md` for the step-by-step (baseline → extract independently-changing
content → extract styling → extract behaviour by feature → extract routes last → verify parity after each).

---

## 7. Evolution rules

Every **significant** architecture (Level 2, and Level 1 where it earns its keep) records — briefly, usually
inline in `AGENTS.md`:

- **Selected capabilities** (what's in).
- **Intentionally-omitted capabilities** (what's deliberately out — so the next agent doesn't "fix" a
  non-bug).
- **Why** (the forces that drove the shape).
- **Trigger to add** a deferred capability (the observable condition that flips the decision).
- **Trigger to split / restructure** (from the *File decomposition* evidence list).
- **Which routine tasks do NOT need Web Builder** (content edits, data updates, small local fixes).
- **Which tasks DO need Web Builder back** (major UI, architecture change, a suspected upstream bug).

**Level 0 records none of this.** A one-file page has nothing to remember.

Record a durable decision (an ADR-style note) only when it is durable, had **several reasonable options**, or
was the **user's call** — see `project-protocol.md` for the decision / learning / handoff triggers.

---

## 8. How architecture is judged

A good architecture scores well on:

- **Responsibility clarity** — each part does one thing.
- **Cohesion** — things that change together live together.
- **Predictable ownership** — an agent knows where an edit goes.
- **Lookup locality** — finding code is fast.
- **Minimal duplication** — one source of truth per fact.
- **Testability** — parts can be verified in isolation.
- **Tool / IDE performance** — files open and search fast.
- **Agent context efficiency** — a task reads a slice, not the whole tree.
- **Framework fit** — it goes with the stack, not against it.
- **Evolvability** — the next capability has an obvious home.
- **Right indirection** — enough to separate concerns, not so much that following a path is a maze.

If a proposed structure doesn't beat "one file" on several of these, it isn't worth its indirection.

---

## 9. Where to go next

- Choosing/adapting to a **site type** → `site-profiles.md` (and `learning-sites.md` for the deep one).
- A **big single-file** site or a monolith to migrate → `large-static-sites.md`.
- Leaving a project so a **routine agent** can continue → `project-protocol.md`.
- A bug/finding that might belong **upstream** in Web Builder → `problem-routing.md`.
- **Proving** the build works → `verification.md`.
- The **UI** itself (always) → `SKILL.md` + `components-catalog.md` + `design-principles.md`.
</content>
</invoke>

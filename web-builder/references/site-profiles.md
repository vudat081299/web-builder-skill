# Site profiles — starting priors per site type

A **profile is a prior, not a preset.** It gives you a likely complexity level, the questions worth asking,
the failure modes to watch, and an example minimal tree — so you start from evidence instead of a blank page.
A profile **never overrides** a framework convention that already fits, and never forces structure a project
doesn't need. When no profile fits, **synthesizing a new tree is the normal, expected move** (see
`project-architecture.md` — *The architecture model* + *Synthesis workflow*).

> Run the **complexity gate** (`project-architecture.md` — *The complexity gate*) *first*. The profile only refines the answer;
> it does not replace the gate. Many sites that "sound like" a profile are still Level 0 in practice.

## Table of contents

- [How to use a profile](#how-to-use-a-profile)
- [New site vs existing site vs one-off](#new-site-vs-existing-site-vs-one-off)
- [Landing / marketing](#landing--marketing)
- [Portfolio](#portfolio)
- [Documentation / reference](#documentation--reference)
- [Learning / course / study](#learning--course--study) → deep dive in `learning-sites.md`
- [Dashboard / data visualization](#dashboard--data-visualization)
- [Interactive personal tool](#interactive-personal-tool)
- [CRUD / data app](#crud--data-app)
- [Content-heavy site](#content-heavy-site)
- [Hybrid site](#hybrid-site)
- [No profile fits — synthesize](#no-profile-fits--synthesize)

## How to use a profile

1. Guess the type and your confidence.
2. Run the gate; take the profile's *Typical level* as a prior, not a verdict.
3. Answer the profile's *Questions* from the prompt/repo; ask the user only per `project-architecture.md`'s *Synthesis workflow*.
4. Watch the *Failure modes*.
5. Start from the *Example tree*, then adapt to the real forces.

---

## New site vs existing site vs one-off

- **New site** — you choose the level from the gate. Default to the *lowest* that fits; grow later on a
  trigger (`project-architecture.md` — *Evolution rules*).
- **Existing site** — do **not** impose a profile. First read the local `AGENTS.md`/contract, inspect the
  framework conventions and existing components, and **reuse local solutions.** Only reach for Web Builder
  architecture when the task genuinely exceeds the local boundary (`project-protocol.md`, invocation
  boundary). Never restructure an existing project just to make it look like a Web Builder profile.
- **Small static / one-off page** — almost always **Level 0**. One `index.html`, ship it, no contract.

---

## Landing / marketing

- **Typical level:** 0 (often), 1 if it grows sections/pages or is updated on a cadence.
- **Prior:** one long scrolling page — hero, features, social proof, pricing, CTA, footer. Start from
  `assets/templates/landing.html`.
- **Questions:** one page or several? A/B variants? CMS-driven copy or hardcoded? Needs SEO/OG meta? A form
  that posts somewhere?
- **Failure modes:** over-structuring a single page into a mini-framework; hand-rolling a shell instead of the
  template; burying copy in markup when marketing edits it weekly (→ external content).
- **Example (Level 0):** `index.html` (+ `/assets/` for images). Nothing else.

## Portfolio

- **Typical level:** 0 for a single page; 1 if projects are many and updated over time.
- **Prior:** intro + a grid of work + contact. `wb-grid`, `wb-card`, `wb-media`.
- **Questions:** how many pieces, and how often added? Case-study detail pages or just cards? Any CMS?
- **Failure modes:** a router + build for six static cards (Level 0 suffices); conversely, hardcoding 40
  projects into markup when a manifest would make adds trivial.
- **Example (Level 1 when it grows):** `index.html` + `content/projects.json` (manifest) + a small render
  script; detail pages derived from the manifest.

## Documentation / reference

- **Typical level:** 1–2. Many pages, navigation, search, cross-links; updated continually.
- **Prior:** a **content manifest** (pages + nav order + metadata) is the source of truth; a static shell
  frames every page; search is client-side over the manifest. (This repo's own docs site is an instance.)
- **Questions:** how many docs, and who authors them? Markdown or authored HTML? Versioned docs? Search:
  client-side or a service? Build step acceptable, or must it stay zero-build?
- **Failure modes:** duplicating nav in every page instead of deriving it from the manifest; splitting one
  cohesive reference page across files for LOC reasons (keep it cohesive — `large-static-sites.md`).
- **Example (Level 2):** `shell` + `content/<page>.md|html` + `content/manifest.json` + a render/route layer +
  a search index built from the manifest.

## Learning / course / study

- **Typical level:** 1–2, and the **deepest-invested profile** (~60% of real use) — but **not** the universal
  default. A one-lesson page is still Level 0.
- **Prior:** a **lesson manifest** drives listing, ordering, progress, and next/prev; each lesson is an
  independently-authored content unit; progress persists locally.
- **This profile has its own reference — read `learning-sites.md`** for the full treatment (manifest shape,
  progress model, quiz/interaction patterns, the big-monolith migration, failure modes).

## Dashboard / data visualization

- **Typical level:** 2 (usually). Live/remote data, state, filters, several independent panels.
- **Prior:** an **API adapter** owns data + loading/error/empty; **domain/data separation** keeps transforms
  out of the view; panels are **feature modules**; Web Builder's chart + stat + table primitives render it.
  Start from `assets/templates/dashboard.html`.
- **Questions:** data source and refresh model (poll/websocket/static)? Client or server state? Which
  interactions are independent (filter, drill-down, date range)? Auth?
- **Failure modes:** fetch calls sprayed through panels (→ one adapter); no loading/error/empty states;
  business maths inside chart components (→ domain layer); one giant file mixing all panels.
- **Example (Level 2):** `shell` + `features/<panel>/` + `data/api.js` (adapter) + `domain/<calc>.js` (pure) +
  `state/` (store).

## Interactive personal tool

- **Typical level:** 1–2. A calculator/tracker/editor: real state, local persistence, a few features.
- **Prior:** **local persistence** via one storage adapter; **feature modules** per capability;
  **import/export boundary** if data crosses the edge (backup/restore, share). Often no backend.
- **Questions:** what persists and where (localStorage/IndexedDB)? Import/export? Offline? How many independent
  features? Will it ever sync to a server (defer with a trigger)?
- **Failure modes:** `localStorage` reads/writes scattered everywhere (unmigratable → adapter); one file
  growing past readability as features accrete; premature backend.
- **Example (Level 1→2):** `index.html`/`shell` + `features/<feature>.js` + `store/persist.js` (adapter) +
  `io/import-export.js`.

## CRUD / data app

- **Typical level:** 2. Records with create/read/update/delete, forms, validation, lists, auth.
- **Prior:** **API adapter** + **domain** + **forms/validation** + list/detail/form screens from templates
  (`list.html`, `detail.html`, `form.html`). Auth forces ≥ Level 1 (never Level 0).
- **Questions:** entities and relationships? Server or local? Optimistic updates? Validation rules (domain vs
  field)? Roles/permissions?
- **Failure modes:** validation logic duplicated between form and server view (→ shared domain); no
  loading/error states; list + form + detail crammed into one module.
- **Example (Level 2):** `shell` + `features/<entity>/{list,form,detail}.js` + `data/api.js` +
  `domain/<entity>.js` + `auth/`.

## Content-heavy site

- **Typical level:** 1–2. Blog/magazine/knowledge base: many articles, taxonomy, feeds, SEO.
- **Prior:** **external content** + a **manifest** (articles + taxonomy) as source of truth; a static shell;
  SEO/prerendering matters, so favor SSG or crawlable HTML.
- **Questions:** authoring workflow (Markdown/CMS)? How many articles and growth rate? Taxonomy/related posts?
  RSS? SEO requirements? Build step acceptable?
- **Failure modes:** treating each article as a hand-built page (→ manifest + template); SPA-only rendering
  where SEO needs server HTML.
- **Example (Level 2):** `content/posts/*.md` + `content/manifest.json` + `templates/` + a build/render step +
  feeds derived from the manifest.

## Hybrid site

- **Typical level:** 2, occasionally 1. Combines profiles — e.g. marketing + docs + app, or content +
  dashboard.
- **Prior:** treat each area as its own sub-profile with a clear boundary between them; share only the shell
  and the design system. Don't force one architecture across areas that change on different cadences.
- **Questions:** what are the distinct areas, and how independent are they? Shared auth/nav? One deploy or
  several? Which area carries the most change?
- **Failure modes:** one uniform structure imposed across areas with very different needs; or the opposite —
  three disconnected mini-apps with no shared shell/design system.
- **Example (Level 2):** `shell` (shared) + `areas/marketing/` + `areas/docs/` + `areas/app/`, each internally
  shaped by its own sub-profile.

---

## No profile fits — synthesize

If the site doesn't match a profile, that is **not** a problem to force-fit. Go straight to constraint-based
synthesis (`project-architecture.md` — *The architecture model* + *Synthesis workflow*): list responsibilities
and units of change, find the sources of truth, trace data flow, keep the framework's conventions, choose
patterns (*Patterns*), and produce the smallest tree
that carries the load. Record it in `AGENTS.md` with the omitted capabilities and evolution triggers
(`project-protocol.md`). A synthesized architecture that fits the real forces beats any profile applied by
reflex.

# Learning sites — the deep profile

Learning / course / study sites are the **most common** thing built with this skill (~60% of real use), so
this profile is the most developed. That frequency is **not** a reason to make it the default — a
single-lesson explainer is still a Level 0 one-file page. Reach for this profile only once the complexity
gate (`project-architecture.md` — *The complexity gate*) says a learning site is genuinely Level 1/2: **many lessons, authored
independently, maintained across sessions.**

## Table of contents

- [What makes a learning site distinct](#what-makes-a-learning-site-distinct)
- [The lesson manifest (source of truth)](#the-lesson-manifest-source-of-truth)
- [The lesson unit](#the-lesson-unit)
- [Progress & state](#progress--state)
- [Interactions (quiz, exercises, code)](#interactions-quiz-exercises-code)
- [Navigation & discovery](#navigation--discovery)
- [Example trees by level](#example-trees-by-level)
- [Failure modes](#failure-modes)
- [Evolution triggers](#evolution-triggers)
- [Migrating a monolith](#migrating-a-monolith)

## What makes a learning site distinct

Three forces set it apart and drive every structural call:

1. **Many like-shaped units.** Lessons/chapters/modules are added one at a time, by possibly different hands,
   long after the shell is built. → a **content manifest** and **external content**
   (`project-architecture.md` — *Patterns*) are almost always right.
2. **Progress is first-class.** "Where am I, what's done, what's next" is core UX, and it must **persist**. →
   a **local persistence** adapter.
3. **Lessons carry interaction.** Quizzes, exercises, runnable snippets, reveals — each is a **feature
   behaviour** that should not tangle with lesson content or with each other.

The UI is pure Web Builder: `wb-shell` + sidenav for the lesson rail, `wb-steps` for progress, `wb-card` /
`wb-media` for lesson cards, `wb-accordion` / `wb-collapse` for reveals, `wb-progress` for completion, the
chart primitives for any data. **Do not invent lesson-UI components** — compose from `wb-*`.

## The lesson manifest (source of truth)

One manifest indexes every unit. Adding a lesson = **one manifest entry + one content file**, nothing else
touched. Keep it declarative:

```jsonc
// content/manifest.json  — the single source of truth for structure/order/metadata
{
  "course": "…",
  "modules": [
    { "id": "intro", "title": "…", "lessons": [
      { "id": "what-is-x", "title": "…", "file": "lessons/what-is-x.html",
        "est_min": 8, "prereq": [], "tags": ["basics"] }
    ]}
  ]
}
```

Everything derives from it: the sidenav tree, ordering, next/prev, breadcrumbs, prerequisite gating, search,
and a progress overview. The manifest holds **structure and metadata only** — never lesson prose (that lives
in the content files) and never user progress (that lives in storage).

## The lesson unit

Each lesson is an **independently-authored content file** (HTML fragment or Markdown rendered to one). It
should be readable and editable on its own, know nothing about other lessons, and expose interaction via
declarative hooks (`data-*` attributes / known class names) that feature modules wire up — not inline
`<script>` per lesson. A cohesive long lesson is fine as one file (`large-static-sites.md`); split a lesson
only when it genuinely mixes unrelated topics.

## Progress & state

- One **storage adapter** owns all persistence (`store/progress.js`): `getProgress()`, `markComplete(id)`,
  `lastVisited()`, plus a `version` for migration. The app never touches `localStorage` directly.
- Model progress as data: a set of completed lesson ids + a last-position pointer. Derive percentages and
  "next" from the manifest + this set — don't store derived values.
- Guard for private mode / disabled storage: the site must still work read-only if persistence fails.

## Interactions (quiz, exercises, code)

Each interaction type is a **feature module** (`features/quiz.js`, `features/exercise.js`,
`features/runnable.js`), each scanning for its own hooks and wiring behaviour. This keeps a new interaction
type from touching lesson content or the shell, and lets each be tested alone.

- **Quiz** — declare questions/answers in the content (or a sibling JSON); the module renders state and
  records the result via the progress adapter. Use `wb-choice` / radio-solid, `wb-cap` tones for
  correct/incorrect, `wb-alert` for feedback.
- **Reveal / hint** — prefer progressive enhancement: `wb-accordion` / `wb-collapse` (native `<details>`)
  needs no JS.
- **Runnable code** — sandbox it (iframe/worker); keep the runner a module, isolated from lesson markup.

## Navigation & discovery

Derive all of it from the manifest: a `wb-shell__side` sidenav tree of modules→lessons, `wb-steps` for the
current path, `wb-breadcrumb`, a `wb-pager` for prev/next, and client-side search over manifest titles/tags.
Prerequisite gating reads `prereq` against the progress set. Nothing here is hand-maintained per lesson.

## Example trees by level

**Level 0** — a single explainer/one lesson: just `index.html`. No manifest, no adapter, no `.agent/`.

**Level 1** — a small course, few lessons, light maintenance:
```
index.html            # shell + router
content/manifest.json # order + metadata
content/lessons/*.html
app.js                # render + a little progress in localStorage
AGENTS.md             # short: where lessons live, how to add one, how to run
```

**Level 2** — a real, growing course with interactions and progress:
```
index.html / shell
content/manifest.json
content/lessons/*.(html|md)
features/{quiz,exercise,runnable}.js   # one module per interaction type
store/progress.js                      # persistence adapter (+ versioned migrate)
nav/                                   # manifest-derived sidenav/search/pager
AGENTS.md + .agent/ (decisions, handoff) as needed
```

Physical paths are illustrative — follow the framework's conventions if one is in play
(`project-architecture.md` — *The architecture model*).

## Failure modes

- **Manifest drift / no manifest** — nav and order hardcoded per page; adding a lesson means editing many
  files. → derive everything from one manifest.
- **Progress smeared into the UI** — `localStorage` calls in lesson code, unmigratable. → one adapter.
- **Interactions tangled into content** — a quiz's logic inline in the lesson, copy-pasted per lesson. → one
  feature module scanning declarative hooks.
- **One mega-file** — shell + all lessons + all interactions in a single file that no longer opens fast (the
  classic ~20k-line study page). → migrate incrementally (`large-static-sites.md`).
- **Invented lesson components** — bespoke card/quiz/progress CSS instead of `wb-*`. → compose from the
  library; if a genuinely new primitive emerges, that's an **upstream** candidate (`problem-routing.md`),
  not a local one-off.
- **Over-building a single explainer** — a manifest + adapter + `.agent/` for one lesson. → that's Level 0.

## Evolution triggers

- Lessons authored by non-developers → move content to Markdown/CMS behind the same manifest.
- Many courses → the manifest grows a `courses` layer, or splits per course.
- Server-synced progress needed → add a sync layer behind the existing adapter interface (the adapter is why
  this is cheap).
- Search outgrows client-side → a prebuilt index or a service.

Record the ones you defer, with their trigger, in `AGENTS.md` (`project-protocol.md`).

## Migrating a monolith

A big single-file study site (content + styles + behaviour + progress in one ~20k-line `index.html`) migrates
**incrementally, never big-bang** — see `large-static-sites.md` for the ordered steps. The learning-specific
order: baseline verification → extract the **lesson content** into `content/` + a manifest first (the highest
independent-change surface) → extract **progress** into an adapter → extract **interactions** into feature
modules → extract routes last. Verify parity after every step.
</content>

# Large & single-file sites — when big is fine, and how to split when it isn't

This reference covers two cases the complexity gate hands off: a **cohesive file that exceeds the fast-path
threshold** (evaluate, don't reflex-split) and a **large monolith that genuinely needs decomposition**
(migrate incrementally, never big-bang). The governing rule is `project-architecture.md` — *File decomposition*:

> **File size is a diagnostic signal, not an architectural rule.** A cohesive 10,000-line content file may be
> acceptable. A 1,000-line file mixing layout, content, styling and behavior may not be.

## Table of contents

- [Big is not automatically wrong](#big-is-not-automatically-wrong)
- [The split decision](#the-split-decision)
- [Incremental migration (the ordered steps)](#incremental-migration-the-ordered-steps)
- [Worked example: a ~20,000-line study page](#worked-example-a-20000-line-study-page)
- [Anti-patterns](#anti-patterns)

## Big is not automatically wrong

A large file is fine when it is **cohesive, structured, and searchable**:

- One clear responsibility (e.g. it is *all lesson content*, or *all of one reference document*).
- Predictable internal structure — consistent headings/sections/anchors an agent can jump to with one search.
- A change usually touches **one local region**, not the whole file.
- It opens and searches without tooling lag.

If crossing 1,000 lines / 100 KB only means "there is a lot of cohesive content," **keep it as one file.**
Splitting cohesive content across files for a line count buys nothing and adds navigation overhead and the
risk of a duplicated source of truth. A 10,000-line file that meets the bullets above is a *non-issue*.

## The split decision

Split **only** on concrete evidence (`project-architecture.md` — *File decomposition*): mixed responsibilities in one file;
unclear ownership; a change forces scanning the whole file; IDE/tool lag; the file can't be read in a
reasonable agent pass; multiple independent units cohabiting; a part you can't test alone; frequent edit
conflicts; a duplicated source of truth; a dependency-direction violation.

The distinction that matters: **many independent units** living together (split — each changes on its own
cadence) vs **one cohesive body** that happens to be long (keep — it changes as a unit). A 700-line file that
tangles layout + content + CSS + state + three behaviours is a better split candidate than a cohesive
12,000-line one.

Before splitting, name the seam by **responsibility / unit of change**, not by line budget. If the only
reason you can give is "it's too many lines," you don't yet have a reason to split.

## Incremental migration (the ordered steps)

When decomposition *is* warranted, migrate in small, verifiable steps. **Never rewrite big-bang** — each step
must keep the site working and be checkable against the baseline.

1. **Baseline verification.** Capture current behaviour first: what the page renders, its routes/anchors, key
   interactions, console clean. This is the parity oracle every later step is checked against
   (`verification.md`). Commit this baseline.
2. **Extract independently-changing content** (highest-value seam). Move the many-units content
   (lessons/articles/records) out to `content/` + a manifest. The file now references content instead of
   embedding it.
3. **Extract project styling** *if needed*. Pull page-specific CSS into its own stylesheet. (Web Builder's
   `web-builder.css` already carries the component styling — this is only for genuinely project-specific
   rules.)
4. **Extract behaviour by feature.** One module per independent behaviour (`features/<name>.js`), each owning
   its own DOM wiring. Move them out one at a time.
5. **Extract routes / pages** — **only if** there's a real reason (multiple entry points, deep-linking, SEO).
   Often unnecessary; a single shell + content switching is enough.
6. **Verify parity after every step.** Re-run the baseline checks; the site must behave identically. If a step
   can't be verified, it's too big — cut it smaller.
7. **No big-bang rewrite.** If you're tempted to "just rewrite it clean," stop — you lose the parity oracle and
   the ability to bisect a regression.
8. **Don't split cohesive content for LOC.** The content file can stay large after extraction; that's the
   point — it's now *only* content, cohesive and independently editable.

Stop as soon as the pain that triggered the migration is gone. You do **not** have to reach a maximal
structure — the goal is a maintainable one, at the lowest level that solves it (`project-architecture.md` — *The complexity gate*).

## Worked example: a ~20,000-line study page

A single `index.html` holding a whole course — shell, all lessons, all quizzes, progress, and styles inline.
The gate says Level 2 (many independent units, ongoing maintenance, tool lag). Migrate:

1. **Baseline:** list every lesson anchor, every interaction, and confirm a clean console; commit it.
2. **Content out:** each lesson → `content/lessons/<id>.html`; build `content/manifest.json` (order +
   metadata). The shell now renders lessons from the manifest. Verify: same lessons, same order, same anchors.
3. **Styling out** (if the inline `<style>` is large and project-specific): → one stylesheet. Verify visual
   parity in light **and** dark.
4. **Behaviour out:** `features/quiz.js`, `features/progress.js`, `features/reveal.js` — one at a time, each
   verified. Progress moves behind a `store/progress.js` adapter.
5. **Routes:** add real routes only if deep-linking to a lesson is required; otherwise keep the shell +
   manifest switch.
6. **Parity** re-checked after each step; `AGENTS.md` written so the next agent can add a lesson without
   reading the whole tree.

Result: a cohesive-per-file Level 2 tree where adding a lesson is one manifest entry + one content file — the
learning-site target shape (`learning-sites.md`).

## Anti-patterns

- **Big-bang rewrite** — throwing away the working monolith for a fresh structure; you lose parity and
  bisectability.
- **LOC-driven splitting** — cutting a cohesive file because a number crossed a line; adds indirection, no
  value.
- **Forwarding-only files** — a "module" that just re-exports; a boundary with no responsibility behind it.
- **Duplicated source of truth** — content copied into both the old file and the new one "during migration";
  keep exactly one authoritative copy at every step.
- **Skipping the baseline** — migrating with no parity oracle, so you can't tell what a step broke.
</content>

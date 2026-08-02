# CLAUDE.md

## The product is the skill — everything else serves it (read first)

**This project produces one thing: the `web-builder` skill.** The docs site, the `/wb-change` workflow, the
`.claude/` hooks, even this file — all of it exists **only to produce and protect a high-quality skill**.
It is instrumentation, never the goal. Judge every change by one question: *does this leave the shipped skill
better, and still coherent?* A pretty demo, a passing check, or a green hook mean nothing if the skill itself
regresses — so any guardrail, validator, or review worth having validates the **skill**, not just the docs plumbing.

The skill = `web-builder/SKILL.md` + `web-builder/references/` + `web-builder/assets/web-builder.css` (**the
only file that ships to a running app**) + `web-builder/assets/templates/` (source you copy, not something an
app links). The docs site (`index.html` / `app.js` / `docs.css` / `pages/`) and `.claude/`
tooling **never ship** — they exist to review, dogfood, and safeguard the skill. What the skill is: a
minimalist, zero-build CSS component library for web UIs (personal-finance is its flagship use, not its
boundary). `README.md` = project map; `web-builder/SKILL.md` = how to build UI with it.

North star: **reuse** — assemble web UI from approved `wb-*` parts, and fold anything genuinely new back into
the skill (the sync steps below), so the skill keeps compounding in quality.

**Docs = the human-readable superset of the repo.** The skill is the *product*, but the **docs** — this file,
`README.md`, `web-builder/references/*.md`, the docs-site, and code comments — are where a **person** finds
*everything true of the repo*: skill **+** code **+** tooling (the `/wb-change` workflow and how it triggers,
the hooks, the numbered design principles §1–25, the deliberate trade-offs). If a fact lives only in code or
tooling and a human can't find it in the docs, that's a gap to close — not to leave implicit. So a repo change
isn't done when the code works; it's done when the docs a human would read still tell the whole, true story.
And the docs **site** must be **self-contained** (§23): a `pages/*.html` renders its content **in-site** (for
length use a `<details>`/accordion or a dedicated page — e.g. `principles.html` renders §1–25 in full,
`tooling.html` covers serve/verify/hooks, `decisions.html` mirrors the README trade-offs (each tagged `T#`)),
never a teaser punting a human to a raw `.md`. (The AI-facing `SKILL.md → references/*.md` layering stays —
that's token thrift, not a gap. `validate-sync.sh` CHECK 11(c), 12 + 13 enforce this — 13 blocks a commit if a
README `T#` isn't rendered on `#/decisions`.)

## Working here

- **Use the web-builder skill. Don't invent styling** — assemble from `wb-*` classes + tokens
  (look up the fit in `web-builder/references/components-catalog.md`). If you're typing a hex or a px, there is
  almost certainly a token for it.
- **Only `web-builder/assets/web-builder.css` ships to a running app** (+ `assets/templates/` as source you
  copy). `index.html` / `app.js` / `docs.css` / `pages/` are docs chrome and never ship.
- **Preview:** `cd web-builder/assets && python3 serve.py` → http://127.0.0.1:8777 (no-store, so a normal
  reload shows edits). Drive the SPA by setting the hash, e.g. `#/receipt`; after editing `app.js`, do a
  full reload (its in-memory `SECTIONS`/`ROUTES` is stale until then).

## The change workflow (`/wb-change`) + guardrails

A component/token change touches many files, so run **`/wb-change`** — it orchestrates the full flow
(discover → plan → confirm → implement → sync the 7 places below → verify in the browser → `/code-review`
→ commit + push), pushing heavy reads to subagents to save tokens. Two hooks in `.claude/` back it up:
a **PostToolUse** nudge injects the sync checklist the moment you edit `web-builder.css`, and a
**PreToolUse** gate blocks `git commit`/`git push` when `.claude/hooks/validate-sync.sh` fails. For discovery,
a read-only helper `.claude/tools/wb.sh locate <class>` prints ready-to-run `Read` offset/limit clusters +
a blast-radius map, so you never read the whole CSS. (Automating §18/coherence as a *gate* was tried and
dropped — too noisy on the real CSS; they stay eyeball checks. See README § *Deliberate trade-offs*.) The full
workflow lives in the skill/hooks (loaded on demand), not here — this file stays a lean pointer.

## Adding or changing a component — sync ALL of these in one change

> **Whole screens start from a template.** `web-builder/assets/templates/*.html` ships six finished screens
> (dashboard · list · form · detail · settings · auth) on the scaffold; SKILL.md makes starting there a hard
> rule. They ship *as source you copy* — the runtime payload is still exactly one CSS file. A change to the
> shell, the page rhythm, or anything every screen carries must land in the affected templates too (step 7),
> and a new page recipe means a catalog row **and** a template file (CHECK 14 locks both directions).

1. `web-builder/assets/web-builder.css` — the `.wb-*` rules (numbered section; **tokens, not magic numbers** —
   hairline `var(--wb-bw)`, pill `var(--wb-radius-pill)`).
2. `web-builder/assets/pages/<id>.html` — the demo page (markup only; use `.wb-cluster/.wb-stack/.wb-grid`
   for layout, not inline `display:flex`).
3. `web-builder/assets/app.js` — a `{ id, label }` in the `SECTIONS` model (single source of truth for the
   section switcher + sidebar + router): a **component** goes under the right `group` in the `components`
   section; a foundation/meta page goes in the flat `items` of the `design` / `project` section.
4. `web-builder/references/components-catalog.md` — a section + a decision-guide row.
5. `web-builder/SKILL.md` — the AI's **first read**: add the new part to the right per-intent scope group
   (*Foundation · Actions · … · Structure*), or note a new capability on a family already listed. If SKILL.md
   doesn't list it, the next AI trusts its scope and assumes the part doesn't exist — exactly the miss that
   put this line here.
6. `web-builder/assets/templates/<screen>.html` — if the change touches the shell, the page rhythm, or
   anything every screen carries. A **new page recipe** = a catalog row **and** a template file (CHECK 14).
7. If relevant: `design-principles.md` (a convention), `integration.md` (needs an app behaviour
   engine), `bootstrap-comparison.md` (coverage note), `CHANGELOG.md` (a **user-visible** new/changed part —
   the shipped changelog rots if you skip it).

If these drift, the skill misleads the next AI. Verify with `.claude/hooks/validate-sync.sh` — it validates
both the **docs site** (routes == pages · no per-page `<style>` · `app.js` parses) **and the skill
deliverable** (SKILL.md frontmatter + trigger description · SKILL.md scope names every component `group` · every
`references/*.md` exists · the catalog never documents a class the CSS lacks · `web-builder.css` braces
balanced · every catalog recipe has a real template and every template has a recipe · **one version string**
— `--wb-version` agrees with the newest cut release in `CHANGELOG.md`, the CSS header, SKILL.md and both
docs-chrome strings). The commit gate runs it for you.

## Conventions to keep

The **colour ladder is the most important rule** (design-principles §1): white-black-grey first (tier 1);
bright **solid** colour only for real status (tier 2 — paid / overdue / due-soon); the same colour **soft**
when the signal should stay calm (tier 3). Tiers 2–3 are colour-spend *levels* that ride on **any** component
(capsule, tag, number, border, row tint, card, chart) — not just capsules. Classification (a category) is
*not* status — keep it grey.

**Locale split:** docs **chrome is English** (the sidebar/nav model in `app.js`, the topbar, the Tweak panel,
the footer — and a page's `wb-eyebrow`, which echoes its `SECTIONS` group label so the two must be renamed
together). Everything a page *says* — prose, demo copy, sample labels — stays **Vietnamese-first** (§20: copy
is data). Rename a NAV `group` and you also touch SKILL.md's scope headers (CHECK 10), README, this file,
`bootstrap-comparison.md`, `docs-site.md` and the eyebrows on that group's pages.

Then: **tokens over magic numbers**; the docs are **dogfooded** (built from `wb-*` primitives); dark flips
shadows to a soft light lift; dismiss **×** top-right; **no left-accent bars**; layout is a small flex/grid
utility set, **not** a 12-column foundation. Full numbered rules: `web-builder/references/design-principles.md`.

## Git

Solo repo, committed directly to `main` (the user's established workflow). Branch only if asked.
End commit messages with `Co-Authored-By: Claude <model> <noreply@anthropic.com>`, where `<model>` is the
model you are actually running as (`Claude Opus 5`, …) — sign what authored the commit, don't copy a name
out of this file. History up to `41bcc01` is signed *Claude Opus 4.8*, which was accurate at the time.

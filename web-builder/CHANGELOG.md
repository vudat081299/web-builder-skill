# Web Builder — Changelog

The shipped skill (`SKILL.md` + `references/` + `web-builder.css`) **compounds over time**. This log tells a
**consumer** — an app, or an AI reading the packaged skill — what changed between versions, so an integration
can tell whether a part it needs already exists. Newest first.

> Scope: the **shipped skill** only. The docs site (`assets/index.html` · `app.js` · `docs.css` · `pages/*`)
> is instrumentation that never ships and isn't versioned here. How to *rebuild* the docs from the skill lives
> in [`references/docs-site.md`](references/docs-site.md); how the loop closes is in `SKILL.md` ("Closing the loop").

## Unreleased (v0.7-dev)

### Added
- **Shared counter badge — `.wb-badge` (CSS section 56).** A count / notification badge previously existed
  only as `wb-sidenav__badge` (sidebar-only). `.wb-badge` is the shared one for nav items, tabs, buttons,
  icon buttons and avatars: neutral by default (a count is information, not status — colour ladder §1), with
  solid `--danger` / `--success` attention tones, a `--dot` (presence, no number), and `--float` inside
  `.wb-badge-host` to pin a count to the top-right corner of an icon/avatar. Documented on the Capsules /
  Badges page + catalog. CSS only — reuses existing tone tokens.
- **Code block primitive — `.wb-code` (CSS section 55).** The docs' own code block (`.demo__code`) is chrome
  and never ships, so an app needing a monospace block had nothing to reach for (mildly against the §2 dogfood
  stance). `.wb-code` ships it: an **inline** chip on `<code>`/`<span>` and a **block** on
  `<pre class="wb-code">` (preserves whitespace, scrolls sideways on the page-wide themed scrollbar). Mono from
  `--wb-font-mono`, neutral `--wb-surface-2` surface + hairline border. New `#/code` demo page + catalog *Code*
  section + decision row. No JS.
- **Print stylesheet — `@media print` (CSS section 54).** Finance UIs get printed (receipts, debt tables,
  statements) and the library had zero print rules. Now it prints on a **white, ink-saving page in any theme**
  (dark mode re-declares the core surface/ink/border tokens to light for print), drops shadows and
  navigation/transient chrome (navbar · sidenav · shell rail · drawer · toast · tooltip · pager · pagination),
  keeps `wb-card` / `wb-receipt` / `wb-stat` / table rows from splitting across a page fold, and repeats a
  table's `thead` on every page. Documented as design-principles §26. CSS only — no class or token added
  (reuses existing tokens).
- **Table row selection + bulk actions — `wb-table__check` + `wb-table-bulk`.** The other half of a real list
  screen (pairs with the filter bar): a leading checkbox column with a **select-all** header box (tri-state:
  checked / indeterminate / empty), an `is-selected` neutral row tint (new `--wb-row-selected` token —
  selection is classification, not status, so no colour), and a `.wb-table-bulk` bar that reveals a live count
  + batch actions once anything is picked. Dependency-free docs driver in `app.js` (delegated `change`/`click`
  on `data-row-select` / `data-select-all` / `data-bulk`). New: catalog *Row selection & bulk actions* section
  + a `#/tables` demo.
- **Table column sort — `wb-th-sort` + `aria-sort`.** Click a header to sort the rows ascending ⇄ descending.
  This is genuinely *column sort*, distinct from `wb-table--sortable` (drag-to-reorder whole rows), which used
  to be the only "sortable" the library had. State lives on the accessible `aria-sort` attribute (no extra
  class), the caret flows inline so it never overlaps a right-aligned `wb-num` header, and the sort key is
  `data-sort-value` if present else the cell text (numeric auto-detected, otherwise Vietnamese-aware compare).
  A ~20-line dependency-free driver ships in the docs `app.js` to copy. New: catalog *Sort by column* section +
  a `#/tables` demo. CSS/JS only — no token added.
- **Architecture layer — AI-native project organization.** Beside building UI, the skill now helps an agent
  choose *how a project is organized* — an **adaptive** capability, never mandatory ceremony. Small builds take
  a **one-file fast path** (a single `index.html`, no `.agent/`); structure appears only when a complexity gate
  says a site is large/long-lived (Level 1/2), synthesized from constraints rather than a fixed tree.
  - **New references (ship with the skill):** `project-architecture.md` (the hub — Level 0/1/2 gate,
    constraint-based synthesis, capability vocabulary, patterns, file-decomposition, evolution rules),
    `site-profiles.md`, `learning-sites.md`, `large-static-sites.md`, `project-protocol.md`,
    `problem-routing.md`, `verification.md`.
  - **`SKILL.md`** gained the one-file gate, the invocation boundary, and architecture routing; its trigger
    description now also covers new-site / architecture / restructure. Still < 500 lines.
  - **Scope of the architecture half:** it shapes **the web project's own files**. It is deliberately *not* a
    system-architecture skill (backend / service / data-platform design belongs elsewhere), and packaging or
    releasing Web Builder itself is upstream-repo work — kept **out** of the shipped trigger so a consumer never
    auto-loads the skill for a release flow they don't have.
  - **Repo tooling (does NOT ship):** agent-agnostic `scripts/` (verify · package · verify-package · install ·
    release + project/problem classifiers), workflows `/wb-architect` · `/wb-intake` · `/wb-release`, and
    `tests/forward-tests.sh`. No component, template, runtime, or component doc changed.

### Fixed
- **Tool-call scaffolding had leaked into 11 authored files** — a trailing line that was only `</content>` (and
  one `</invoke>`). Seven of them are shipped `references/*.md`, so the garbage was being packaged into
  `web-builder.skill` and distributed. Stripped, and **CHECK 20** in `scripts/verify.sh` now blocks any commit
  that reintroduces it — every other check had passed on the bad bytes, and packaging verified them faithfully.
- **The Level 0/1/2 classifier contradicted the reference it encodes.** `classify-project.sh` omitted two of
  `project-architecture.md`'s own "stop being Level 0" signals (a contributor needing a handoff; tooling lag),
  so a one-page site with a handoff need classified **L0**. A lone handoff need now escalates to **L1** — not
  L2, per *"one signal ≠ maximal architecture"* — and a large **non-cohesive** single file is now recognised as
  split evidence and routed to incremental migration instead of being reported as *"no signals"* and called
  *small*. Two fixtures (`10-onepage-handoff`, `11-tangled-oversize`) lock both directions.
- **`problem-routing.md` promised a routing class nothing could produce.** Its table declares
  `project-architecture` ("a workaround forced by *this project's* architecture"), but `classify-problem.sh`
  had no branch returning it — so a finding with **complete** evidence fell through to `needs-triage`
  (*"keep investigating"*), sending a downstream agent to look for evidence it already had. The class is now
  reachable, ordered ahead of `upstream-candidate` so an architecture-forced workaround is never reported
  upstream as a missing primitive. Also fixed in the same reference: *"The **two** that flow upstream"*
  followed by a list of **three**.
- **`SKILL.md` hid the landing template from the next AI.** `landing.html` shipped as a seventh page template
  and the catalog gained its recipe, but `SKILL.md`, `CLAUDE.md` and `bootstrap-comparison.md` still said
  **"six finished screens"** — and `SKILL.md` contradicted *itself* (two places said seven, one said six). An
  agent trusting the router would conclude no landing template existed and compose one from scratch, which is
  exactly what starting-from-a-template is supposed to prevent. Corrected everywhere, and **CHECK 24** now
  compares the counted prose against the actual number of template files.
- **The Level 0 / Level 2 reference examples used three classes that don't exist.** `tests/examples/` models
  correct usage — the forward tests point at it — yet the Level 0 landing wrote `wb-btn--primary` (plain
  `wb-btn` *is* the primary button), `wb-cap--soft-success` (the soft tier is `wb-cap wb-cap--success`) and
  `wb-text-muted` (the muted-text utility is `wb-help`). All three rendered as nothing. Fixed, and CHECK 23
  now covers `tests/examples/` too.
- **A shipped demo page taught a class that does not exist.** `pages/shell.html` wrote
  `<input class="wb-input wb-input--sm">`, but `web-builder.css` has no input size modifier — so the input
  rendered at default size and any agent copying that markup (which `SKILL.md` explicitly tells it to do)
  inherited a class that silently does nothing. Removed. **CHECK 23** now closes this direction permanently:
  CHECK 8 already stopped the *catalog* from documenting a class the CSS lacks, but nothing stopped
  `pages/*.html` or `templates/*.html` — both of which **ship** — from *using* one.
- **Guardrails for the architecture layer itself.** The component half is anchored to a machine-checkable
  artifact (CHECK 8 diffs the catalog against the real CSS); the architecture half was unanchored prose, and
  both drifts above survived a fully green test suite — because the tests check each classifier *against
  itself*. **CHECK 21** now proves every complexity-gate signal is both gated in `classify-project.sh` and
  named in `project-architecture.md`; **CHECK 22** proves `problem-routing.md`'s class table and
  `classify-problem.sh` offer the same set. Both directions, both files, hard-blocking.

### Changed
- **Theme default is now a documented contract: first visit follows the OS, the toggle is 2-state.** When a
  build asks for "dark/light" and nothing more, ship: no stored preference → follow `prefers-color-scheme`
  (via a pre-paint boot script, not a CSS `@media` block); the toggle flips **light ⇄ dark only** and persists
  under `localStorage["wb-theme"]` (`'light'`|`'dark'`); there is **no "system"/"auto" button state** (clearing
  the key returns to OS-follow). The shipped `templates/*.html` already wired this; now `SKILL.md`,
  `design-principles.md` §6 and the catalog's theme-toggle section spell it out, and the templates use the
  collision-safe key `wb-theme` (was the generic `theme`). The docs-site topbar toggle dropped its old 3-state
  `system→light→dark` cycle to match. No CSS or component changed.
- **The theme-aware scrollbar is now a page-wide default, declared once** (CSS section 27). It used to be an **opt-in
  name list** (`.wb-scroll-y` · `.wb-scroll-x` · `.wb-table-scroll` · `.wb-menu` · `.wb-textarea` ·
  `.wb-scrollbars`), so any *other* scroller — an `overflow:auto` div you wrote by hand, a third-party widget,
  a hand-rolled dialog body — showed a bright OS bar next to wb surfaces, and `.wb-scrollbars` had to be
  repeated on every one of them. Now CSS section 27 declares it on `:root` (+ `.dark`) and `*`, and **every** scroller on
  the page inherits it, including the viewport bar, with **no class to add**. `.wb-scroll-y`/`-x` keep their
  real job: overflow + tail room.
  - **New: `.wb-scrollbars--os`** — hands an element **and its subtree** back to the native OS scrollbar
    (a widget that ships its own bar, or a surface that must look un-themed).
  - **`.wb-scrollbars` still works** but is now a **no-op** on a normal page; it is kept for existing markup
    and for re-asserting the theme on a scroller *inside* a `--os` subtree. Nothing to change in an app that
    uses it — the repo's own templates simply dropped it.
  - **If you retune the bar, edit both halves.** Measured in Chrome 148: where a scroller has
    `scrollbar-color`/`-width`, Chrome **ignores** that scroller's `::-webkit-scrollbar` rules — so the
    `::-webkit-*` block in that section is a **legacy-WebKit fallback** (Safari < 18.2), not a twin of the standard
    props. The old comment claiming the two were "kept identical" was wrong.

### Fixed
- **The app-shell rail could float over the page and let main content show through it.**
  `.wb-shell__side` carried both `position: sticky` and its own `overflow-y: auto` — sticking to the
  viewport scroll *and* scrolling its own content on the same node. Chromium can mistrack that box's
  size/position after a fast, forceful scroll: the rail collapses to its content height and renders as a
  floating card, and since it no longer occupies real space in the shell's flex row, the main column flows
  in right where the rail used to sit — whatever was there (an alert, a heading) shows through around it.
  Reported against a consuming page and confirmed with a screenshot of it happening on Chrome/macOS.
  Fixed by splitting the two roles: `.wb-shell__side` now only sticks and clips (`overflow: hidden`, no
  scroll math of its own); `.wb-sidenav` — already the documented single child every consumer nests inside
  it — carries the real `overflow-y: auto` plus the padding that used to sit on the slot. **No markup
  change** for a rail built the documented way: every shipped template and every demo page already nests
  content like that. A rail with **more** than that one child needs the new `--stack` below.

### Added
- **`.wb-shell__side--stack`** — the rail slot for a rail that holds **more than the one `.wb-sidenav`**: a
  pinned search box, a workspace switcher, an account block that must stay put while the nav scrolls. The
  slot takes the padding back and becomes a flex column; every child is pinned by default and the **one**
  that scrolls says so with `.wb-scroll-y`, taking the leftover height plus the tail room.
  ```html
  <aside class="wb-shell__side wb-shell__side--stack">
    <div class="wb-input-group"> … </div>          <!-- pinned -->
    <nav class="wb-sidenav wb-scroll-y"> … </nav>  <!-- the one that scrolls -->
  </aside>
  ```
  This closes the hole the fix above would otherwise have left: with the scrolling moved onto the
  `.wb-sidenav` child, a rail whose direct child *isn't* that nav had nothing scrolling at all and got
  silently clipped by the slot's `overflow: hidden`. The docs site's own rail is exactly that shape and now
  runs on this modifier instead of a docs-only flex column.

## v0.6 — 2026-08-02

The release that ships the **ground under the components**: the app shell + page scaffold, the `.wb-app`
baseline, seven finished page templates, and a self-review rubric. Everything below had lived only in the
docs' own un-shipped stylesheet, which is why a build using the skill never looked like the docs.

The one shipped file now carries its own version: `var(--wb-version)` (`"0.6"`), readable at runtime.

### Added
- **`--wb-version`** — the shipped stylesheet now says which build it is, as a `:root` token you can read at
  runtime: `getComputedStyle(document.documentElement).getPropertyValue('--wb-version').replace(/"/g,'')`
  → `0.6` (it is a CSS *string*, so it works in `content:` too — hence the quote-strip). The one
  file is normally **copied** into a project rather than installed, so there is no `package.json` to check —
  a consumer holding `web-builder.css` previously had no way at all to tell v0.5 from v0.6, and the repo
  itself had drifted (this changelog said *Unreleased (v0.6-dev)* while the docs already displayed a shipped
  *v0.6*). The token is the source of truth and `validate-sync.sh` **CHECK 15** now blocks a commit when the
  changelog, the CSS header, `SKILL.md` or the docs chrome disagree with it.
- **`references/page-review.md` — a nine-gate self-review** an AI runs on a finished page *before* delivering
  it. Four gates are **measurable**, with a console snippet in the file: invented classes · the colour ladder ·
  horizontal overflow at 1280/900/700/390 · a navbar that has wrapped. The rest are judgement gates (frame,
  heading ladder, both themes, a11y floor, real copy) plus a table of the specific mistakes this library
  invites. **Why it matters to a consumer:** "start from a template" makes a page *begin* right; nothing
  checked that it still *ended* right. On its first run the class-parity gate found `.is-done` — see below.
- **`templates/landing.html`** — the seventh screen and the second shell-less one: the public/marketing page
  (navbar + container + full footer, no rail). Hero → proof → features → `wb-steps--horizontal` → pricing →
  FAQ → CTA. Entirely **tier 1**: it ships with zero coloured backgrounds, because a marketing page has no
  status to report — the ladder's most-tempting-to-break case, answered by example.
- **`.wb-navbar--collapse-lg`** — collapse the bar's inline links at **900px** instead of 640. 640 fits an
  *app* bar (brand + a couple of links + icon actions); a *public* bar also carries a full link menu and one
  or two text CTAs, which needs ~840 — so between roughly **660 and 840px it wrapped to two rows**, the exact
  broken state the collapse exists to prevent. 900 is deliberately the width `.wb-shell` folds its rail at, so
  a page makes one layout shift, not two. A modifier rather than a token because a container query cannot read
  a custom property. Rule of thumb: more than ~3 links, or any text button in `__actions` → use it.
- **`.wb-steps__item.is-done`** — now a **real rule**. The docs, the catalog and the CSS comment all promised
  the triad `.is-done` / `.is-active` / `.is-todo`, but only the last two were ever defined; `is-done` "worked"
  purely because it happened to match the marker's default. It read as an invented class in any markup audit
  (that is how it was found), and it would have broken silently the day the default changed. Same declarations
  as the base marker, on purpose. Two shipped templates were using it.
- **Page templates** (`assets/templates/*.html`) — six **finished screens** built on the scaffold:
  `dashboard` · `list` · `form` · `detail` · `settings` · `auth`. Each is a standalone HTML document (one
  `<link>` to `web-builder.css`, no build) covering a named recipe in `components-catalog.md`, and each
  shell template ends with the same ~12 lines of driver JS — two class toggles, the whole behaviour contract
  of a shell. **`SKILL.md` now makes starting from a template a hard rule**, and `validate-sync.sh` CHECK 14
  locks recipes ↔ templates both ways. **Why it matters to a consumer:** the previous release shipped the
  frame but still left a build assembling a screen part by part, re-deciding heading levels, breadcrumb
  placement and colour budget every time. These ship the decisions.
- **`.wb-app` — the app baseline** (CSS section 53), the ground under everything: `box-sizing: border-box`
  for every `wb-*` element, the font, canvas/ink colours, `line-height: 1.55`, font smoothing, and links
  that inherit their colour instead of going browser-blue. Put it on `<body>`; `.wb-shell` carries the same
  declarations, so only a shell-less screen (auth, landing, an embedded widget) needs it explicitly.
  Deliberately opt-in rather than a bare `body {}` rule, so dropping the stylesheet in for one component
  never restyles a host page. **Why it matters to a consumer:** this had never shipped — it lived in the
  docs' own stylesheet — so every other build fell through to browser defaults (serif text, blue underlined
  links, a loose line-height, an 8px body margin). It was the largest single reason a build didn't look
  like the docs.
- **`.wb-shell__side-toggle`** — the ☰ that opens the folded rail. Shows at exactly the 900px width the
  rail folds at, so the button and the drawer can never disagree. (Distinct from `.wb-navbar__toggle`,
  which collapses a bar's *inline links* by the bar's own width; between 640 and 900px there was previously
  no way to open the rail.)
- **App shell & page scaffold** (CSS section 52) — the layer *above* components: the frame of a whole screen plus the
  heading rhythm inside it. `wb-shell` + `__body` / `__side` / `__main`; the rail slot sticks below the bar,
  scrolls on its own, and folds into an off-canvas drawer with a scrim below 900px, driven by
  `.is-side-collapsed` / `.is-side-open` on the shell. Content column = `wb-container--pad`. Heading ladder:
  `wb-eyebrow` · `wb-page-head` (`--lg` hero) · `wb-section` · `wb-block`, each with `__title` / `__desc` and
  each styling whatever `h1…h6` you nest inside, so an app keeps a valid outline and still gets the scale.
  **Why it matters to a consumer:** this frame previously existed only in the un-shipped docs chrome, so a
  build using the skill had every component but had to invent its own shell and spacing — the main reason a
  finished screen didn't look like the docs. Start every new screen here.
- **Type scale + rhythm tokens** — `--wb-text-display/-page/-section/-title/-body/-help/-caption/-label`
  (the ladder the Typography page documented as a convention is now an API), `--wb-measure` / `-tight` for
  prose width, and the shell/rhythm knobs `--wb-shell-h` · `--wb-navbar-h` · `--wb-sidenav-w` ·
  `--wb-page-pad-block` / `--wb-page-pad-end` · `--wb-section-gap` · `--wb-block-gap`.
  Existing components keep their literal px sizes for now — retrofitting them onto the tokens is a deliberate
  separate sweep, not folded silently into this one.
- **Page recipes** — `references/components-catalog.md` gains a *Composing a page* section: an app-shell
  skeleton (now rooted in `wb-shell` — see the entry above) plus named recipes
  (dashboard · records list · form · detail · auth · settings) and page-rhythm notes. The "build a whole
  screen from nothing" layer.
- **`references/docs-site.md`** — the docs-site architecture (NAV/router, page grammar, docs-chrome inventory,
  Config/search/dual-preview), so the skill is self-sufficient to reconstruct the docs.
- **Design principles §19–24** — accessibility baseline, Vietnamese-first copy/locale, responsive
  graceful-collapse, demo-density (fold a free variation into one sample instead of a new section), the docs
  site staying **self-contained** (§23 — render in-site, never defer to a raw `.md`), and **concentric nested
  radius** (§24 — inner radius = outer radius − gap).
- **Navigation primitives** — `wb-footer` (brand + link columns + copyright; `--slim`) and `wb-pager`
  (prev/next page links, `[`/`]` shortcuts) + `wb-kbd` keycap.
- **Receipt** (`wb-receipt`) — `--ticket` variant (dashed tear + half-circle side cuts), scallop/`--wave`/
  `--dashed` edges, `--wb-receipt-d` / `--wb-receipt-gap` notch knobs, bill/transfer/voucher templates.
- **Pickers** — `wb-calendar` (month grid; single date or `--range`), `wb-timepicker` (scroll columns
  hour:minute, `--ampm` for 12-hour), and the colour pickers `wb-swatches` (preset palette) + `wb-colorpicker`
  (SV · hue · hex · presets, replaces the OS dialog). Each hosts inline or inside `wb-popover`.
- **Typed-or-picked inputs** — masked inputs that format *while typing* via `data-mask` (date · time · datetime
  · card · daterange, no popup) and the segmented `wb-input-tpl` field (inked separators, auto-advancing parts),
  kept two-way in sync with the calendar/time popover; plus a rich-text/markdown **format toolbar** (`wb-toolbar`,
  `--attached`) over a textarea.
- **Structure primitives** — `wb-slotgrid` (fixed cells `--1`…`--6`; drop an item into any slot, empty gaps
  kept, drop on an occupied slot **swaps**) and the flat `wb-sortable` list/grid gaining `--no-grip` (drag the
  whole card instead of a handle).

### Changed / fixed
- **The shipped file no longer describes itself as a personal-finance kit.** Line 2 of `web-builder.css` —
  the first thing anyone reads in the *only* file that ships — still said *"component library for personal
  finance web apps"*, left over from `cashy-ui`, long after the repo repositioned to general web UI. It now
  matches what `SKILL.md` and the README have said for a while: a minimalist, zero-build library for web UIs,
  **deepest** on money screens rather than **limited** to them. Comment only; no rule changed.
- **`wb-steps--horizontal`: the rail no longer runs through the markers.** It was drawn centre-to-centre
  (`left: 50%; width: 100%`) and only *looked* right because the default marker is opaque and sits on
  `z-index: 1`, hiding the half-line crossing it. Every state that deliberately drops that fill —
  **`.is-todo`**, **`--dashed`**, `--dot` + `.is-todo`, and all of them in dark — tore the mask off and the
  connector cut straight through the circle. Now it spans the **gap** between two markers
  (`left: calc(50% + size/2); width: calc(100% - size)`), which is exact: horizontal items are `flex: 1 1 0`
  with the marker centred, so centre-to-centre is one item width. Geometry instead of a mask, so it is right
  for every state and every variant at once. No markup change.
- **A text CTA in `wb-navbar__actions` scrolled the whole page sideways.** `__actions` is `flex: none` and is
  never touched by the collapse (by design — the theme toggle, search and avatar must stay reachable on a
  phone), so a text button in it kept its full width at 390px: the shipped **`templates/landing.html`
  overflowed by 116px**, and the catalog was actively recommending that placement. `__actions` is now
  **icon-only by contract**; a text CTA goes at the **end of `__menu`**, after a `wb-navbar__spacer` nested
  inside the menu. To make that work, `.wb-navbar__menu` now takes the free width (`flex: 1 1 auto;
  min-width: 0`) so the nested spacer can push the CTA hard right while the bar is wide — and the CTA tucks
  into the ☰ panel when it collapses. **A bar without a CTA is unaffected**: links stay left, `__actions`
  stays hard right, the outer `__spacer` simply has no free space left to claim. Verified on all seven
  templates × 1280/900/700/390: zero overflow, bar height 56 everywhere.
- **Transparent controls now have a visible hover** — `--ghost` / `--outline` buttons and every dismiss ×
  (`.wb-close`, `.wb-tag__x`, `.wb-filter-token__x`) hover to the new **`--wb-ink-hover`** token, a
  *translucent* ink tint, instead of the opaque `--wb-surface-2` / `--wb-surface-hover`. The bug: an opaque
  `--wb-surface-2` is **byte-identical to `--wb-canvas`**, so a ghost icon button sitting on the app canvas —
  a toolbar, a row action, a close × outside a card — had **literally zero hover feedback**, and on a
  soft-tinted alert an opaque grey punched a grey hole in the colour. Alpha composites correctly on a card,
  the canvas, and a tinted surface alike, and carries its own dark value, so two `.dark` override rules were
  deleted. Nothing to change in an app's markup. New principle in `design-principles.md` §1.
- **`.wb-container` no longer overflows its parent** — it lacked `box-sizing: border-box`, so `width: 100%`
  plus the inline padding made it **40px wider** than any column narrower than `--wb-container-max`. A
  `--wide` container next to a shell rail scrolled the page sideways. Now covered by the section-53 rule
  (every `wb-*` element is border-box) and set explicitly on the container. The docs never saw it: they cap
  the max below the column width.
- **`.wb-page-head > .wb-breadcrumb`** gets the gap under it. A breadcrumb carries no margin of its own (it
  is also used inline, in a card, in a bar), so nested in a page head it collided with the eyebrow. Nest it
  **inside** `.wb-page-head`; a sibling above still has no gap, by design.
- **Intent-group names are English** — the eleven scope groups in `SKILL.md` are now *Foundation · Layout &
  utilities · Actions · Inputs · Pickers · Data display · Feedback · Overlays · Navigation · Disclosure ·
  Structure* (were Vietnamese). Names only: no component moved group, nothing was added or removed. A
  consumer that grepped the old Vietnamese headers to locate a family needs the new names. Component **copy**
  in every example is unchanged — still Vietnamese-first (design-principles §20: copy is data, not style).
- **Card** gains `--pad` — padding on the card itself, for a one-part card with no `__head`/`__body`/`__foot`
  (link groups, callout tiles, small summaries).
- **Section** gains `--flush` — drops the top gap for a section that opens a page right under the head, so
  that case stops being a hand-written `margin-top`.
- **`--wb-scrim`** — the dim behind anything covering the page is now one token, shared by `wb-overlay`
  (modal / drawer) and the shell's mobile rail. No visual change; two overlays can no longer dim differently.
- **Navbar**: height is now `min-height: var(--wb-navbar-h)` instead of a fixed `56px`, so the bar grows for a
  taller control and the shell rail can read the same token for its sticky offset. New `--glass` modifier
  (translucent + blur) for a sticky bar over scrolling content.
- **Sidenav**: width reads `--wb-sidenav-w`. Inside a `.wb-shell__side` slot it drops its own surface (the slot
  paints it) and contributes only link styling — standalone use is unchanged.
- **Accordion** (`wb-accordion`): a long / multi-element `<summary>` (inline `<code>`/`<b>`) no longer
  fragments — the chevron is pinned top-right and the title flows as normal wrapping text (was `display:flex`,
  which made every inline child a flex item and shrank each to min-content, dropping the `·` to its own line).
- Docs dogfooding: de-inlined `display:flex` in the charts/sidenav demos to `wb-cluster`/`wb-stack`.
- Guardrail: `validate-sync.sh` now also asserts SKILL.md's scope names every `NAV` group (drift check).
- De-hardcoded the intent-group list in tooling/docs (it had drifted to a phantom "Biểu đồ" group).

---

*Format: loosely [Keep a Changelog](https://keepachangelog.com). Started at v0.6; entries before this point
live in `git log`.*

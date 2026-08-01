# Web Builder — Changelog

The shipped skill (`SKILL.md` + `references/` + `web-builder.css`) **compounds over time**. This log tells a
**consumer** — an app, or an AI reading the packaged skill — what changed between versions, so an integration
can tell whether a part it needs already exists. Newest first.

> Scope: the **shipped skill** only. The docs site (`assets/index.html` · `app.js` · `docs.css` · `pages/*`)
> is instrumentation that never ships and isn't versioned here. How to *rebuild* the docs from the skill lives
> in [`references/docs-site.md`](references/docs-site.md); how the loop closes is in `SKILL.md` ("Closing the loop").

## Unreleased (v0.6-dev)

### Added
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

# Web Builder — Changelog

The shipped skill (`SKILL.md` + `references/` + `web-builder.css`) **compounds over time**. This log tells a
**consumer** — an app, or an AI reading the packaged skill — what changed between versions, so an integration
can tell whether a part it needs already exists. Newest first.

> Scope: the **shipped skill** only. The docs site (`assets/index.html` · `app.js` · `docs.css` · `pages/*`)
> is instrumentation that never ships and isn't versioned here. How to *rebuild* the docs from the skill lives
> in [`references/docs-site.md`](references/docs-site.md); how the loop closes is in `SKILL.md` ("Closing the loop").

## Unreleased (v0.6-dev)

### Added
- **Page recipes** — `references/components-catalog.md` gains a *Composing a page* section: an app-shell
  skeleton (`wb-navbar` · `wb-sidenav` · `wb-container` · `wb-footer` · `wb-pager`) plus named recipes
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
- **Accordion** (`wb-accordion`): a long / multi-element `<summary>` (inline `<code>`/`<b>`) no longer
  fragments — the chevron is pinned top-right and the title flows as normal wrapping text (was `display:flex`,
  which made every inline child a flex item and shrank each to min-content, dropping the `·` to its own line).
- Docs dogfooding: de-inlined `display:flex` in the charts/sidenav demos to `wb-cluster`/`wb-stack`.
- Guardrail: `validate-sync.sh` now also asserts SKILL.md's scope names every `NAV` group (drift check).
- De-hardcoded the intent-group list in tooling/docs (it had drifted to a phantom "Biểu đồ" group).

---

*Format: loosely [Keep a Changelog](https://keepachangelog.com). Started at v0.6; entries before this point
live in `git log`.*

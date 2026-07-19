# Web Builder — Rebuilding the docs site

The docs site (`web-builder/assets/{index.html, app.js, docs.css, pages/*.html}`) is **disposable
instrumentation — it never ships.** Only `web-builder.css` ships. This doc exists for one reason: so the
skill is self-sufficient to reconstruct a docs site of the *same quality* from scratch, since that knowledge
otherwise lives only in the source. The docs are themselves **dogfooded** — every page is assembled from
`wb-*` primitives, and `docs.css` holds **only chrome the library has no primitive for** (the sidebar tree,
the demo stage + code block, the dual preview, the config drawer, the search dialog, and the token/type/font
specimens). If the library gains a primitive that covers a piece of chrome, the chrome is deleted and the page
dogfoods the primitive instead.

> **This doc is a best-effort, hand-kept snapshot** of `app.js` / `docs.css`. Unlike the component catalog
> (which `validate-sync.sh` checks against the CSS), nothing machine-validates this doc — so if the docs
> source changes, **re-sync it by hand**. It captures the *design* of the docs app (architecture, page grammar,
> chrome roster), enough to rebuild an equivalent — not a line-for-line mirror of the current code.

---

## 1. Architecture — one single-page app, three files

- **`index.html`** — a static shell, never regenerated. It holds: the `<head>` with a **pre-paint theme
  script** (below), the `.doc-shell` (sidebar + main + topbar), an empty `<main id="view">` the router fills,
  an empty `<div id="docfooter">`, the Config drawer (`.doc-config`), and the search dialog
  (`.wb-overlay.doc-search`). CSS + JS are injected with a `?v=Date.now()` cache-buster so local edits never
  show stale (see script in `<head>`).
- **`app.js`** — the whole engine: the `NAV` model (single source of truth), a hash router, per-page init,
  the Config playground, full-text search, theme cycling, the dual light/dark preview, and the auto-rendered
  pager + footer. Pages in `pages/` stay **markup-only — no shell, no `<script>`, no `<style>`.**
- **`docs.css`** — the chrome classes only (inventory in §5). Reuses `--wb-*` tokens so the docs follow the
  library's light/dark theme automatically.

**Router model:** `#/<id>` → `fetch("pages/<id>.html", { cache: "no-store" })` → inject into `#view`. Because
it `fetch()`es, the site **must be served over HTTP** (fetch fails on `file://`). Use `serve.py` (a
`SimpleHTTPRequestHandler` subclass that adds `Cache-Control: no-store`) so a plain reload shows edits with no
hard-refresh: `cd web-builder/assets && python3 serve.py` → http://127.0.0.1:8777.

---

## 2. The NAV model — single source of truth

One array drives the **sidebar tree**, the **router**, **route validation**, the **pager order**, the
**search index**, and the page↔group map. Shape: an array of groups, each `{ group, items: [{ id, label }] }`
(an item may carry `coming: true` to render a disabled "soon" stub).

```js
const NAV = [
  { group: "Nền tảng", items: [
    { id: "overview", label: "Tổng quan" },
    { id: "tokens",   label: "Design tokens" },
  ]},
  { group: "Hành động", items: [
    { id: "buttons",  label: "Buttons" },
    { id: "dropdown", label: "Dropdown / Menu" },
  ]},
];
// Derived once, right after NAV:
const ROUTES = {};                 // id -> item, for O(1) route lookup + validation
NAV.forEach(g => g.items.forEach(it => ROUTES[it.id] = it));
const DEFAULT_ROUTE = "overview";  // empty/unknown hash falls back here
```

`renderNav()` maps `NAV` → the `.doc-tree` markup; `loadRoute()` validates against `ROUTES` and redirects to
`DEFAULT_ROUTE` on a miss. Add a route to `NAV` and the sidebar, router, pager, and search pick it up — nothing
else to wire.

---

## 3. The page grammar — copy-paste skeleton

Every `pages/<id>.html` is a **markup-only fragment** (no `<html>/<head>/<body>`). It follows one grammar:
a page head, then `doc-sec` sections, each holding `doc-block` units, each holding a `demo` (live stage +
copyable code). Fill this in:

```html
<!-- 1 · Page head: eyebrow (= NAV group), h2 title, one-line intro -->
<div class="doc-page-head">
  <p class="doc-eyebrow">Nhập liệu</p>
  <h2>Switch</h2>
  <p>One-sentence description of the component and when to use it.</p>
</div>

<!-- Optional callout: outline + soft tint box, no left bar (leading emoji + text) -->
<div class="doc-note"><span>💡</span><div><b>Tip:</b> a note or gotcha worth surfacing.</div></div>

<!-- 2 · Section: a themed grouping. h3 title + optional lead paragraph -->
<section class="doc-sec">
  <h3>Cơ bản</h3>
  <p class="doc-sec__desc">Optional section lead — max ~68ch, muted.</p>

  <!-- 3 · Block: one variant. h4 label + optional sub-description -->
  <div class="doc-block">
    <h4>Default</h4>
    <p class="doc-block__desc">Optional per-variant note, e.g. what a modifier changes.</p>

    <!-- 4 · Demo unit: live stage on top, copyable code below -->
    <div class="demo">
      <div class="demo__stage">
        <label class="wb-switch"><input type="checkbox" checked /><span class="wb-switch__track"></span> Label</label>
      </div>
      <div class="demo__code"><button class="copy-btn">Copy</button><pre><code>&lt;label class="wb-switch"&gt;
  &lt;input type="checkbox" checked /&gt;&lt;span class="wb-switch__track"&gt;&lt;/span&gt; Label
&lt;/label&gt;</code></pre></div>
    </div>
  </div>

  <hr class="wb-divider" />  <!-- separators between blocks dogfood the library primitive -->
</section>
```

**Rules baked into the grammar:**
- `doc-eyebrow` text = the item's NAV group (kept in sync by hand).
- The **code sample is escaped HTML** inside `<pre><code>` and must mirror the live stage exactly. `.copy-btn`
  is picked up by a delegated click handler in `app.js` (copies the `<code>` text) — no per-page JS.
- Use library layout primitives inside the stage (`.wb-stack`, `.wb-cluster`, `.wb-grid`), **never** inline
  `display:flex`.
- **Demo density (design-principles §22):** `demo__stage` and `demo__code` are **not 1:1** — a stage may hold
  **several specimens** (a short + a long breadcrumb) under a **single** `demo__code`. Emit one code block per
  *pattern*; only add a second when the copy-paste snippet genuinely differs (a modifier, a different
  structure). Don't spin up a second `.demo` card to re-print near-identical code.
- Demo variants: `demo--plain` (alias, same look) and `demo--pop` (drops `overflow:hidden` so a popover/menu
  can escape the box — used on overlay pages).
- For a capsule/badge specimen row, `cap-row` + `cap-row__label` gives a labelled row of chips.

---

## 4. Data-attribute init hooks — how interactive demos boot

Pages ship **static markup only**; interactivity is attached generically. After the router injects a page it
calls `initPage(view)`, which queries for data-attributes and wires each match. To make a demo interactive,
add the attribute to the markup — no page script. The registry (in `initPage`):

| Attribute | Boots | Attribute | Boots |
|---|---|---|---|
| `data-swatches` | token colour swatches (from a fixed token list) | `data-sticky-fill` | fills a sticky-table demo with rows |
| `data-dual` | dual light/dark iframe preview (see §6) | `data-tree` | expand/collapse + drag-reparent tree |
| `data-sortable` / `data-sortable-rows` / `data-slotgrid` | drag-reorder list/grid, table rows, fixed-slot grid | `data-range-filter` | dual-slider ⇄ min/max inputs ⇄ summary |
| `data-colorpicker` | SV area + hue + hex colour picker | `data-calendar` / `data-timepicker` | month-grid date / scroll-column time picker |
| `data-mask` | format-while-typing masked input | `data-reveal` | password show/hide toggle |
| `data-picker-out` | writes a hosted picker's value into a field | `data-formatbar` | markdown format toolbar → textarea |

Global behaviours (dropdown/modal/toast/tabs/popover/collapse open-close, tree-node toggle, locked-switch
shake, sidebar + group toggles) are handled by **one delegated `document` click listener**, so injected pages
work with zero per-page wiring. `data-dual` snippets live in a `<template>` (see §6). Note in-page comments
that these drivers are docs-only glue — a real app maps the same classes onto Radix / dnd-kit / a date lib.

---

## 5. Docs-chrome class inventory (`docs.css`)

Non-`wb-*` classes — the chrome the library has no primitive for. Compact roster by area:

| Class | Role |
|---|---|
| `doc-shell` | flex wrapper: sidebar + main column, `min-height:100vh` |
| `doc-side` | sticky left sidebar; the ONE divider is its right border; off-canvas drawer < 900px |
| `doc-brand` · `__mark` · `__name` · `__ver` | sidebar brand block (logo tile + name + version) |
| `doc-tree` · `__group` · `__head` · `__caret` · `__items` · `__link` · `__badge` | the grouped, collapsible nav tree; `__head` is a collapse button (caret on the RIGHT); `__link.is-active` / `.is-coming` |
| `doc-main` | right column (flex:1) |
| `doc-topbar` | sticky blurred header; holds `h1`, `.spacer`, search/config/theme buttons |
| `doc-side-toggle` | panel-icon button that hides the sidebar (desktop) / opens the drawer (mobile) |
| `theme-btn` · `doc-icon-btn` | pill theme cycler; round config icon-button |
| `doc-content` | centered page column (`max-width:980px`), where injected pages render |
| `doc-eyebrow` | uppercase kicker above a page/section title |
| `doc-page-head` (`h2`,`p`) | page title block |
| `doc-sec` · `doc-sec__desc` | a page section + its muted lead paragraph |
| `doc-block` · `doc-block__desc` | a variant unit within a section + its sub-description |
| `doc-note` | outline + soft-tint callout box (no left bar) |
| `doc-sep` | neutral separator glyph (→ / ↔) between inline chips |
| `doc-hero` (`h2`,`p`) | larger title block, overview page only |
| `nav-card` · `__t` · `__d` | link/summary card grid tile (overview, cross-links) |
| `demo` · `demo__stage` · `demo__code` · `demo--plain` · `demo--pop` | the demo container: live stage (canvas bg) + code block; `--pop` lets overlays escape |
| `copy-btn` | copy-to-clipboard button inside `demo__code` |
| `cap-row` · `cap-row__label` | labelled row of capsule/badge specimens |
| `dual` · `dual__panel` · `dual__cap` · `dual__frame` | side-by-side light/dark iframe preview |
| `swatch` · `__chip` · `__meta` · `__name` · `__val` | token colour swatch tile |
| `tier` · `__item` · `__n` · `__t` · `__d` | colour-ladder tier cards |
| `type-scale` · `type-row` · `__meta` · `__sample` · `weight-cell` · `__n` · `__s` | typography specimens |
| `font-card` (+ `__top`,`__name`,`__tag`,`__meta`,`__big`,`__mid`,`__nums`) | font specimen card |
| `chart-grid` · `lay-box` | responsive chart-card grid; layout-demo filler tile |
| `doc-coming` | dashed "coming soon" / load-error placeholder |
| `doc-config` (+ `__head`,`__title`,`__sub`,`__body`,`__group`,`__gtitle`,`__row`,`__label`,`__color`,`__swatch`,`__out`,`__foot`) | the slide-in Config drawer + its rows |
| `doc-search-trigger` (+ `__label`,`__kbd`) | topbar search button |
| `doc-search` (+ `__box`,`__bar`,`__input`,`__results`,`__hit`,`__hl`,`__hint`,`__foot`,`__legend`,`__count`) | the command-palette search dialog (built on `.wb-overlay` + `.wb-modal`) |

---

## 6. App features to reproduce (spec, not code)

**Theme cycling.** Three modes stored in `localStorage["wb-theme"]`: `system` (default, follows the OS via
`matchMedia("(prefers-color-scheme: dark)")`), `light`, `dark`. The topbar `theme-btn` cycles
system→light→dark; `.dark` on `<html>` is the switch. In `system` mode the app live-tracks OS changes via the
media-query `change` event. **FOUC guard:** a tiny inline script in `index.html`'s `<head>` reads the stored
mode *before paint* and adds `.dark` up front, so the page never flashes the wrong mode.

**Config playground.** A slide-in `.doc-config` drawer (opened from `#configBtn`) that edits docs-facing
`--wb-*` tokens **live** by setting CSS custom properties on `:root` — it **never** touches `web-builder.css`,
so shipped primitives are untouched. Groups/rows come from a `CONFIG_GROUPS` data model; row types are
`range`, `color` (a `wb-colorpicker` in a popover), `font`, `shadow` (presets), `select`, and `corner` (a
radius preset that rewrites every radius token). Changes mirror into the dual-preview iframes by hand (custom
props don't cross the iframe boundary). **Export:** builds a Markdown blob with a `:root { … }` (or `.dark { … }`)
CSS block of the overrides and downloads it as `web-builder-tweaks.md` — the user pastes it into the CSS or
hands it to an AI. Reset clears every override.

**Full-text search.** A `⌘K` / `/` command-palette dialog (built on `.wb-overlay` + `.wb-modal`). The index is
built **lazily on first open**: `fetch()` every non-coming page, strip tags/scripts to plain text, cache it.
Matching is case-insensitive substring (label matches rank above body matches); results show title + group +
a highlighted snippet. Keyboard: ↑/↓ move the active row, ↵ navigates (`location.hash`), Esc closes; mouse
hover syncs the active row.

**Dual light/dark preview (`renderDual`).** For each `[data-dual]`, read the inner `<template>` snippet and
render two isolated `<iframe>`s side by side. Each iframe's `srcdoc` is a minimal HTML doc that loads
`web-builder.css`, sets `<html class="dark">` (or not), pads the body, and drops the snippet in. On load,
current Config tweaks are pushed in and the iframe auto-sizes to its content. Isolation is the point: a viewer
on one theme still sees the other.

**Auto-rendered pager + footer.** `PAGE_ORDER` (flattened `NAV`) drives a prev/next `.wb-pager` appended to the
foot of **every** page by the router (`renderPager(id)`); `[` and `]` jump prev/next (guarded so typing in a
field never triggers them). `renderFooter()` fills `#docfooter` **once** at boot with a `.wb-footer` (both
dogfood shipped primitives — the app.js driver an app would write).

---

## 7. How to add a page

Two steps (part of the 6-place sync in `CLAUDE.md` / `/wb-change`):

1. Create `pages/<id>.html` using the §3 grammar (markup only).
2. Add `{ id, label }` to the right group in `NAV` (`app.js`).

The router (`ROUTES`), sidebar (`renderNav`), pager (`PAGE_ORDER`), and search index all derive from `NAV`, so
they pick it up automatically — nothing else to wire. (The other four sync places are `web-builder.css`,
`components-catalog.md`, `SKILL.md`, and — if relevant — `design-principles.md` / `integration.md` /
`bootstrap-comparison.md`.) `validate-sync.sh` enforces `routes == pages` and no per-page `<style>`.

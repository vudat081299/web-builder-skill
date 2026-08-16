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
  script** (below), then the **shipped app shell** (`web-builder.css`, CSS section 52) — a `.wb-shell` whose full-width
  `.wb-navbar--sticky --glass` bar sits OVER a `.wb-shell__body` (the `.wb-shell__side` rail + the
  `.wb-shell__main` column), so the bar always spans the whole width and the rail never shrinks it — an empty
  `<main id="view" class="wb-container wb-container--pad">` the router fills, an empty `<div id="docfooter">`,
  the Config drawer (`.doc-config`), and the search dialog (`.wb-overlay.doc-search`). CSS + JS are injected
  with a `?v=Date.now()` cache-buster so local edits never show stale (see script in `<head>`).
  **The docs own no frame of their own**: shell, rail, bar and content column are all library primitives, and
  `docs.css` only retunes three tokens (`--wb-shell-h` / `--wb-navbar-h` / `--wb-sidenav-w`). If you catch
  yourself declaring a frame rule in `docs.css`, it belongs upstream in CSS section 52 instead.
- **`app.js`** — the whole engine: the `SECTIONS` model (single source of truth), a hash router, per-page init,
  the Config playground, full-text search, theme cycling, the dual light/dark preview, and the auto-rendered
  pager + footer. Pages in `pages/` stay **markup-only — no shell, no `<script>`, no `<style>`.**
- **`docs.css`** — the chrome classes only (inventory in §5). Reuses `--wb-*` tokens so the docs follow the
  library's light/dark theme automatically.

**Router model:** `#/<id>` → `fetch("pages/<id>.html", { cache: "no-store" })` → inject into `#view`. Because
it `fetch()`es, the site **must be served over HTTP** (fetch fails on `file://`). Use `serve.py` (a
`SimpleHTTPRequestHandler` subclass that adds `Cache-Control: no-store`) so a plain reload shows edits with no
hard-refresh: `cd web-builder/assets && python3 serve.py` → http://127.0.0.1:8777.

---

## 2. The SECTIONS model — single source of truth

One array drives the **section switcher** (a dropdown at the top of the sidebar), the per-section **sidebar
tree**, the **router**, **route validation**, the **pager order** (scoped *within* a section), the **search
index** (global, spans every section), and the page↔group map. Shape: an array of **sections**, each
`{ id, title, icon, … }`. The `components` section carries grouped headings via
`groups: [{ group, items: [{ id, label }] }]`; the flatter `design` / `project` sections use a headingless
`items: [{ id, label }]` (an item may carry `coming: true` to render a disabled "soon" stub).

> **Why two shapes.** `validate-sync.sh` CHECK 10 greps every `group: "…"` in `app.js` and requires each to
> appear in `SKILL.md`'s *Current scope* (the component-family list). So **only the `components` section uses
> `group:` labels** — they ARE that scope; `design` / `project` are docs-site buckets kept flat (no `group:`)
> so they never leak into the skill's scope. And sections name themselves with `title:` (not `label:`) so their
> `id: "…"` lines don't trip CHECK 1's `id: "…", label:` route parser.

> **Locale.** Everything `app.js` / `index.html` render is **chrome → English**: these `title:` / `group:` /
> `label:` strings, the topbar, the search dialog, the Tweak panel, the footer. Everything a `pages/*.html`
> *says* is **content → Vietnamese-first** (§20 — copy is data). The one string that crosses the line is a
> page's `wb-eyebrow`: it echoes that page's `group:` label, so renaming a group means renaming the eyebrow
> on every page in it (and SKILL.md's scope header, which CHECK 10 grep-matches).

```js
const SECTIONS = [
  { id: "design", title: "Design", icon: "format_paint", items: [
    { id: "overview", label: "Overview" },
    { id: "tokens",   label: "Design tokens" },
  ]},
  { id: "components", title: "Components", icon: "widgets", groups: [
    { group: "Actions", items: [
      { id: "buttons",  label: "Buttons" },
      { id: "dropdown", label: "Dropdown / Menu" },
    ]},
  ]},
  { id: "project", title: "Project & skill", icon: "deployed_code", items: [
    { id: "skill",     label: "Product & skill" },
    { id: "decisions", label: "Decisions & trade-offs" },
  ]},
];
// Derived once, right after SECTIONS:
function groupsOf(s) { return s.groups || [{ group: "", items: s.items || [] }]; } // flat → 1 headingless group
function itemsOf(s)  { return groupsOf(s).flatMap(g => g.items).filter(it => !it.coming); }
const ROUTES = {}, SECTION_OF = {}, SECTION_FIRST = {};    // id→item · id→section · section→first id
SECTIONS.forEach(s => { const it = itemsOf(s); SECTION_FIRST[s.id] = it[0] ? it[0].id : "";
  it.forEach(x => { ROUTES[x.id] = x; SECTION_OF[x.id] = s.id; }); });
const DEFAULT_ROUTE = "overview";  // empty/unknown hash falls back here
```

`renderSecSwitch(id)` renders the sidebar-top dropdown (dogfoods `.wb-dropdown` + `.wb-menu`); picking a
section navigates to its `SECTION_FIRST`. `renderNav(id)` maps **one** section → the `.doc-tree` markup (a flat
section renders one `--flat` headingless group). `loadRoute()` validates against `ROUTES`, and when a route's
`SECTION_OF` differs from the mounted section it re-renders the switcher + tree. Add a route to the right
section and the switcher, tree, router, pager, and search pick it up — nothing else to wire.

---

## 3. The page grammar — copy-paste skeleton

Every `pages/<id>.html` is a **markup-only fragment** (no `<html>/<head>/<body>`). It follows one grammar:
a page head, then `wb-section` sections, each holding `wb-block` units, each holding a `demo` (live stage +
copyable code).

Everything in that grammar **except `demo*` / `copy-btn` is a shipped primitive** (CSS section 52) — the docs page
scaffold *is* the library's page scaffold. That's deliberate: a page laid out correctly here is laid out
correctly in a real build, and the rhythm can't drift between the two. Fill this in:

```html
<!-- 1 · Page head: eyebrow (= group, or section title for a flat page), title, one-line intro -->
<div class="wb-page-head">
  <p class="wb-eyebrow">Inputs</p>
  <h2>Switch</h2>
  <p>One-sentence description of the component and when to use it.</p>
</div>

<!-- Optional callout: the shipped info alert; .doc-note adds only page-flow margin + a top-aligned icon -->
<div class="wb-alert wb-alert--info doc-note"><span>💡</span><div><b>Tip:</b> a note or gotcha worth surfacing.</div></div>

<!-- 2 · Section: a themed grouping. Heading + optional lead paragraph -->
<section class="wb-section">
  <h3>Cơ bản</h3>
  <p class="wb-section__desc">Optional section lead — capped at --wb-measure (~68ch), muted.</p>

  <!-- 3 · Block: one variant. Sub-heading + optional sub-description -->
  <div class="wb-block">
    <h4>Default</h4>
    <p class="wb-block__desc">Optional per-variant note, e.g. what a modifier changes.</p>

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
- `wb-eyebrow` text = the item's `group` (or, for a flat design/project page, its section title) — kept in sync by hand.
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

Non-`wb-*` classes — the chrome the library has no primitive for. Compact roster by area.

**What is NOT here any more, and why.** The page **frame**, the heading **rhythm** and the document
**baseline** used to be docs chrome: shell, rail, topbar, content column, eyebrow / page-head / section /
block, the note box, the link tiles — plus `* { box-sizing }`, the `body {}` font/colour/line-height block
and `a { color: inherit }`. All of it was folded into the library (CSS section 52 for the frame, 53 for the
baseline) because an app built with this skill needs exactly that and had no way to get it — the docs looked
composed and a fresh build didn't. The mapping, if you meet the old names:

| was (docs.css) | now (shipped) |
|---|---|
| `* { box-sizing: border-box }` | `:where([class^="wb-"], [class*=" wb-"])` — scoped to the library, never the host page |
| `body { font · bg · color · line-height · smoothing }` | **`.wb-app`** on `<body>` (`.wb-shell` carries the same) |
| `a { color: inherit }` | `:where(.wb-app, .wb-shell) :where(a)` — zero specificity, so components still win |
| `doc-shell` · `doc-body` · `doc-main` | `wb-shell` · `wb-shell__body` · `wb-shell__main` |
| `doc-side` (+ off-canvas < 900px) | `wb-shell__side wb-shell__side--stack` (drawer + scrim ship too; `--stack` because this rail pins the section switcher above the scrolling tree — the tree is the child carrying `.wb-scroll-y`) |
| `doc-topbar` | `wb-navbar wb-navbar--sticky wb-navbar--glass` (a `.doc-topbar` hook keeps two docs-only tweaks) |
| `doc-content` | `wb-container wb-container--pad` (docs set `--wb-container-max: 980px` + 32px side gutters) |
| `doc-eyebrow` · `doc-page-head` · `doc-sec` · `doc-block` | `wb-eyebrow` · `wb-page-head` · `wb-section` · `wb-block` |
| `doc-hero` | `wb-page-head--lg` |
| `doc-note` | `wb-alert wb-alert--info` (`.doc-note` survives as page-flow margin + top-aligned icon) |
| `nav-card` · `__t` · `__d` | `wb-card wb-card--pad` · `wb-card__title` · `wb-card__sub` |
| `.doc-shell.is-side-hidden` | `.wb-shell.is-side-collapsed` |

The still-docs-only roster:

| Class | Role |
|---|---|
| `doc-secswitch` · `-wrap` · `__btn` · `__ico` · `__label` | the **section switcher** dropdown at the top of the sidebar (dogfoods `.wb-dropdown` + `.wb-menu`); swaps which section's tree is shown |
| `doc-brand` · `__mark` · `__text` · `__name` · `__ver` | brand block in the **topbar** (logo tile + name + version); it **is** the sidebar toggle (`data-side-toggle` — click the W) |
| `doc-tree` · `__group` (`--flat`) · `__head` · `__caret` · `__items` · `__link` · `__badge` | one section's nav tree; `__head` is a collapse button (caret on the RIGHT); a flat section renders one `--flat` headingless group; `__link.is-active` / `.is-coming` |
| `doc-topbar` · `doc-topbar__cap` | hook on the shipped bar for the two docs deviations: a roomier gap/padding, and hiding the "Minimalist UI kit" cap on phones |
| `theme-btn` · `doc-icon-btn` | pill theme cycler; round config icon-button |
| `doc-content` | consumer tuning of the shipped content column: `--wb-container-max: 980px` + roomier 32px side gutters (18px under 900px) |
| `doc-note` | margin + top-aligned icon on the shipped info alert (page flow, not looks) |
| `doc-sep` | neutral separator glyph (→ / ↔) between inline chips |
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

**Auto-rendered pager + footer.** `sectionOrder(id)` (the current section's flattened items) drives a prev/next
`.wb-pager` appended to the foot of **every** page by the router (`renderPager(id)`) — so the pager walks
*within* a section (cross-section jumps go through the switcher); `[` and `]` jump prev/next (guarded so typing
in a field never triggers them). `renderFooter()` fills `#docfooter` **once** at boot with a `.wb-footer` (both
dogfood shipped primitives — the app.js driver an app would write).

---

## 7. How to add a page

Two steps (part of the 6-place sync in `CLAUDE.md` / `/wb-change`):

1. Create `pages/<id>.html` using the §3 grammar (markup only).
2. Add `{ id, label }` to the right **section** in `SECTIONS` (`app.js`) — a component goes under the right
   `group:` in the `components` section; a design/project page goes in that section's flat `items:`.

The router (`ROUTES`), switcher + sidebar (`renderSecSwitch` / `renderNav`), pager (`sectionOrder`), and search
index all derive from `SECTIONS`, so they pick it up automatically — nothing else to wire. (The other four sync
places are `web-builder.css`,
`components-catalog.md`, `SKILL.md`, and — if relevant — `design-principles.md` / `integration.md` /
`bootstrap-comparison.md`.) `validate-sync.sh` enforces `routes == pages` and no per-page `<style>`.

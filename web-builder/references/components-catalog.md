# Web Builder — Component Catalog

The lookup table for "I'm building X → use this, here's the markup." Copy the snippet,
swap the data, done. Do **not** redesign from scratch — that's the whole point of this
library. Each is rendered live on its own page under `assets/pages/` (served over HTTP —
see SKILL.md).

Scope so far: foundations (**colour**, **tokens**, **typography**, **fonts**, **border & radius**,
**Config/tweak** playground); **Buttons** (+ button-group), **Dropdown**; **inputs** — one primitive per
page: **Text input**, **Select**, **Textarea**, **Checkbox/Radio**, **Switch**, **Range/Slider**,
**File/Upload**, **Colour**; **Card**, **Tables**, **Filter bar**, **List group**, **Stat/KPI**, **Capsules**, **Tags**,
**Avatar**; **Alert**, **Toast**, **Modal**, **Drawer/Offcanvas**, **Progress**, **Skeleton**,
**Empty state**, **Tooltip**; **Tabs** (underline / pill / boxed), **Breadcrumb**, **Pagination**,
**Accordion**, **Divider**; **Charts** (line/area, bars, **combo bar+line**, **horizontal ranked bars**,
donut + thin/rounded + progress ring, budget, sparkline, mono/blue schemes + count-aware ramps); a
drag-and-drop **Tree**; a flat **Sortable** list /
grid / **table rows**; and **Grid/Layout** utilities (cluster / grid / stack / container / ratio). Coverage
tracks **Bootstrap**'s primitive set, re-cut minimalist. Icons come from an **icon font** (Material Symbols, loaded
by `@import` in `web-builder.css` — swap `--wb-icon-font` to use another set); tones use outline + soft
background (no left-accent bar on components — documented as a non-default variant on the Border page).

Every component is themed off tokens and works in light + dark. The interactive ones
(dropdown, modal, tabs, toast) ship as **CSS + a tiny vanilla toggle** in the docs; in a
real app, drive them with a behaviour engine (Radix/shadcn etc.) and keep the `wb-*` classes
for the look (see `integration.md`).

---

## Quick decision guide

| You're building… | Use | Section |
|---|---|---|
| Any clickable action (save, add, cancel, delete) | **Button** | [Buttons](#buttons) |
| A sign-in-with-provider button (Apple / Google) | **Button** — social | [Buttons](#buttons) |
| A status / category / method label inside a cell | **Capsule** | [Capsules](#capsules) |
| A free-form label a user pins to a transaction (`#…`) | **Tag** | [Tags](#tags) |
| A dashboard KPI (balance, income, spend, change %) | **Stat card** | [Stat cards](#stat--kpi-cards) |
| A list of accounts, categories, simple records | Table — basic | [Tables](#tables) |
| A transaction / activity feed with amounts + status | Table — transactions (hero) | [Tables](#tables) |
| A budget / breakdown with many rows | Table — `--striped --compact` | [Tables](#tables) |
| A long scrollable list, header must stay visible | Table — `--sticky` | [Tables](#tables) |
| Debts / receivables / anything with overdue-vs-paid | Table + row-state + colour | [Tables](#tables) |
| A totals / summary line under a table | `<tfoot>` row | [Tables](#tables) |
| A toolbar to search + filter a table/list (tag, status, amount range) | **Filter bar** | [Filter bar](#filter-bar) |
| Filter by amount range (≥ / ≤ / between), a `#tag`, or a status | **Filter bar** tokens | [Filter bar](#filter-bar) |
| A data-entry form (add/edit transaction, settings) | **Form controls** | [Forms](#form-controls) |
| A money input, a category picker, a yes/no setting | input-group / select / switch | [Forms](#form-controls) |
| A slider for a budget cap / threshold | **Range** | [Range](#range--slider) |
| Attach a statement / receipt (button or drop area) | **File / dropzone** | [File](#file--upload) |
| Pick a category / label colour | **Colour input** | [Colour](#colour-input) |
| A settings / accounts list (one item per row) | **List group** | [List group](#list-group) |
| A content container / section with header + body | **Card** | [Card](#card) |
| Show one transaction / bill as a torn-paper slip | **Receipt** (hoá đơn) | [Receipt](#receipt) |
| A menu of actions off a button (⋯, "Thao tác") | **Dropdown** | [Dropdown](#dropdown--menu) |
| An inline message inside a page/form | **Alert** | [Alert](#alert--banner) |
| A transient "saved / failed" notification | **Toast** | [Toast](#toast) |
| A confirm / focused task over a dimmed screen | **Modal** | [Modal](#modal--dialog) |
| A slide-in filters / detail / side-menu panel | **Drawer** | [Drawer](#drawer--offcanvas) |
| Switch between views, or a Thu/Chi segmented toggle | **Tabs** | [Tabs](#tabs) |
| The top app bar (brand · links · actions) | **Navbar** | [Navbar](#navbar--nav-menu) |
| A set of page-navigation links (a menu) | **Nav** (`.wb-nav`) | [Navbar](#navbar--nav-menu) |
| The left navigation rail of an app shell | **Sidebar** (`.wb-sidenav`) | [Sidebar](#sidebar-side-nav) |
| A segmented filter of joined buttons (Ngày/Tuần/Tháng) | **Button group** | [Button group](#button-group) |
| Budget usage / completion ratio | **Progress** | [Progress](#progress) |
| A loading bar with no known % (loading / syncing) | **Progress** `--loading` | [Progress](#progress) |
| A loading placeholder before data arrives | **Skeleton** | [Skeleton](#skeleton) |
| A "no data yet" / empty list screen | **Empty state** | [Empty](#empty-state) |
| A short hint on hover / focus | **Tooltip** | [Tooltip](#tooltip) |
| The path "where am I" above a page | **Breadcrumb** | [Breadcrumb](#breadcrumb) |
| Page through a long list/table | **Pagination** | [Pagination](#pagination) |
| A person / initials / member group | **Avatar** | [Avatar](#avatar) |
| Collapsible FAQ / sections | **Accordion** | [Accordion](#accordion) |
| A visual separator (solid / dashed / dotted / fade / tone / **ray** / labelled) | **Divider** | [Divider](#divider) |
| Border widths / radii / dashed / outline-tone conventions | **Border** | [Border](#border--radius) |
| A spending line, income-vs-expense bars, **combo bar+line**, category donut, sparkline | **Charts** | [Charts](#charts) |
| Ranking many categories (top spend / top debt) | **Charts** — horizontal ranked bars | [Charts](#charts) |
| Budget usage per category (progress + over-budget) | **Charts** (budget) / Progress | [Charts](#charts) |
| Nested categories (drag to reorder / reparent) | **Tree** | [Tree](#tree) |
| Reorder a flat list or grid of cards (drag) | **Sortable** | [Sortable](#sortable-list--grid) |
| Reorder rows inside a data table (drag) | **Sortable table** (`--sortable`) | [Sortable](#sortable-list--grid) |
| Arrange in a row/column, align (top/center/bottom, left/right), wrap, equal widths | **Grid / Layout** utilities | [Layout](#grid--layout) |
| A UI icon (chevron, close, drag, search…) | **Icon** (`.wb-ico`) | [Icons](#icons) |
| Fine-tune tokens live + export a `.md` | **Config** (docs playground) | [Config](#config--tweak) |

---

## Buttons

`.wb-btn` + optional fill + tone + size. Default (no modifier) is the **neutral primary**
(near-black in light, near-white in dark) — the primary action is *not* a brand colour.

```
FILL:  (default solid neutral) · --secondary · --outline · --ghost
TONE:  --danger · --success        (only meaningful actions: delete, confirm payment)
SIZE:  (default) · --sm · --lg      SHAPE: --icon (square) · --block (full width)
STATE: disabled attr / .is-disabled · .is-loading (+ a <span class="wb-spinner">)
```

**Choosing:** one **primary** per view (the main action) → `wb-btn`. Everything else →
`--secondary` / `--outline` / `--ghost`. Reserve `--danger` for destructive, `--success`
for an explicit money-received confirmation. Don't put two solid neutral buttons side by
side — pair primary with a ghost/secondary.

```html
<button class="wb-btn">Lưu giao dịch</button>
<button class="wb-btn wb-btn--ghost">Huỷ</button>
<button class="wb-btn wb-btn--secondary wb-btn--icon" aria-label="Sửa">✎</button>
<button class="wb-btn wb-btn--danger">Xoá</button>
<button class="wb-btn is-loading"><span class="wb-spinner"></span> Đang lưu…</button>
```

Icon-only buttons **must** have `aria-label`. The spinner inherits the button's text
colour, so it works on any variant.

**Social login** — reuse `.wb-btn` + a brand logo `<svg>` on the left, usually `--block` (full
width) in a `.wb-stack`. Apple = neutral primary `wb-btn` (black bg / white logo via
`fill="currentColor"` — auto-flips per theme); Google = `--secondary` with the 4-colour "G". The
provider logo is the **one** allowed colour exception; the rest of the button stays neutral.

```html
<div class="wb-stack" style="max-width:300px">
  <button class="wb-btn wb-btn--block">
    <svg width="17" height="17" viewBox="0 0 384 512" fill="currentColor"><path d="…apple…"/></svg>
    Tiếp tục với Apple
  </button>
  <button class="wb-btn wb-btn--secondary wb-btn--block">
    <svg width="17" height="17" viewBox="0 0 48 48"><!-- Google G, 4 màu --></svg>
    Tiếp tục với Google
  </button>
</div>
```

---

## Button group

`.wb-btn-group` joins `.wb-btn` children into one segmented control (shared 1px seams, rounded
outer ends). Works with any variant; `--outline` / `--secondary` read best. Mark the chosen one
`.is-active`. For a calm single-select toggle, `.wb-tabs--pill` is often nicer.

```html
<div class="wb-btn-group">
  <button class="wb-btn wb-btn--outline is-active">Ngày</button>
  <button class="wb-btn wb-btn--outline">Tuần</button>
  <button class="wb-btn wb-btn--outline">Tháng</button>
</div>
```

## Stat / KPI cards

`.wb-stat` inside `.wb-stat-grid` (auto-fit responsive grid). Neutral card; the only
colour is the delta — `--up` (green) for a rise, `--down` (red) for a drop, because the
*direction* is the meaning. Use for the top-of-dashboard summary (balance, income, spend).

```html
<div class="wb-stat-grid">
  <div class="wb-stat">
    <div class="wb-stat__top">
      <span class="wb-stat__label">Tổng số dư</span>
      <span class="wb-stat__icon">◈</span>          <!-- optional -->
    </div>
    <div class="wb-stat__value">47.590.000&nbsp;₫</div>
    <div class="wb-stat__foot">
      <span class="wb-stat__delta wb-stat__delta--up">↑ 12,4%</span> so với tháng trước
    </div>
  </div>
  <!-- …more .wb-stat… -->
</div>
```

The `__foot` can hold a delta, a plain caption, or a capsule (e.g. a danger capsule for
"2 quá hạn"). Keep values in `tabular-nums` (the class already does this).

---

## Capsules

`.wb-cap` + optional **FILL** modifier + optional **TONE** modifier. Default (no
modifier) is soft grey — the most common case.

```
FILL:  (default soft grey) · --solid · --outline · --elevated
TONE:  (default neutral)   · --success · --danger · --warning · --info
COLOUR:--tinted + style="--wb-cap-color:#hex"   (custom category hue, like tags)
SIZE:  (default) · --sm · --lg
DOT:   add <span class="wb-cap__dot"></span> as first child for a status dot
```

**Choosing:**
- **Category / classification** (not a status) → neutral, no tone: `class="wb-cap"`.
- **Status that should stay calm** → tone, soft (default fill): `wb-cap wb-cap--success`.
- **Status that must shout** (overdue, failed) → tone + solid: `wb-cap wb-cap--danger wb-cap--solid`.
- **A neutral chip that needs to pop off a busy surface** → `wb-cap wb-cap--elevated`.

```html
<!-- category (neutral, tier 1) -->
<span class="wb-cap">Ăn uống</span>

<!-- calm status (tier 3, soft) -->
<span class="wb-cap wb-cap--success"><span class="wb-cap__dot"></span> Đã trả</span>

<!-- loud status (tier 2, solid) -->
<span class="wb-cap wb-cap--danger wb-cap--solid">Quá hạn</span>

<!-- neutral emphasis on a busy row (white + grey shadow) -->
<span class="wb-cap wb-cap--elevated">Xuất CSV</span>

<!-- coloured category chip (classification only — pass one variable) -->
<span class="wb-cap wb-cap--tinted" style="--wb-cap-color:#4f46e5"><span class="wb-cap__dot"></span> Ăn uống</span>
```

Status → tone mapping (keep it consistent across the app):
`Đã trả / Đã nhận / Hoàn tất` → **success** · `Chờ / Sắp đến hạn` → **warning** ·
`Quá hạn / Thất bại / Nợ xấu` → **danger** · `Đang xử lý` → **info` · everything else → **neutral**.

---

## Tags

`.wb-tag` — a **`#`-prefixed** label a user pins to a transaction (free-form, unlike a
fixed category). Same family as capsules; the leading `#` is added by CSS.

```
SHAPE:  (pill, default) · --rect · --notch    (notch = physical-tag look, with a punch hole)
TONE:   (neutral) · --success · --danger · --warning · --info
COLOUR: --tinted + style="--wb-tag-color:#hex"   (a custom per-category hue)
EMPH:   --solid  (tier-2 full colour; pair with a tone or --tinted)
SIZE:   (default) · --sm · --lg      REMOVE: add <button class="wb-tag__x">×</button>
GROUP:  wrap several in .wb-tags   (flex-wrap row)
```

**Choosing:** most tags are **neutral** (classification, not status). Give a tag its own
hue only when the category genuinely has one in the app — pass it via the one variable so
both themes stay correct. Reserve `--solid` for a tag that must shout.

```html
<!-- neutral, and a category with its own colour -->
<span class="wb-tag">an-uong</span>
<span class="wb-tag wb-tag--tinted" style="--wb-tag-color:#0d9488">du-lich</span>

<!-- semantic + removable, grouped on a transaction -->
<div class="wb-tags">
  <span class="wb-tag wb-tag--success">hoan-tien</span>
  <span class="wb-tag wb-tag--notch">tien-mat</span>
  <span class="wb-tag">tet-2027<button class="wb-tag__x" aria-label="Xoá">×</button></span>
</div>
```

**Tag vs capsule:** a *capsule* carries a fixed meaning the app defines (status /
classification); a *tag* is a user-attached label and always shows `#`.

---

## Tables

Anatomy (all parts optional except the `<table>`):

```html
<div class="wb-card">                       <!-- surface + border + radius + shadow -->
  <div class="wb-table-head">…title / actions…</div>
  <div class="wb-table-scroll">             <!-- horizontal scroll; bound height for sticky -->
    <table class="wb-table">…</table>
  </div>
  <div class="wb-table-foot">…pagination…</div>
</div>
```

**Modifiers on `.wb-table`:** `--striped` · `--bordered` · `--compact` · `--sticky` ·
`--no-hover` (hover is on by default).

**Cell helpers:** `wb-num` (right-align + tabular) · `wb-num--pos|--neg|--strong` ·
`wb-cell-strong` · `wb-cell-muted` · `wb-cell-sub` (small second line).

**Row states (use colour only when it means something):**
`wb-row--danger` · `wb-row--warning` · `wb-row--success` — a subtle background tint
(no left accent bar; pair with a coloured capsule in the row for an explicit label). For
overdue debts, bad debt, over-budget, etc.

### Snippet — transaction row (the hero pattern)

```html
<table class="wb-table">
  <thead>
    <tr><th>Ngày</th><th>Nội dung</th><th>Danh mục</th><th class="wb-num">Số tiền</th><th>Trạng thái</th></tr>
  </thead>
  <tbody>
    <tr>
      <td class="wb-cell-muted">14/07</td>
      <td>
        <span class="wb-cell-strong">Lương tháng 7</span>
        <span class="wb-cell-sub">Công ty ABC</span>
      </td>
      <td><span class="wb-cap wb-cap--success">Thu nhập</span></td>
      <td class="wb-num wb-num--pos">+25.000.000&nbsp;₫</td>
      <td><span class="wb-cap wb-cap--success"><span class="wb-cap__dot"></span> Đã nhận</span></td>
    </tr>
  </tbody>
  <tfoot>
    <tr><td colspan="3">Ròng trong kỳ</td><td class="wb-num wb-num--pos">+21.360.000&nbsp;₫</td><td></td></tr>
  </tfoot>
</table>
```

### Snippet — sticky, scrollable long list

```html
<div class="wb-table-scroll" style="max-height: 320px;">
  <table class="wb-table wb-table--sticky wb-table--compact">…</table>
</div>
```

### Snippet — debt / receivables (meaningful colour)

```html
<tr class="wb-row--danger">
  <td class="wb-cell-strong">Nguyễn Văn A</td>
  <td class="wb-cell-muted">01/06/2026</td>
  <td class="wb-num wb-num--strong">5.000.000&nbsp;₫</td>
  <td><span class="wb-cap wb-cap--danger wb-cap--solid">Quá hạn 43 ngày</span></td>
</tr>
```

---

## Filter bar

A toolbar for narrowing a table / list — a search box + a multi-select field dropdown + removable
**tokens** (tag, status, amount range, date). Built from `input`, `menu`, `cap`, `tag`; this section
adds only `.wb-filterbar`, the `.wb-filter-token` chip, and the dashed `.wb-filter-add` trigger.
Behaviour (open / apply / remove) is the app's — the classes are the visuals. Colour ladder: the bar
and tokens stay grey chrome; a token borrows a **soft** status tone (`--success` / `--danger` / …)
only when it *is* a status filter.

```html
<div class="wb-filterbar">
  <div class="wb-input-group wb-filterbar__search">
    <span class="wb-input-group__addon"><span class="wb-ico wb-ico--sm">search</span></span>
    <input class="wb-input" type="search" placeholder="Tìm giao dịch…" />
  </div>

  <span class="wb-filter-token wb-filter-token--success">
    <span class="wb-filter-token__key">Trạng thái</span>
    <span class="wb-filter-token__val">Đã trả</span>
    <button class="wb-filter-token__x" aria-label="Bỏ lọc"></button>
  </span>
  <span class="wb-filter-token">
    <span class="wb-filter-token__key">Số tiền</span>
    <span class="wb-filter-token__val">≥ 1.000.000 ₫</span>
    <button class="wb-filter-token__x" aria-label="Bỏ lọc"></button>
  </span>

  <button class="wb-filter-add"><span class="wb-ico wb-ico--sm">add</span> Thêm bộ lọc</button>
  <span class="wb-filterbar__count">24 giao dịch</span>
</div>
```

Per-field editor = a padded menu (`.wb-menu.wb-filter-pop`): **amount** uses a `.wb-range-filter` — a
dual-handle slider (`.wb-range-dual`) + min/max inputs + a plain-language summary, all synced; **tag** & **status** use multi-select checkbox rows
(`.wb-check.wb-menu__item`) that show the value with a real `tag` / `cap`.

---

## List group

`.wb-list` — a bordered, hairline-divided list (accounts/wallets, settings, a picker). Lighter than
a table when each row is ONE item, not columns. `__item--link` rows hover, `.is-active` / `.is-disabled`
(on an `__item`) mark or mute a row; `--flush` (on the list) drops the frame to sit inside a `.wb-card`. Compose `__title`
(+ nested `__sub`) and `__end` (right-aligned meta).

```html
<ul class="wb-list">
  <li class="wb-list__item">
    <span class="wb-list__title">Vietcombank<span class="wb-list__sub">•••• 8842</span></span>
    <span class="wb-list__end wb-num--strong">18.740.000 ₫</span>
  </li>
</ul>
```

## Form controls

Wrap each control in `.wb-field` (label + control + help/error stacked). Controls are
neutral; the only colour is the red invalid state.

```
CONTROLS: .wb-input · .wb-select (wrap in .wb-select-wrap + a .wb-ico chevron) ·
          .wb-textarea · .wb-check · .wb-radio · .wb-switch
LABELS:   .wb-label (+ .wb-label__opt for "(tùy chọn)")
HELP:     .wb-help (muted) · .wb-error (red)
INVALID:  add the STATE class .is-invalid to the control (.wb-input.is-invalid …) +
          aria-invalid="true", then show .wb-error. (State = .is-*, not a --modifier.)
GROUP:    .wb-input-group with .wb-input-group__addon for PREFIX or SUFFIX (₫, %, https://, an icon)
```

```html
<!-- PREFIX (₫ / https:// / an icon) and SUFFIX via .wb-input-group -->
<div class="wb-input-group">
  <span class="wb-input-group__addon">₫</span>
  <input class="wb-input" inputmode="numeric" value="1.280.000" />
</div>
<div class="wb-input-group">
  <span class="wb-input-group__addon"><span class="wb-ico wb-ico--sm">search</span></span>
  <input class="wb-input" placeholder="Tìm giao dịch…" />
</div>

<!-- SELECT: wrap so the chevron is a real icon, not a background image -->
<span class="wb-select-wrap">
  <select class="wb-select"><option>Ăn uống</option></select>
  <span class="wb-ico">expand_more</span>
</span>

<!-- INVALID = a runtime STATE (.is-*), not a block --modifier. Red border, stays red on focus. -->
<input class="wb-input is-invalid" value="sai-email" aria-invalid="true" />
<span class="wb-error">Email không hợp lệ.</span>

<!-- yes/no setting -->
<label class="wb-switch">
  <input type="checkbox" checked /><span class="wb-switch__track"></span> Đã thanh toán
</label>
<!-- I/O = power-rocker hint drawn in the track background as CSS shapes (bar=on / ring=off), no font dep -->
<label class="wb-switch wb-switch--io">
  <input type="checkbox" checked /><span class="wb-switch__track"></span> Bật thông báo
</label>
<!-- DISABLED = inert: dim neutral track (never the on/off colour) + not-allowed -->
<label class="wb-switch">
  <input type="checkbox" checked disabled /><span class="wb-switch__track"></span> Nhận email tuần
</label>
<!-- LOCKED = has a real value but blocked. Lock sits BESIDE the toggle (never on the thumb); it
     shakes + darkens to strong ink (đen; flips white on dark) when a flip is attempted. Input stays ENABLED so it emits the click we
     intercept (deny + shake wired via a delegated handler — see app.js / the Switch page). -->
<label class="wb-switch wb-switch--locked">
  <input type="checkbox" checked /><span class="wb-switch__track"></span>
  <span class="wb-switch__lock" aria-hidden="true">lock</span> Đồng bộ ngân hàng
</label>
```

Money fields: use `inputmode="numeric"`, right sentinel `₫` as an addon, and format the
display value with the app's locale (`1.280.000`).

**Checkbox & radio** are drawn on the native input itself (`appearance:none` — the input stays
focusable / keyboard-operable / form-correct, no extra markup): a box / circle with a **bold ink border**,
filled solid on check (white tick / dot, auto-inverts on dark). Border width is a knob (`--wb-check-bw`)
and the corner follows the radius tokens, so both track Config (incl. the **sharp** preset). Radio stays round.

---

## Range / Slider

`.wb-range` — themed track + `--wb-fg` thumb (native `accent-color` can't theme per mode). `--sm`
for a thinner bar; `disabled` mutes. For a FILLED track set an inline gradient from the current value.
**Dual-handle** `.wb-range-dual` picks a MIN + MAX band (two stacked inputs `data-h="min"/"max"` + a
`--a`/`--b` fill) — pair with min/max boxes + a summary as `.wb-range-filter` (the amount/price filter;
see [Filter bar](#filter-bar)). App: Radix **Slider** for keyboard robustness; keep the classes.

```html
<input class="wb-range" type="range" min="0" max="10000000" value="3500000" />
<input class="wb-range" type="range" value="65"
  style="background:linear-gradient(to right,var(--wb-fg) 65%,var(--wb-border-strong) 65%)" />

<!-- dual-handle (min–max band); JS keeps --a/--b + boxes + summary in sync -->
<div class="wb-range-dual" style="--a:20;--b:70">
  <div class="wb-range-dual__track"></div><div class="wb-range-dual__fill"></div>
  <input class="wb-range-dual__input" data-h="min" type="range" min="0" max="10000000" value="2000000" />
  <input class="wb-range-dual__input" data-h="max" type="range" min="0" max="10000000" value="7000000" />
</div>
```

## Colour input

`.wb-color` cleans up the native `<input type=color>`: the whole control becomes a rounded swatch of
the current value (browser inner border/padding stripped — no "square stuck in a button"). `--pill`,
`--sm`; pair a hex label with `.wb-color-field`. Use for category / label colours.

```html
<span class="wb-color-field"><input class="wb-color" type="color" value="#6366f1" /><code>#6366F1</code></span>
```

## File / Upload

`.wb-file` styles the native file control (neutral "choose" button + filename). `.wb-dropzone` is
the dashed "droppable" affordance for statements/receipts — a `<label>` around a hidden input; add
`.is-dragover` on drag in the app.

```html
<input class="wb-file" type="file" />
<label class="wb-dropzone">
  <span class="wb-ico wb-dropzone__icon">cloud_upload</span>
  <div><b>Kéo sao kê vào đây</b> hoặc bấm để chọn</div><input type="file" hidden />
</label>
```

## Card

`.wb-card` = the surface (border + radius + soft shadow). Compose `__head` / `__body` /
`__foot`. Variants: `--dashed` (dashed hairline, no shadow — "add new"/drop zones),
`--flat` (no shadow), `--hover` (lifts on hover — clickable cards). It also wraps tables.

```html
<div class="wb-card">
  <div class="wb-card__head"><h4 class="wb-card__title">Ngân sách</h4></div>
  <div class="wb-card__body">…</div>
  <div class="wb-card__foot">…</div>
</div>
<div class="wb-card wb-card--dashed"><div class="wb-card__body">＋ Thêm</div></div>
```

## Receipt

`.wb-receipt` (wrapper — casts the drop-shadow that follows the torn edge) > `.wb-receipt__paper`
(the paper — `--wb-surface` fill + a zig-zag **mask** on the top & bottom edge). For a **hoá đơn**:
one transaction, a bill, a small statement. Parts: `__head` (`__merchant` + `__meta`), a `__body` of
`__line` rows (desc left, amount right — tabular), `__rule` (dashed perforation), `__total`, `__note`.
Modifiers: `--bottom` (tear only the bottom, clean header), `--flat` (no shadow); tune the teeth with
`--wb-receipt-tw` / `--wb-receipt-th`.

```html
<div class="wb-receipt">
  <div class="wb-receipt__paper">
    <div class="wb-receipt__head">
      <div class="wb-receipt__merchant">Highlands Coffee</div>
      <div class="wb-receipt__meta">08/07/2026 · #HD-0192</div>
    </div>
    <div class="wb-receipt__body">
      <div class="wb-receipt__line"><span>Cà phê sữa</span><span>45.000</span></div>
    </div>
    <div class="wb-receipt__rule"></div>
    <div class="wb-receipt__total"><span>Tổng</span><span>192.240 ₫</span></div>
  </div>
</div>
```
The shadow lives on the wrapper by design — a mask would clip a shadow set on the paper itself. Static, no JS.

## Dropdown / Menu

`.wb-dropdown` wraps a trigger + `.wb-dropdown__menu`; toggle `.is-open`. `.wb-menu`
is the floating panel (also standalone). Items: `.wb-menu__item` (+ `--danger`), optional
`.wb-menu__ico` / `.wb-menu__kbd`, `.wb-menu__label`, `.wb-menu__sep`.

```html
<div class="wb-dropdown">
  <button class="wb-btn wb-btn--secondary" data-dd-toggle>Thao tác ▾</button>
  <div class="wb-dropdown__menu"><div class="wb-menu">
    <button class="wb-menu__item"><span class="wb-menu__ico">✎</span> Sửa</button>
    <div class="wb-menu__sep"></div>
    <button class="wb-menu__item wb-menu__item--danger">Xoá</button>
  </div></div>
</div>
```
App: Radix DropdownMenu for focus/keyboard/portal; keep `wb-menu*` for the look.

## Alert / Banner

Inline message block. `.wb-alert` + tone `--info|--success|--warning|--danger` (soft tint +
full outline in the tone colour — no left-accent bar). Parts: `__icon`, `__body` > `__title` +
`__msg`, optional `.wb-close` (the `__body` flexes to fill, so the × always sits **top-right**).

```html
<div class="wb-alert wb-alert--warning">
  <span class="wb-alert__icon">!</span>
  <div class="wb-alert__body"><p class="wb-alert__title">Sắp vượt ngân sách</p>
    <p class="wb-alert__msg">Đã dùng 82% hạn mức.</p></div>
</div>
```

## Toast

Transient notification. `.wb-toaster` (fixed container, once) holds `.wb-toast` items
(+ tone `--success|--warning|--danger|--info`). Parts mirror alert; the close × sits **top-right**.

```html
<div class="wb-toaster">
  <div class="wb-toast wb-toast--success">
    <span class="wb-toast__icon"><span class="wb-ico wb-ico--xs">check</span></span>
    <div class="wb-toast__body"><p class="wb-toast__title">Đã lưu</p></div>
    <button class="wb-close" aria-label="Đóng"></button>
  </div>
</div>
```
App: use **sonner**; keep `wb-toast*` classes.

## Modal / Dialog

`.wb-overlay` (dims screen, toggle `.is-open`) → `.wb-modal` with `__head` / `__body` /
`__foot`. `data-modal-open="#id"` opens, `data-modal-close` (or clicking the backdrop) closes.

```html
<div class="wb-overlay" id="m1">
  <div class="wb-modal">
    <div class="wb-modal__head"><h4 class="wb-modal__title">Xoá?</h4>
      <button class="wb-close" data-modal-close>×</button></div>
    <div class="wb-modal__body">Không thể hoàn tác.</div>
    <div class="wb-modal__foot">
      <button class="wb-btn wb-btn--ghost" data-modal-close>Huỷ</button>
      <button class="wb-btn wb-btn--danger" data-modal-close>Xoá</button></div>
  </div>
</div>
```
App: Radix Dialog for focus-trap/portal; keep `wb-modal*` for the look.

## Drawer / Offcanvas

`.wb-drawer` slides a panel in from an edge over `.wb-overlay` (the modal scrim) — filters,
transaction detail, a side menu. Right by default; `--left` from the left. Toggle `.is-open` on the
overlay (the shared modal JS works: `data-modal-open` / `-close`, click scrim to close). Parts: `__head`
(title + `.wb-close`, pinned right) · `__body` (scrolls) · `__foot`. App: Radix **Dialog** / **vaul**.

```html
<div class="wb-overlay" id="filters">
  <aside class="wb-drawer">                       <!-- --left to slide from the left -->
    <div class="wb-drawer__head"><div><h3 class="wb-drawer__title">Bộ lọc</h3></div>
      <button class="wb-close" data-modal-close></button></div>
    <div class="wb-drawer__body"> … </div>
    <div class="wb-drawer__foot"> … </div>
  </aside>
</div>
```

## Navbar / Nav (menu)

`.wb-navbar` = the top app bar: `__brand` (+ `__mark` square logo), a `.wb-nav` of links, `__spacer`
(pushes the rest right), `__actions`. `--sticky` pins it. `.wb-nav` is the standalone **menu** primitive —
`.wb-nav__link` (+ `.is-active` / `.is-disabled`, optional `.wb-ico`); `--vertical` stacks it, `--underline`
gives a page-tab look. Active is a plain highlight (no left bar). Wire `.is-active` to the router; mobile
menu toggling is the app's job. A **`.wb-theme-toggle`** icon button (two glyphs: `dark_mode` moon +
`light_mode` sun) swaps automatically with root `.dark` — the app only flips `.dark` (next-themes / one line of JS).

```html
<div class="wb-navbar">
  <a class="wb-navbar__brand"><span class="wb-navbar__mark">L</span> Ledger</a>
  <nav class="wb-nav">
    <a class="wb-nav__link is-active">Tổng quan</a>
    <a class="wb-nav__link">Giao dịch</a>
  </nav>
  <span class="wb-navbar__spacer"></span>
  <div class="wb-navbar__actions">
    <button class="wb-btn wb-btn--ghost wb-btn--icon wb-theme-toggle" aria-label="Sáng/Tối">
      <span class="wb-ico wb-theme-toggle__to-dark">dark_mode</span>
      <span class="wb-ico wb-theme-toggle__to-light">light_mode</span>
    </button>
    <span class="wb-avatar wb-avatar--sm">DV</span>
  </div>
</div>
```
App: keep the classes; drive `.is-active` from React Router (`NavLink`).

## Sidebar (side-nav)

`.wb-sidenav` = the vertical app rail: `__section` (uppercase group label), `__link` (icon + label,
+ `.is-active`), `__badge` (right-aligned count). A shippable sibling of the docs' own sidebar (which adds
collapse behaviour and stays docs chrome). Add `.wb-scroll-y` if it gets long; compose with `.wb-navbar`
for a full app shell.

```html
<nav class="wb-sidenav">
  <div class="wb-sidenav__section">Tổng quan</div>
  <a class="wb-sidenav__link is-active"><span class="wb-ico">dashboard</span> Bảng điều khiển</a>
  <a class="wb-sidenav__link"><span class="wb-ico">receipt_long</span> Giao dịch
    <span class="wb-sidenav__badge">128</span></a>
</nav>
```

## Tabs

`.wb-tabs` > `.wb-tab` (add `.is-active`), panels `.wb-tab-panel` (`hidden` to hide).
Underline default; `.wb-tabs--pill` = segmented control (Thu/Chi, time range);
`.wb-tabs--boxed` = sharp-cornered, high-contrast (solid track + inset thumb, inverts in dark).
In the docs wrap in `[data-tabs]` with `data-tab`/`data-panel` for the JS switch.

```html
<div data-tabs>
  <div class="wb-tabs"><button class="wb-tab is-active" data-tab="a">Tổng quan</button>
    <button class="wb-tab" data-tab="b">Giao dịch</button></div>
  <div class="wb-tab-panel" data-panel="a">…</div>
  <div class="wb-tab-panel" data-panel="b" hidden>…</div>
</div>
```

## Tooltip

Pure-CSS hover/focus hint. `.wb-tooltip` wraps the trigger + `.wb-tooltip__bubble`.

```html
<span class="wb-tooltip">
  <button class="wb-btn wb-btn--icon" aria-label="Thông tin">ⓘ</button>
  <span class="wb-tooltip__bubble">Cập nhật 5 phút trước</span>
</span>
```
App: Radix Tooltip when you need smart positioning / delay.

## Breadcrumb

`.wb-breadcrumb` with `<a>` links, `.wb-breadcrumb__sep` between, `.wb-breadcrumb__current`
for the last (current) crumb.

```html
<nav class="wb-breadcrumb"><a href="#">Trang chủ</a>
  <span class="wb-breadcrumb__sep">/</span>
  <span class="wb-breadcrumb__current">Chi tiết</span></nav>
```

## Pagination

`.wb-pagination` with `.wb-page` items (`.is-active` current, `disabled` at edges,
`.wb-page--gap` for `…`). Fits a `.wb-card__foot`.

```html
<nav class="wb-pagination">
  <button class="wb-page" disabled aria-label="Trước">‹</button>
  <a class="wb-page is-active" aria-current="page">1</a>
  <a class="wb-page">2</a>
  <button class="wb-page" aria-label="Sau">›</button>
</nav>
```

## Avatar

`.wb-avatar` (image or initials). Sizes `--sm|--lg`, shape `--square`. Stack with
`.wb-avatar-group`. Give it a category hue via inline `background`/`color` if needed.

```html
<span class="wb-avatar">VD</span>
<span class="wb-avatar"><img src="…" alt="" /></span>
<div class="wb-avatar-group"><span class="wb-avatar">A</span><span class="wb-avatar">+3</span></div>
```

## Progress

`.wb-progress` > `.wb-progress__bar` (set `width`). Bar tone `--success|--warning|--danger`.
`--lg` for a chunkier bar. Ideal for "đã chi / ngân sách".

```html
<div class="wb-progress"><div class="wb-progress__bar wb-progress__bar--warning" style="width:82%"></div></div>
```

**Indeterminate / loading** — no known %; a lit segment travels the track on a loop (loading /
syncing, not a measured fill). Add `--loading` to the track, no `__bar` child; recolour the
segment with `--wb-progress-c`. Respects `prefers-reduced-motion`.

```html
<div class="wb-progress wb-progress--loading"></div>
<div class="wb-progress wb-progress--loading wb-progress--lg" style="--wb-progress-c:var(--wb-info)"></div>
```

## Accordion

Built on native `<details>` (no JS). `.wb-accordion` > `.wb-accordion__item` (a
`<details>`) > `<summary>` + `.wb-accordion__body`.

```html
<div class="wb-accordion">
  <details class="wb-accordion__item" open>
    <summary>Câu hỏi</summary>
    <div class="wb-accordion__body">Trả lời…</div>
  </details>
</div>
```

## Divider

`.wb-divider` (horizontal). **Styles:** `--dashed`, `--dotted`, `--fade` (dissolves at both ends).
**Tone** (colour = status, per the ladder — plain breaks stay grey): `--success` / `--danger` /
`--warning` / `--info` / `--strong` (ink). `--vertical` (between inline clusters), `--label`
(centred text). `--ray` = a decorative **light-ray that sweeps along** the line on a loop (respects
`prefers-reduced-motion`; **not** a progress bar — the full line stays visible). One knob
`--wb-divider-c` colours line + ticks; `--wb-divider-ray` sets the sweep colour.

```html
<hr class="wb-divider wb-divider--dashed" />
<hr class="wb-divider wb-divider--fade" />
<hr class="wb-divider wb-divider--success" />        <!-- tone: only for a meaningful boundary -->
<hr class="wb-divider--ray" style="--wb-divider-ray:var(--wb-info)" />
<div class="wb-divider--label">HOẶC</div>
<span class="wb-divider--vertical"></span>
```

## Skeleton

Shimmer placeholder while loading. `.wb-skeleton` + `--text|--title|--circle`; size with
inline width/height.

```html
<div class="wb-skeleton wb-skeleton--title"></div>
<div class="wb-skeleton wb-skeleton--text" style="width:60%"></div>
<div class="wb-skeleton wb-skeleton--circle" style="width:40px;height:40px"></div>
```

## Empty state

`.wb-empty` with `__icon`, `__title`, `__msg`, and usually one primary action.

```html
<div class="wb-empty">
  <div class="wb-empty__icon">🧾</div>
  <p class="wb-empty__title">Chưa có giao dịch</p>
  <p class="wb-empty__msg">Thêm giao dịch đầu tiên để bắt đầu.</p>
  <button class="wb-btn">＋ Thêm giao dịch</button>
</div>
```

## Tree

Nested categories, unlimited depth. `ul.wb-tree` > `li.wb-tree__node` (`.is-collapsed`
to fold) > `.wb-tree__row` + nested `ul.wb-tree__children`. Row parts: `__toggle`
(chevron — from the **icon font** via `::before`, leave the button empty; add `.is-leaf` when it
has no children), `__handle` (drag grip — the **drag_indicator** 6-dot icon, empty span),
`__ico` (emoji/icon slot), `__dot`
(category colour), `__label`, `__meta` (count/amount), `__check`, `__actions` (add/edit icon buttons —
reveal on hover/focus by default). Drag classes (`is-dragging`, `is-drop-before|after|inside`) set by the JS.

**Variants:** `--lines` (guide rails) · `--right` (chevron on the right, disclosure style) ·
`--flat` (hide toggles → non-collapsible read-only outline) · `--actions-shown` (row action buttons
always visible — for touch or a management screen, instead of hover-reveal). Collapsible vs not =
simply include the `__toggle` buttons or don't.

Types in the docs: **manager** (drag to reorder + reparent — `data-tree` + draggable rows),
**navigation** (`--lines` + counts + `.is-selected`), **budget** (colour dot + amount),
**filter** (checkbox), **right-chevron** (`--right`), **static** (`--flat`), **file-explorer**
(`__ico` emoji). Expand/collapse works on any tree with toggles; only `data-tree` gets drag.

```html
<ul class="wb-tree" data-tree>
  <li class="wb-tree__node">
    <div class="wb-tree__row" draggable="true">
      <button class="wb-tree__toggle"></button>   <!-- chevron via icon font; empty -->
      <span class="wb-tree__handle"></span>        <!-- 6-dot grip icon; empty -->
      <span class="wb-tree__label">Chi tiêu</span><span class="wb-tree__meta">128</span>
    </div>
    <ul class="wb-tree__children">
      <li class="wb-tree__node"><div class="wb-tree__row" draggable="true">
        <button class="wb-tree__toggle is-leaf"></button>
        <span class="wb-tree__handle"></span>
        <span class="wb-tree__label">Ăn uống</span></div></li>
    </ul>
  </li>
</ul>
```
Docs drag = vanilla HTML5 DnD (reorder + reparent, blocks dropping into its own descendant).
App: **dnd-kit** for the interaction; keep the `wb-tree*` classes for the look.

---

## Border & radius

Conventions, not many classes. Widths: `--wb-border` (1px hairline, default) ·
`--wb-border-strong` (1px, stronger); 2px for large blocks that must read. Radii:
`--wb-radius-sm|-(base 10px)|-lg|-pill`, or `0` for the sharp look (boxed tabs). **This site
does not use left-accent bars** — express a tone with a full **outline + soft background**
(like a capsule): `border: 1px solid color-mix(in srgb, var(--wb-danger) 55%, var(--wb-border)); background: var(--wb-danger-soft)`.
Use **dashed** to signal "empty / droppable / optional": `.wb-card--dashed`,
`.wb-divider--dashed`, `.wb-sortable__ph`. The left-accent bar is documented on the Border page
as a **non-default variant** (a thin tone marker for feed / notification lists or quotes) — use with
intent, not as a component default.

## Charts

SVG/CSS finance visuals — no chart lib in the skill. Palette tokens: `--wb-chart-income` /
`--wb-chart-expense` (**bright** green/red — `#22c55e` / `#ef4444`, a step lighter than the semantic
`-success/-danger` so a filled bar isn't muddy), `--wb-chart-1…8` (categorical), `--wb-chart-grid`,
`--wb-chart-axis` (brighter in dark). Pieces:
- **Line/area** — `<polyline class="wb-series-line">` + `<path class="wb-series-area">`; each
  point is `<g class="wb-point">` (an invisible `__hit` circle + `.wb-series-dot` + a
  `.wb-point__tip` that fades in on hover — pure SVG, no JS). Axis/grid via `.wb-axis-line` /
  `.wb-grid-line` / `.wb-axis-label`; colour via inline `stroke`/`fill: var(--wb-chart-*)`.
- **Bars** (CSS) — `.wb-bars` (faint gridlines built in) > `.wb-bars__col` with `.wb-bar`
  (`--income|--expense`, `height:%`) + `.wb-bars__label`; optional `.wb-bar__val` shows on column
  hover. (Base uses `.dark :where(.wb-bar)` so the income/expense tones survive dark mode.)
- **Combo (bar + line)** — draw `<rect>` bars first, then overlay a `.wb-series-line` + `.wb-point`
  dots on the same axis (e.g. chi as bars, thu as the line) → one chart, two encodings.
- **Horizontal ranked bars** — *not* a new component: `.wb-progress` rows inside a `.wb-stack`
  (label + value above each), tinted per category (`background:var(--wb-chart-N)`); longest = 100%.
  Best for ranking many categories (top spend / top debt) where a donut gets crowded.
- **Donut** — `<circle pathLength="100" stroke-dasharray="<pct> 100" stroke-dashoffset="-<cumulative>">`
  inside `<g transform="rotate(-90 …)">`; shorten each `<pct>` by ~1 for a thin gap between slices
  (`.wb-donut__track` = surface colour, so gaps read clean). `.wb-donut__center-value|-label` centre.
- **Thin / rounded donut & progress ring** — put `.wb-arc` (+ `--round` for soft pill caps) on the
  segments, with a THIN `stroke-width` (~10) and bigger gaps (~5 path-units) so the pill caps actually
  show. A progress ring (budget/goal gauge) = one `.wb-arc--round` over a `.wb-ring__track`, with
  `.wb-donut__center-*` text; colour it by the progress tones (neutral/`chart-1` &lt; ~80% · warning ·
  danger), not amber by default.
- **Colour schemes** — wrap a chart in `.wb-chart-scheme--mono` (grey) or `--blue` (one-hue): each
  series is mixed from a single ink toward the canvas. Add `.wb-chart-ramp--N` (N = number of series)
  to spread them evenly from 100% → 25% strength so no two steps look alike — a fixed grey-900…-200 set
  clumps at the dark end and reads the same; without a count an even up-to-8 spread is used. Both invert
  light↔dark; put the scheme on `:root` (via Config) to apply site-wide when multi-colour is too busy.
- **Budget** — reuse `.wb-progress` (success < ~80% · warning ~80–99% · danger ≥100%).
- **Sparkline** — `.wb-spark` with a single `<path>` (tiny trend in a stat card).
- **Legend / tooltip** — `.wb-legend` + `.wb-legend__item` + `__dot` (+ `__val`); `.wb-chart__tip`.

```html
<div class="wb-bars">
  <div class="wb-bars__col">
    <div class="wb-bar wb-bar--income"  style="height:83%"></div>
    <div class="wb-bar wb-bar--expense" style="height:27%"></div>
    <span class="wb-bars__label">T3</span>
  </div>
</div>
```
App: **Recharts**, fed the same `--wb-chart-*` tokens so it matches; keep `.wb-chart__tip`
for the tooltip look.

## Sortable list / grid

Flat drag-to-reorder (one level — use **Tree** for nesting). `.wb-sortable` (list) or
`.wb-sortable--grid` (card grid) with `data-sortable`; each `.wb-sortable__item`
(`draggable="true"`) holds a `.wb-grip` + `.wb-sortable__label` (+ `__meta`). While
dragging, the JS inserts a dashed `.wb-sortable__ph` at the drop position.

```html
<div class="wb-sortable" data-sortable>
  <div class="wb-sortable__item" draggable="true">
    <span class="wb-grip"></span>
    <span class="wb-sortable__label">Ăn uống</span>
    <span class="wb-sortable__meta">−3.280.000 ₫</span>
  </div>
</div>
```
App: **dnd-kit** (`@dnd-kit/sortable`); keep the `wb-sortable*` classes.

**Sortable table rows:** add `--sortable` to a `.wb-table`, give each `<tr>` a `.wb-row-grip`
cell (holding `.wb-grip`) + `draggable="true"`, and `data-sortable-rows` on the `<tbody>`. While
dragging, the JS inserts a dashed `.wb-row-ph` row at the drop position. App → dnd-kit over the rows.

## Icons

Icons are an **icon font** (Material Symbols Rounded, `@import`ed in `web-builder.css`) — never
hand-drawn. Inline: `<span class="wb-ico">expand_more</span>` (the text is a ligature). Sizes
`--xs|--sm|--lg|--xl`; tune globally via `--wb-ico-size` / `--wb-ico-weight` (heavier = crisper —
the Config panel drives these). A few components inject their icon via `::before` (accordion, tree
toggle, close ×) and stay empty in markup; a `<select>` gets its chevron from a `.wb-ico` inside
`.wb-select-wrap`. Swap `--wb-icon-font` to use a different set (e.g. lucide) in the app.

```html
<span class="wb-ico">search</span>
<span class="wb-ico wb-ico--sm">expand_more</span>
<button class="wb-close" aria-label="Đóng"></button>   <!-- the × comes from ::before -->
```

## Grid / Layout

Composable layout utilities (no colour/meaning — just placement; swap for Tailwind flex/grid if you
prefer):
- `.wb-cluster` — a row that **wraps**. Main axis (justify): `--start` / `--end` / `--center` /
  `--between` / `--around` / `--evenly` / `--stretch` (equal-**width** items fill the row). Cross axis
  (align, when items differ in height): `--top` / `--middle` (vertical centre = default) / `--bottom` /
  `--baseline` — note `--center` is horizontal (justify), `--middle` is vertical (align). Gap
  `--tight` / `--loose`; `--nowrap` to stop wrapping.
- `.wb-inline` — the **inline** sibling of `.wb-cluster`: an `inline-flex` row (8px gap, items
  vertically centred) that flows *inside* text or a cell instead of forming a block-level row. Reach for
  it for an icon + label on one line; reach for `.wb-cluster` for a full, wrapping row.
- `.wb-grid` — 2-D grid: `--auto` (auto-fill by `--wb-grid-min`), `--2/--3/--4` (fixed cols, → 1
  col on mobile), `--equal` (equal columns in one row). Cells are **equal-height** — use this for a row
  of equal-height cards rather than a cluster.
- `.wb-stack` — vertical flow with a gap (`--tight` / `--loose`); the vertical partner of `--cluster`.
  Align items horizontally: `--start` (left) / `--center` / `--end` (right).
- `.wb-container` — centered max-width column (`--narrow` 720 · default 1120 · `--wide` 1320px).
- `.wb-ratio` — hold an aspect ratio (`--1x1` / `--4x3` / `--16x9`) for embeds / receipt images.
- **Per-item helpers** (on a flex child): `.wb-grow` (eat the remaining space) ·
  `.wb-self--top` / `--center` / `--bottom` / `--stretch` / `--baseline` (override alignment for one item).

```html
<div class="wb-cluster wb-cluster--between"><span>Tổng chi</span><span class="wb-num">−11,8tr</span></div>
<div class="wb-cluster wb-cluster--top"> … </div>            <!-- top-align a row of unequal-height items -->
<div class="wb-cluster wb-cluster--nowrap"><input class="wb-input wb-grow"/><button class="wb-btn">Lọc</button></div>
<div class="wb-grid wb-grid--auto" style="--wb-grid-min:150px"> … </div>
```

## Scroll areas

`.wb-scroll-y` — put on any `overflow-y` region (a bounded list, a category picker, a side panel). It
gives a **thin, theme-aware scrollbar** (transparent track + neutral-border thumb, so no bright OS bar
clashing on dark or reading as a divider) and **`scroll-padding` tail room**; add `--pad` for extra
bottom space so the last item scrolls clear of the edge (easier to read/tap/select). The built-in table
body (`.wb-table-scroll`) and dropdown `.wb-menu` already carry the themed scrollbar. Scale the tail
to the case — a short menu needs little, a long list wants more.

```html
<div class="wb-scroll-y wb-scroll-y--pad" style="max-height:320px"> … danh mục dài … </div>
```

## Config / Tweak

A **docs-only** playground (gear in the topbar, or the Config page) that slides in a drawer to tune
tokens **live**, grouped by job: a **corner-style preset** (Bo tròn / **Vuông sắc = 0** / Bo nhiều) that
squares *every* control at once, plus per-radius sliders; border width (incl. a **checkbox** border knob)
and border colours; shadow; surface/text colours + the status palette (for the theme being viewed); font +
icon; chart scheme; and a separate **docs-only** group (`--wb-demo-bw`, `--wb-demo-shadow`,
`--wb-doc-divider`). **Xuất .md** downloads the changed `:root{}` block to paste
into source (or hand to an AI). It only sets CSS variables on the docs root — it never edits
`web-builder.css`, so the shipped primitives are never touched.

---

## Using these in an app (React + Tailwind)

The markup above is framework-agnostic HTML + classes, so it works in a `.tsx` return
as-is (remember `className`, and self-close void tags). For the recommended React
component wrappers, CVA variants, and how the tokens plug into Tailwind/shadcn, see
`integration.md`.

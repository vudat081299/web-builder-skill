# Cashy UI — Component Catalog

The lookup table for "I'm building X → use this, here's the markup." Copy the snippet,
swap the data, done. Do **not** redesign from scratch — that's the whole point of this
library. Each is rendered live on its own page under `assets/pages/` (served over HTTP —
see SKILL.md).

Scope so far: foundations (**colour**, **tokens**, **typography**, **fonts**, **border & radius**,
**Config/tweak** playground); **Buttons** (+ button-group), **Dropdown**; **inputs** — one primitive per
page: **Text input**, **Select**, **Textarea**, **Checkbox/Radio**, **Switch**, **Range/Slider**,
**File/Upload**, **Colour**; **Card**, **Tables**, **List group**, **Stat/KPI**, **Capsules**, **Tags**,
**Avatar**; **Alert**, **Toast**, **Modal**, **Drawer/Offcanvas**, **Progress**, **Skeleton**,
**Empty state**, **Tooltip**; **Tabs** (underline / pill / boxed), **Breadcrumb**, **Pagination**,
**Accordion**, **Divider**; **Charts** (line/area, bars, **combo bar+line**, **horizontal ranked bars**,
donut + thin/rounded + progress ring, budget, sparkline, mono/blue schemes + count-aware ramps); a
drag-and-drop **Tree**; a flat **Sortable** list /
grid / **table rows**; and **Grid/Layout** utilities (cluster / grid / stack / container / ratio). Coverage
tracks **Bootstrap**'s primitive set, re-cut minimalist. Icons come from an **icon font** (Material Symbols, loaded
by `@import` in `cashy-ui.css` — swap `--cash-icon-font` to use another set); tones use outline + soft
background (no left-accent bar on components — documented as a non-default variant on the Border page).

Every component is themed off tokens and works in light + dark. The interactive ones
(dropdown, modal, tabs, toast) ship as **CSS + a tiny vanilla toggle** in the docs; in the
cashy app, drive them with Radix/shadcn and keep the `cash-*` classes for the look (see
`cashy-integration.md`).

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
| A data-entry form (add/edit transaction, settings) | **Form controls** | [Forms](#form-controls) |
| A money input, a category picker, a yes/no setting | input-group / select / switch | [Forms](#form-controls) |
| A slider for a budget cap / threshold | **Range** | [Range](#range--slider) |
| Attach a statement / receipt (button or drop area) | **File / dropzone** | [File](#file--upload) |
| Pick a category / label colour | **Colour input** | [Colour](#colour-input) |
| A settings / accounts list (one item per row) | **List group** | [List group](#list-group) |
| A content container / section with header + body | **Card** | [Card](#card) |
| A menu of actions off a button (⋯, "Thao tác") | **Dropdown** | [Dropdown](#dropdown--menu) |
| An inline message inside a page/form | **Alert** | [Alert](#alert--banner) |
| A transient "saved / failed" notification | **Toast** | [Toast](#toast) |
| A confirm / focused task over a dimmed screen | **Modal** | [Modal](#modal--dialog) |
| A slide-in filters / detail / side-menu panel | **Drawer** | [Drawer](#drawer--offcanvas) |
| Switch between views, or a Thu/Chi segmented toggle | **Tabs** | [Tabs](#tabs) |
| A segmented filter of joined buttons (Ngày/Tuần/Tháng) | **Button group** | [Button group](#button-group) |
| Budget usage / completion ratio | **Progress** | [Progress](#progress) |
| A loading placeholder before data arrives | **Skeleton** | [Skeleton](#skeleton) |
| A "no data yet" / empty list screen | **Empty state** | [Empty](#empty-state) |
| A short hint on hover / focus | **Tooltip** | [Tooltip](#tooltip) |
| The path "where am I" above a page | **Breadcrumb** | [Breadcrumb](#breadcrumb) |
| Page through a long list/table | **Pagination** | [Pagination](#pagination) |
| A person / initials / member group | **Avatar** | [Avatar](#avatar) |
| Collapsible FAQ / sections | **Accordion** | [Accordion](#accordion) |
| A visual separator (solid / dashed / labelled) | **Divider** | [Divider](#divider) |
| Border widths / radii / dashed / outline-tone conventions | **Border** | [Border](#border--radius) |
| A spending line, income-vs-expense bars, **combo bar+line**, category donut, sparkline | **Charts** | [Charts](#charts) |
| Ranking many categories (top spend / top debt) | **Charts** — horizontal ranked bars | [Charts](#charts) |
| Budget usage per category (progress + over-budget) | **Charts** (budget) / Progress | [Charts](#charts) |
| Nested categories (drag to reorder / reparent) | **Tree** | [Tree](#tree) |
| Reorder a flat list or grid of cards (drag) | **Sortable** | [Sortable](#sortable-list--grid) |
| Reorder rows inside a data table (drag) | **Sortable table** (`--sortable`) | [Sortable](#sortable-list--grid) |
| Arrange cards/chips: wrap, equal widths, right-align | **Grid / Layout** utilities | [Layout](#grid--layout) |
| A UI icon (chevron, close, drag, search…) | **Icon** (`.cash-ico`) | [Icons](#icons) |
| Fine-tune tokens live + export a `.md` | **Config** (docs playground) | [Config](#config--tweak) |

---

## Buttons

`.cash-btn` + optional fill + tone + size. Default (no modifier) is the **neutral primary**
(near-black in light, near-white in dark) — the primary action is *not* a brand colour.

```
FILL:  (default solid neutral) · --secondary · --outline · --ghost
TONE:  --danger · --success        (only meaningful actions: delete, confirm payment)
SIZE:  (default) · --sm · --lg      SHAPE: --icon (square) · --block (full width)
STATE: disabled attr / .is-disabled · .is-loading (+ a <span class="cash-spinner">)
```

**Choosing:** one **primary** per view (the main action) → `cash-btn`. Everything else →
`--secondary` / `--outline` / `--ghost`. Reserve `--danger` for destructive, `--success`
for an explicit money-received confirmation. Don't put two solid neutral buttons side by
side — pair primary with a ghost/secondary.

```html
<button class="cash-btn">Lưu giao dịch</button>
<button class="cash-btn cash-btn--ghost">Huỷ</button>
<button class="cash-btn cash-btn--secondary cash-btn--icon" aria-label="Sửa">✎</button>
<button class="cash-btn cash-btn--danger">Xoá</button>
<button class="cash-btn is-loading"><span class="cash-spinner"></span> Đang lưu…</button>
```

Icon-only buttons **must** have `aria-label`. The spinner inherits the button's text
colour, so it works on any variant.

**Social login** — reuse `.cash-btn` + a brand logo `<svg>` on the left, usually `--block` (full
width) in a `.cash-stack`. Apple = neutral primary `cash-btn` (black bg / white logo via
`fill="currentColor"` — auto-flips per theme); Google = `--secondary` with the 4-colour "G". The
provider logo is the **one** allowed colour exception; the rest of the button stays neutral.

```html
<div class="cash-stack" style="max-width:300px">
  <button class="cash-btn cash-btn--block">
    <svg width="17" height="17" viewBox="0 0 384 512" fill="currentColor"><path d="…apple…"/></svg>
    Tiếp tục với Apple
  </button>
  <button class="cash-btn cash-btn--secondary cash-btn--block">
    <svg width="17" height="17" viewBox="0 0 48 48"><!-- Google G, 4 màu --></svg>
    Tiếp tục với Google
  </button>
</div>
```

---

## Button group

`.cash-btn-group` joins `.cash-btn` children into one segmented control (shared 1px seams, rounded
outer ends). Works with any variant; `--outline` / `--secondary` read best. Mark the chosen one
`.is-active`. For a calm single-select toggle, `.cash-tabs--pill` is often nicer.

```html
<div class="cash-btn-group">
  <button class="cash-btn cash-btn--outline is-active">Ngày</button>
  <button class="cash-btn cash-btn--outline">Tuần</button>
  <button class="cash-btn cash-btn--outline">Tháng</button>
</div>
```

## Stat / KPI cards

`.cash-stat` inside `.cash-stat-grid` (auto-fit responsive grid). Neutral card; the only
colour is the delta — `--up` (green) for a rise, `--down` (red) for a drop, because the
*direction* is the meaning. Use for the top-of-dashboard summary (balance, income, spend).

```html
<div class="cash-stat-grid">
  <div class="cash-stat">
    <div class="cash-stat__top">
      <span class="cash-stat__label">Tổng số dư</span>
      <span class="cash-stat__icon">◈</span>          <!-- optional -->
    </div>
    <div class="cash-stat__value">47.590.000&nbsp;₫</div>
    <div class="cash-stat__foot">
      <span class="cash-stat__delta cash-stat__delta--up">↑ 12,4%</span> so với tháng trước
    </div>
  </div>
  <!-- …more .cash-stat… -->
</div>
```

The `__foot` can hold a delta, a plain caption, or a capsule (e.g. a danger capsule for
"2 quá hạn"). Keep values in `tabular-nums` (the class already does this).

---

## Capsules

`.cash-cap` + optional **FILL** modifier + optional **TONE** modifier. Default (no
modifier) is soft grey — the most common case.

```
FILL:  (default soft grey) · --solid · --outline · --elevated
TONE:  (default neutral)   · --success · --danger · --warning · --info
COLOUR:--tinted + style="--cash-cap-color:#hex"   (custom category hue, like tags)
SIZE:  (default) · --sm · --lg
DOT:   add <span class="cash-cap__dot"></span> as first child for a status dot
```

**Choosing:**
- **Category / classification** (not a status) → neutral, no tone: `class="cash-cap"`.
- **Status that should stay calm** → tone, soft (default fill): `cash-cap cash-cap--success`.
- **Status that must shout** (overdue, failed) → tone + solid: `cash-cap cash-cap--danger cash-cap--solid`.
- **A neutral chip that needs to pop off a busy surface** → `cash-cap cash-cap--elevated`.

```html
<!-- category (neutral, tier 1) -->
<span class="cash-cap">Ăn uống</span>

<!-- calm status (tier 3, soft) -->
<span class="cash-cap cash-cap--success"><span class="cash-cap__dot"></span> Đã trả</span>

<!-- loud status (tier 2, solid) -->
<span class="cash-cap cash-cap--danger cash-cap--solid">Quá hạn</span>

<!-- neutral emphasis on a busy row (white + grey shadow) -->
<span class="cash-cap cash-cap--elevated">Xuất CSV</span>

<!-- coloured category chip (classification only — pass one variable) -->
<span class="cash-cap cash-cap--tinted" style="--cash-cap-color:#4f46e5"><span class="cash-cap__dot"></span> Ăn uống</span>
```

Status → tone mapping used across cashy (keep it consistent):
`Đã trả / Đã nhận / Hoàn tất` → **success** · `Chờ / Sắp đến hạn` → **warning** ·
`Quá hạn / Thất bại / Nợ xấu` → **danger** · `Đang xử lý` → **info` · everything else → **neutral**.

---

## Tags

`.cash-tag` — a **`#`-prefixed** label a user pins to a transaction (free-form, unlike a
fixed category). Same family as capsules; the leading `#` is added by CSS.

```
SHAPE:  (pill, default) · --rect · --notch    (notch = physical-tag look, with a punch hole)
TONE:   (neutral) · --success · --danger · --warning · --info
COLOUR: --tinted + style="--cash-tag-color:#hex"   (a custom per-category hue)
EMPH:   --solid  (tier-2 full colour; pair with a tone or --tinted)
SIZE:   (default) · --sm · --lg      REMOVE: add <button class="cash-tag__x">×</button>
GROUP:  wrap several in .cash-tags   (flex-wrap row)
```

**Choosing:** most tags are **neutral** (classification, not status). Give a tag its own
hue only when the category genuinely has one in the app — pass it via the one variable so
both themes stay correct. Reserve `--solid` for a tag that must shout.

```html
<!-- neutral, and a category with its own colour -->
<span class="cash-tag">an-uong</span>
<span class="cash-tag cash-tag--tinted" style="--cash-tag-color:#0d9488">du-lich</span>

<!-- semantic + removable, grouped on a transaction -->
<div class="cash-tags">
  <span class="cash-tag cash-tag--success">hoan-tien</span>
  <span class="cash-tag cash-tag--notch">tien-mat</span>
  <span class="cash-tag">tet-2027<button class="cash-tag__x" aria-label="Xoá">×</button></span>
</div>
```

**Tag vs capsule:** a *capsule* carries a fixed meaning the app defines (status /
classification); a *tag* is a user-attached label and always shows `#`.

---

## Tables

Anatomy (all parts optional except the `<table>`):

```html
<div class="cash-card">                       <!-- surface + border + radius + shadow -->
  <div class="cash-table-head">…title / actions…</div>
  <div class="cash-table-scroll">             <!-- horizontal scroll; bound height for sticky -->
    <table class="cash-table">…</table>
  </div>
  <div class="cash-table-foot">…pagination…</div>
</div>
```

**Modifiers on `.cash-table`:** `--striped` · `--bordered` · `--compact` · `--sticky` ·
`--no-hover` (hover is on by default).

**Cell helpers:** `cash-num` (right-align + tabular) · `cash-num--pos|--neg|--strong` ·
`cash-cell-strong` · `cash-cell-muted` · `cash-cell-sub` (small second line) · `cash-inline`.

**Row states (use colour only when it means something):**
`cash-row--danger` · `cash-row--warning` · `cash-row--success` — a subtle background tint
(no left accent bar; pair with a coloured capsule in the row for an explicit label). For
overdue debts, bad debt, over-budget, etc.

### Snippet — transaction row (the hero pattern)

```html
<table class="cash-table">
  <thead>
    <tr><th>Ngày</th><th>Nội dung</th><th>Danh mục</th><th class="cash-num">Số tiền</th><th>Trạng thái</th></tr>
  </thead>
  <tbody>
    <tr>
      <td class="cash-cell-muted">14/07</td>
      <td>
        <span class="cash-cell-strong">Lương tháng 7</span>
        <span class="cash-cell-sub">Công ty ABC</span>
      </td>
      <td><span class="cash-cap cash-cap--success">Thu nhập</span></td>
      <td class="cash-num cash-num--pos">+25.000.000&nbsp;₫</td>
      <td><span class="cash-cap cash-cap--success"><span class="cash-cap__dot"></span> Đã nhận</span></td>
    </tr>
  </tbody>
  <tfoot>
    <tr><td colspan="3">Ròng trong kỳ</td><td class="cash-num cash-num--pos">+21.360.000&nbsp;₫</td><td></td></tr>
  </tfoot>
</table>
```

### Snippet — sticky, scrollable long list

```html
<div class="cash-table-scroll" style="max-height: 320px;">
  <table class="cash-table cash-table--sticky cash-table--compact">…</table>
</div>
```

### Snippet — debt / receivables (meaningful colour)

```html
<tr class="cash-row--danger">
  <td class="cash-cell-strong">Nguyễn Văn A</td>
  <td class="cash-cell-muted">01/06/2026</td>
  <td class="cash-num cash-num--strong">5.000.000&nbsp;₫</td>
  <td><span class="cash-cap cash-cap--danger cash-cap--solid">Quá hạn 43 ngày</span></td>
</tr>
```

---

## List group

`.cash-list` — a bordered, hairline-divided list (accounts/wallets, settings, a picker). Lighter than
a table when each row is ONE item, not columns. `__item--link` rows hover, `.is-active` / `.is-disabled`
(on an `__item`) mark or mute a row; `--flush` (on the list) drops the frame to sit inside a `.cash-card`. Compose `__title`
(+ nested `__sub`) and `__end` (right-aligned meta).

```html
<ul class="cash-list">
  <li class="cash-list__item">
    <span class="cash-list__title">Vietcombank<span class="cash-list__sub">•••• 8842</span></span>
    <span class="cash-list__end cash-num--strong">18.740.000 ₫</span>
  </li>
</ul>
```

## Form controls

Wrap each control in `.cash-field` (label + control + help/error stacked). Controls are
neutral; the only colour is the red invalid state.

```
CONTROLS: .cash-input · .cash-select (wrap in .cash-select-wrap + a .cash-ico chevron) ·
          .cash-textarea · .cash-check · .cash-radio · .cash-switch
LABELS:   .cash-label (+ .cash-label__opt for "(tùy chọn)")
HELP:     .cash-help (muted) · .cash-error (red)
INVALID:  add the STATE class .is-invalid to the control (.cash-input.is-invalid …) +
          aria-invalid="true", then show .cash-error. (State = .is-*, not a --modifier.)
GROUP:    .cash-input-group with .cash-input-group__addon for PREFIX or SUFFIX (₫, %, https://, an icon)
```

```html
<!-- PREFIX (₫ / https:// / an icon) and SUFFIX via .cash-input-group -->
<div class="cash-input-group">
  <span class="cash-input-group__addon">₫</span>
  <input class="cash-input" inputmode="numeric" value="1.280.000" />
</div>
<div class="cash-input-group">
  <span class="cash-input-group__addon"><span class="cash-ico cash-ico--sm">search</span></span>
  <input class="cash-input" placeholder="Tìm giao dịch…" />
</div>

<!-- SELECT: wrap so the chevron is a real icon, not a background image -->
<span class="cash-select-wrap">
  <select class="cash-select"><option>Ăn uống</option></select>
  <span class="cash-ico">expand_more</span>
</span>

<!-- INVALID = a runtime STATE (.is-*), not a block --modifier. Red border, stays red on focus. -->
<input class="cash-input is-invalid" value="sai-email" aria-invalid="true" />
<span class="cash-error">Email không hợp lệ.</span>

<!-- yes/no setting -->
<label class="cash-switch">
  <input type="checkbox" checked /><span class="cash-switch__track"></span> Đã thanh toán
</label>
<!-- DISABLED = inert: dim neutral track (never the on/off colour) + not-allowed -->
<label class="cash-switch">
  <input type="checkbox" checked disabled /><span class="cash-switch__track"></span> Nhận email tuần
</label>
<!-- LOCKED = has a real value but blocked. Lock sits BESIDE the toggle (never on the thumb); it
     shakes + turns amber when a flip is attempted. Input stays ENABLED so it emits the click we
     intercept (deny + shake wired via a delegated handler — see app.js / the Switch page). -->
<label class="cash-switch cash-switch--locked">
  <input type="checkbox" checked /><span class="cash-switch__track"></span>
  <span class="cash-switch__lock" aria-hidden="true">lock</span> Đồng bộ ngân hàng
</label>
```

Money fields: use `inputmode="numeric"`, right sentinel `₫` as an addon, and format the
display value with the app's locale (`1.280.000`).

---

## Range / Slider

`.cash-range` — themed track + `--cash-fg` thumb (native `accent-color` can't theme per mode). `--sm`
for a thinner bar; `disabled` mutes. For a FILLED track set an inline gradient from the current value.
App: Radix **Slider** for keyboard + range (two thumbs); keep the class.

```html
<input class="cash-range" type="range" min="0" max="10000000" value="3500000" />
<input class="cash-range" type="range" value="65"
  style="background:linear-gradient(to right,var(--cash-fg) 65%,var(--cash-border-strong) 65%)" />
```

## Colour input

`.cash-color` cleans up the native `<input type=color>`: the whole control becomes a rounded swatch of
the current value (browser inner border/padding stripped — no "square stuck in a button"). `--pill`,
`--sm`; pair a hex label with `.cash-color-field`. Use for category / label colours.

```html
<span class="cash-color-field"><input class="cash-color" type="color" value="#6366f1" /><code>#6366F1</code></span>
```

## File / Upload

`.cash-file` styles the native file control (neutral "choose" button + filename). `.cash-dropzone` is
the dashed "droppable" affordance for statements/receipts — a `<label>` around a hidden input; add
`.is-dragover` on drag in the app.

```html
<input class="cash-file" type="file" />
<label class="cash-dropzone">
  <span class="cash-ico cash-dropzone__icon">cloud_upload</span>
  <div><b>Kéo sao kê vào đây</b> hoặc bấm để chọn</div><input type="file" hidden />
</label>
```

## Card

`.cash-card` = the surface (border + radius + soft shadow). Compose `__head` / `__body` /
`__foot`. Variants: `--dashed` (dashed hairline, no shadow — "add new"/drop zones),
`--flat` (no shadow), `--hover` (lifts on hover — clickable cards). It also wraps tables.

```html
<div class="cash-card">
  <div class="cash-card__head"><h4 class="cash-card__title">Ngân sách</h4></div>
  <div class="cash-card__body">…</div>
  <div class="cash-card__foot">…</div>
</div>
<div class="cash-card cash-card--dashed"><div class="cash-card__body">＋ Thêm</div></div>
```

## Dropdown / Menu

`.cash-dropdown` wraps a trigger + `.cash-dropdown__menu`; toggle `.is-open`. `.cash-menu`
is the floating panel (also standalone). Items: `.cash-menu__item` (+ `--danger`), optional
`.cash-menu__ico` / `.cash-menu__kbd`, `.cash-menu__label`, `.cash-menu__sep`.

```html
<div class="cash-dropdown">
  <button class="cash-btn cash-btn--secondary" data-dd-toggle>Thao tác ▾</button>
  <div class="cash-dropdown__menu"><div class="cash-menu">
    <button class="cash-menu__item"><span class="cash-menu__ico">✎</span> Sửa</button>
    <div class="cash-menu__sep"></div>
    <button class="cash-menu__item cash-menu__item--danger">Xoá</button>
  </div></div>
</div>
```
App: Radix DropdownMenu for focus/keyboard/portal; keep `cash-menu*` for the look.

## Alert / Banner

Inline message block. `.cash-alert` + tone `--info|--success|--warning|--danger` (soft tint +
full outline in the tone colour — no left-accent bar). Parts: `__icon`, `__body` > `__title` +
`__msg`, optional `.cash-close` (the `__body` flexes to fill, so the × always sits **top-right**).

```html
<div class="cash-alert cash-alert--warning">
  <span class="cash-alert__icon">!</span>
  <div class="cash-alert__body"><p class="cash-alert__title">Sắp vượt ngân sách</p>
    <p class="cash-alert__msg">Đã dùng 82% hạn mức.</p></div>
</div>
```

## Toast

Transient notification. `.cash-toaster` (fixed container, once) holds `.cash-toast` items
(+ tone `--success|--warning|--danger|--info`). Parts mirror alert; the close × sits **top-right**.

```html
<div class="cash-toaster">
  <div class="cash-toast cash-toast--success">
    <span class="cash-toast__icon"><span class="cash-ico cash-ico--xs">check</span></span>
    <div class="cash-toast__body"><p class="cash-toast__title">Đã lưu</p></div>
    <button class="cash-close" aria-label="Đóng"></button>
  </div>
</div>
```
App: use **sonner**; keep `cash-toast*` classes.

## Modal / Dialog

`.cash-overlay` (dims screen, toggle `.is-open`) → `.cash-modal` with `__head` / `__body` /
`__foot`. `data-modal-open="#id"` opens, `data-modal-close` (or clicking the backdrop) closes.

```html
<div class="cash-overlay" id="m1">
  <div class="cash-modal">
    <div class="cash-modal__head"><h4 class="cash-modal__title">Xoá?</h4>
      <button class="cash-close" data-modal-close>×</button></div>
    <div class="cash-modal__body">Không thể hoàn tác.</div>
    <div class="cash-modal__foot">
      <button class="cash-btn cash-btn--ghost" data-modal-close>Huỷ</button>
      <button class="cash-btn cash-btn--danger" data-modal-close>Xoá</button></div>
  </div>
</div>
```
App: Radix Dialog for focus-trap/portal; keep `cash-modal*` for the look.

## Drawer / Offcanvas

`.cash-drawer` slides a panel in from an edge over `.cash-overlay` (the modal scrim) — filters,
transaction detail, a side menu. Right by default; `--left` from the left. Toggle `.is-open` on the
overlay (the shared modal JS works: `data-modal-open` / `-close`, click scrim to close). Parts: `__head`
(title + `.cash-close`, pinned right) · `__body` (scrolls) · `__foot`. App: Radix **Dialog** / **vaul**.

```html
<div class="cash-overlay" id="filters">
  <aside class="cash-drawer">                       <!-- --left to slide from the left -->
    <div class="cash-drawer__head"><div><h3 class="cash-drawer__title">Bộ lọc</h3></div>
      <button class="cash-close" data-modal-close></button></div>
    <div class="cash-drawer__body"> … </div>
    <div class="cash-drawer__foot"> … </div>
  </aside>
</div>
```

## Tabs

`.cash-tabs` > `.cash-tab` (add `.is-active`), panels `.cash-tab-panel` (`hidden` to hide).
Underline default; `.cash-tabs--pill` = segmented control (Thu/Chi, time range);
`.cash-tabs--boxed` = sharp-cornered, high-contrast (solid track + inset thumb, inverts in dark).
In the docs wrap in `[data-tabs]` with `data-tab`/`data-panel` for the JS switch.

```html
<div data-tabs>
  <div class="cash-tabs"><button class="cash-tab is-active" data-tab="a">Tổng quan</button>
    <button class="cash-tab" data-tab="b">Giao dịch</button></div>
  <div class="cash-tab-panel" data-panel="a">…</div>
  <div class="cash-tab-panel" data-panel="b" hidden>…</div>
</div>
```

## Tooltip

Pure-CSS hover/focus hint. `.cash-tooltip` wraps the trigger + `.cash-tooltip__bubble`.

```html
<span class="cash-tooltip">
  <button class="cash-btn cash-btn--icon" aria-label="Thông tin">ⓘ</button>
  <span class="cash-tooltip__bubble">Cập nhật 5 phút trước</span>
</span>
```
App: Radix Tooltip when you need smart positioning / delay.

## Breadcrumb

`.cash-breadcrumb` with `<a>` links, `.cash-breadcrumb__sep` between, `.cash-breadcrumb__current`
for the last (current) crumb.

```html
<nav class="cash-breadcrumb"><a href="#">Trang chủ</a>
  <span class="cash-breadcrumb__sep">/</span>
  <span class="cash-breadcrumb__current">Chi tiết</span></nav>
```

## Pagination

`.cash-pagination` with `.cash-page` items (`.is-active` current, `disabled` at edges,
`.cash-page--gap` for `…`). Fits a `.cash-card__foot`.

```html
<nav class="cash-pagination">
  <button class="cash-page" disabled aria-label="Trước">‹</button>
  <a class="cash-page is-active" aria-current="page">1</a>
  <a class="cash-page">2</a>
  <button class="cash-page" aria-label="Sau">›</button>
</nav>
```

## Avatar

`.cash-avatar` (image or initials). Sizes `--sm|--lg`, shape `--square`. Stack with
`.cash-avatar-group`. Give it a category hue via inline `background`/`color` if needed.

```html
<span class="cash-avatar">VD</span>
<span class="cash-avatar"><img src="…" alt="" /></span>
<div class="cash-avatar-group"><span class="cash-avatar">A</span><span class="cash-avatar">+3</span></div>
```

## Progress

`.cash-progress` > `.cash-progress__bar` (set `width`). Bar tone `--success|--warning|--danger`.
`--lg` for a chunkier bar. Ideal for "đã chi / ngân sách".

```html
<div class="cash-progress"><div class="cash-progress__bar cash-progress__bar--warning" style="width:82%"></div></div>
```

## Accordion

Built on native `<details>` (no JS). `.cash-accordion` > `.cash-accordion__item` (a
`<details>`) > `<summary>` + `.cash-accordion__body`.

```html
<div class="cash-accordion">
  <details class="cash-accordion__item" open>
    <summary>Câu hỏi</summary>
    <div class="cash-accordion__body">Trả lời…</div>
  </details>
</div>
```

## Divider

`.cash-divider` (horizontal). `--dashed` (nét đứt), `--vertical` (between inline clusters),
`--label` (line with centred text).

```html
<hr class="cash-divider cash-divider--dashed" />
<div class="cash-divider--label">HOẶC</div>
<span class="cash-divider--vertical"></span>
```

## Skeleton

Shimmer placeholder while loading. `.cash-skeleton` + `--text|--title|--circle`; size with
inline width/height.

```html
<div class="cash-skeleton cash-skeleton--title"></div>
<div class="cash-skeleton cash-skeleton--text" style="width:60%"></div>
<div class="cash-skeleton cash-skeleton--circle" style="width:40px;height:40px"></div>
```

## Empty state

`.cash-empty` with `__icon`, `__title`, `__msg`, and usually one primary action.

```html
<div class="cash-empty">
  <div class="cash-empty__icon">🧾</div>
  <p class="cash-empty__title">Chưa có giao dịch</p>
  <p class="cash-empty__msg">Thêm giao dịch đầu tiên để bắt đầu.</p>
  <button class="cash-btn">＋ Thêm giao dịch</button>
</div>
```

## Tree

Nested categories, unlimited depth. `ul.cash-tree` > `li.cash-tree__node` (`.is-collapsed`
to fold) > `.cash-tree__row` + nested `ul.cash-tree__children`. Row parts: `__toggle`
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
<ul class="cash-tree" data-tree>
  <li class="cash-tree__node">
    <div class="cash-tree__row" draggable="true">
      <button class="cash-tree__toggle"></button>   <!-- chevron via icon font; empty -->
      <span class="cash-tree__handle"></span>        <!-- 6-dot grip icon; empty -->
      <span class="cash-tree__label">Chi tiêu</span><span class="cash-tree__meta">128</span>
    </div>
    <ul class="cash-tree__children">
      <li class="cash-tree__node"><div class="cash-tree__row" draggable="true">
        <button class="cash-tree__toggle is-leaf"></button>
        <span class="cash-tree__handle"></span>
        <span class="cash-tree__label">Ăn uống</span></div></li>
    </ul>
  </li>
</ul>
```
Docs drag = vanilla HTML5 DnD (reorder + reparent, blocks dropping into its own descendant).
App: **dnd-kit** for the interaction; keep the `cash-tree*` classes for the look.

---

## Border & radius

Conventions, not many classes. Widths: `--cash-border` (1px hairline, default) ·
`--cash-border-strong` (1px, stronger); 2px for large blocks that must read. Radii:
`--cash-radius-sm|-(base 10px)|-lg|-pill`, or `0` for the sharp look (boxed tabs). **This site
does not use left-accent bars** — express a tone with a full **outline + soft background**
(like a capsule): `border: 1px solid color-mix(in srgb, var(--cash-danger) 55%, var(--cash-border)); background: var(--cash-danger-soft)`.
Use **dashed** to signal "empty / droppable / optional": `.cash-card--dashed`,
`.cash-divider--dashed`, `.cash-sortable__ph`. The left-accent bar is documented on the Border page
as a **non-default variant** (a thin tone marker for feed / notification lists or quotes) — use with
intent, not as a component default.

## Charts

SVG/CSS finance visuals — no chart lib in the skill. Palette tokens: `--cash-chart-income` /
`--cash-chart-expense` (**bright** green/red — `#22c55e` / `#ef4444`, a step lighter than the semantic
`-success/-danger` so a filled bar isn't muddy), `--cash-chart-1…8` (categorical), `--cash-chart-grid`,
`--cash-chart-axis` (brighter in dark). Pieces:
- **Line/area** — `<polyline class="cash-series-line">` + `<path class="cash-series-area">`; each
  point is `<g class="cash-point">` (an invisible `__hit` circle + `.cash-series-dot` + a
  `.cash-point__tip` that fades in on hover — pure SVG, no JS). Axis/grid via `.cash-axis-line` /
  `.cash-grid-line` / `.cash-axis-label`; colour via inline `stroke`/`fill: var(--cash-chart-*)`.
- **Bars** (CSS) — `.cash-bars` (faint gridlines built in) > `.cash-bars__col` with `.cash-bar`
  (`--income|--expense`, `height:%`) + `.cash-bars__label`; optional `.cash-bar__val` shows on column
  hover. (Base uses `.dark :where(.cash-bar)` so the income/expense tones survive dark mode.)
- **Combo (bar + line)** — draw `<rect>` bars first, then overlay a `.cash-series-line` + `.cash-point`
  dots on the same axis (e.g. chi as bars, thu as the line) → one chart, two encodings.
- **Horizontal ranked bars** — *not* a new component: `.cash-progress` rows inside a `.cash-stack`
  (label + value above each), tinted per category (`background:var(--cash-chart-N)`); longest = 100%.
  Best for ranking many categories (top spend / top debt) where a donut gets crowded.
- **Donut** — `<circle pathLength="100" stroke-dasharray="<pct> 100" stroke-dashoffset="-<cumulative>">`
  inside `<g transform="rotate(-90 …)">`; shorten each `<pct>` by ~1 for a thin gap between slices
  (`.cash-donut__track` = surface colour, so gaps read clean). `.cash-donut__center-value|-label` centre.
- **Thin / rounded donut & progress ring** — put `.cash-arc` (+ `--round` for soft pill caps) on the
  segments, with a THIN `stroke-width` (~10) and bigger gaps (~5 path-units) so the pill caps actually
  show. A progress ring (budget/goal gauge) = one `.cash-arc--round` over a `.cash-ring__track`, with
  `.cash-donut__center-*` text; colour it by the progress tones (neutral/`chart-1` &lt; ~80% · warning ·
  danger), not amber by default.
- **Colour schemes** — wrap a chart in `.cash-chart-scheme--mono` (grey) or `--blue` (one-hue): each
  series is mixed from a single ink toward the canvas. Add `.cash-chart-ramp--N` (N = number of series)
  to spread them evenly from 100% → 25% strength so no two steps look alike — a fixed grey-900…-200 set
  clumps at the dark end and reads the same; without a count an even up-to-8 spread is used. Both invert
  light↔dark; put the scheme on `:root` (via Config) to apply site-wide when multi-colour is too busy.
- **Budget** — reuse `.cash-progress` (success < ~80% · warning ~80–99% · danger ≥100%).
- **Sparkline** — `.cash-spark` with a single `<path>` (tiny trend in a stat card).
- **Legend / tooltip** — `.cash-legend` + `.cash-legend__item` + `__dot` (+ `__val`); `.cash-chart__tip`.

```html
<div class="cash-bars">
  <div class="cash-bars__col">
    <div class="cash-bar cash-bar--income"  style="height:83%"></div>
    <div class="cash-bar cash-bar--expense" style="height:27%"></div>
    <span class="cash-bars__label">T3</span>
  </div>
</div>
```
App: **Recharts**, fed the same `--cash-chart-*` tokens so it matches; keep `.cash-chart__tip`
for the tooltip look.

## Sortable list / grid

Flat drag-to-reorder (one level — use **Tree** for nesting). `.cash-sortable` (list) or
`.cash-sortable--grid` (card grid) with `data-sortable`; each `.cash-sortable__item`
(`draggable="true"`) holds a `.cash-grip` + `.cash-sortable__label` (+ `__meta`). While
dragging, the JS inserts a dashed `.cash-sortable__ph` at the drop position.

```html
<div class="cash-sortable" data-sortable>
  <div class="cash-sortable__item" draggable="true">
    <span class="cash-grip"></span>
    <span class="cash-sortable__label">Ăn uống</span>
    <span class="cash-sortable__meta">−3.280.000 ₫</span>
  </div>
</div>
```
App: **dnd-kit** (`@dnd-kit/sortable`); keep the `cash-sortable*` classes.

**Sortable table rows:** add `--sortable` to a `.cash-table`, give each `<tr>` a `.cash-row-grip`
cell (holding `.cash-grip`) + `draggable="true"`, and `data-sortable-rows` on the `<tbody>`. While
dragging, the JS inserts a dashed `.cash-row-ph` row at the drop position. App → dnd-kit over the rows.

## Icons

Icons are an **icon font** (Material Symbols Rounded, `@import`ed in `cashy-ui.css`) — never
hand-drawn. Inline: `<span class="cash-ico">expand_more</span>` (the text is a ligature). Sizes
`--xs|--sm|--lg|--xl`; tune globally via `--cash-ico-size` / `--cash-ico-weight` (heavier = crisper —
the Config panel drives these). A few components inject their icon via `::before` (accordion, tree
toggle, close ×) and stay empty in markup; a `<select>` gets its chevron from a `.cash-ico` inside
`.cash-select-wrap`. Swap `--cash-icon-font` to use a different set (e.g. lucide) in the app.

```html
<span class="cash-ico">search</span>
<span class="cash-ico cash-ico--sm">expand_more</span>
<button class="cash-close" aria-label="Đóng"></button>   <!-- the × comes from ::before -->
```

## Grid / Layout

Composable layout utilities (no colour/meaning — just placement; swap for Tailwind flex/grid if you
prefer):
- `.cash-cluster` — a row that **wraps**; align via `--end` / `--center` / `--between` / `--stretch`
  (equal-size items fill the row) / `--tight` / `--nowrap`.
- `.cash-grid` — 2-D grid: `--auto` (auto-fill by `--cash-grid-min`), `--2/--3/--4` (fixed cols, → 1
  col on mobile), `--equal` (equal columns in one row).
- `.cash-stack` — vertical flow with a gap (`--tight` / `--loose`); the vertical partner of `--cluster`.
- `.cash-container` — centered max-width column (`--narrow` 720 · default 1120 · `--wide` 1320px).
- `.cash-ratio` — hold an aspect ratio (`--1x1` / `--4x3` / `--16x9`) for embeds / receipt images.

```html
<div class="cash-cluster cash-cluster--between"><span>Tổng chi</span><span class="cash-num">−11,8tr</span></div>
<div class="cash-grid cash-grid--auto" style="--cash-grid-min:150px"> … </div>
```

## Scroll areas

`.cash-scroll-y` — put on any `overflow-y` region (a bounded list, a category picker, a side panel). It
gives a **thin, theme-aware scrollbar** (transparent track + neutral-border thumb, so no bright OS bar
clashing on dark or reading as a divider) and **`scroll-padding` tail room**; add `--pad` for extra
bottom space so the last item scrolls clear of the edge (easier to read/tap/select). The built-in table
body (`.cash-table-scroll`) and dropdown `.cash-menu` already carry the themed scrollbar. Scale the tail
to the case — a short menu needs little, a long list wants more.

```html
<div class="cash-scroll-y cash-scroll-y--pad" style="max-height:320px"> … danh mục dài … </div>
```

## Config / Tweak

A **docs-only** playground (gear in the topbar, or the Config page) that slides in a drawer to tune
tokens **live**: font, icon size/weight, radii (global + per button/card/input), border width, shadow,
colours (for the theme being viewed), chart scheme, and docs knobs (`--cash-demo-bw`,
`--cash-demo-shadow`, `--cash-doc-divider`). **Xuất .md** downloads the changed `:root{}` block to paste
into source (or hand to an AI). It only sets CSS variables on the docs root — it never edits
`cashy-ui.css`, so the shipped primitives are never touched.

---

## Using these in cashy (React + Tailwind)

The markup above is framework-agnostic HTML + classes, so it works in a `.tsx` return
as-is (remember `className`, and self-close void tags). For the recommended React
component wrappers, CVA variants, and how the tokens plug into Tailwind/shadcn, see
`cashy-integration.md`.

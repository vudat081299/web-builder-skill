# Cashy UI — Component Catalog

The lookup table for "I'm building X → use this, here's the markup." Copy the snippet,
swap the data, done. Do **not** redesign from scratch — that's the whole point of this
library. See it rendered live in `assets/index.html`.

Scope so far: **Buttons**, **Capsules**, **Stat/KPI cards**, **Tables**, and **Form
inputs**. Navigation, modals, toasts, and charts come in later rounds.

---

## Quick decision guide

| You're building… | Use | Section |
|---|---|---|
| Any clickable action (save, add, cancel, delete) | **Button** | [Buttons](#buttons) |
| A status / category / method label inside a cell | **Capsule** | [Capsules](#capsules) |
| A dashboard KPI (balance, income, spend, change %) | **Stat card** | [Stat cards](#stat--kpi-cards) |
| A list of accounts, categories, simple records | Table — basic | [Tables](#tables) |
| A transaction / activity feed with amounts + status | Table — transactions (hero) | [Tables](#tables) |
| A budget / breakdown with many rows | Table — `--striped --compact` | [Tables](#tables) |
| A long scrollable list, header must stay visible | Table — `--sticky` | [Tables](#tables) |
| Debts / receivables / anything with overdue-vs-paid | Table + row-state + colour | [Tables](#tables) |
| A totals / summary line under a table | `<tfoot>` row | [Tables](#tables) |
| A data-entry form (add/edit transaction, settings) | **Form controls** | [Forms](#form-controls) |
| A money input, a category picker, a yes/no setting | input-group / select / switch | [Forms](#form-controls) |

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

---

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
```

Status → tone mapping used across cashy (keep it consistent):
`Đã trả / Đã nhận / Hoàn tất` → **success** · `Chờ / Sắp đến hạn` → **warning** ·
`Quá hạn / Thất bại / Nợ xấu` → **danger** · `Đang xử lý` → **info` · everything else → **neutral**.

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
`cash-row--danger` · `cash-row--warning` · `cash-row--success` — adds a subtle tint and a
left accent bar. For overdue debts, bad debt, over-budget, etc.

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

## Form controls

Wrap each control in `.cash-field` (label + control + help/error stacked). Controls are
neutral; the only colour is the red invalid state.

```
CONTROLS: .cash-input · .cash-select · .cash-textarea · .cash-check · .cash-radio · .cash-switch
LABELS:   .cash-label (+ .cash-label__opt for "(tùy chọn)")
HELP:     .cash-help (muted) · .cash-error (red)
INVALID:  add --invalid to the control (.cash-input--invalid …) when showing .cash-error
GROUP:    .cash-input-group with .cash-input-group__addon for prefix/suffix (₫, %, .00)
```

```html
<!-- money input with a ₫ suffix -->
<div class="cash-field">
  <label class="cash-label">Số tiền</label>
  <div class="cash-input-group">
    <input class="cash-input" inputmode="numeric" value="1.280.000" />
    <span class="cash-input-group__addon">₫</span>
  </div>
</div>

<!-- invalid + error -->
<div class="cash-field">
  <label class="cash-label">Email nhắc nợ</label>
  <input class="cash-input cash-input--invalid" value="sai-email" />
  <span class="cash-error">Email không hợp lệ.</span>
</div>

<!-- yes/no setting -->
<label class="cash-switch">
  <input type="checkbox" checked /><span class="cash-switch__track"></span> Đã thanh toán
</label>
```

Money fields: use `inputmode="numeric"`, right sentinel `₫` as an addon, and format the
display value with the app's locale (`1.280.000`).

---

## Using these in cashy (React + Tailwind)

The markup above is framework-agnostic HTML + classes, so it works in a `.tsx` return
as-is (remember `className`, and self-close void tags). For the recommended React
component wrappers, CVA variants, and how the tokens plug into Tailwind/shadcn, see
`cashy-integration.md`.

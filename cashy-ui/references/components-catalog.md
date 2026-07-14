# Cashy UI — Component Catalog

The lookup table for "I'm building X → use this, here's the markup." Copy the snippet,
swap the data, done. Do **not** redesign from scratch — that's the whole point of this
library. See it rendered live in `assets/index.html`.

Scope of v1: **Capsules** and **Tables**. Buttons, cards, forms, nav, modals, toasts,
charts come in later rounds.

---

## Quick decision guide

| You're building… | Use | Section |
|---|---|---|
| A status / category / method label inside a cell | **Capsule** | [Capsules](#capsules) |
| A list of accounts, categories, simple records | Table — basic | [Tables](#tables) |
| A transaction / activity feed with amounts + status | Table — transactions (hero) | [Tables](#tables) |
| A budget / breakdown with many rows | Table — `--striped --compact` | [Tables](#tables) |
| A long scrollable list, header must stay visible | Table — `--sticky` | [Tables](#tables) |
| Debts / receivables / anything with overdue-vs-paid | Table + row-state + colour | [Tables](#tables) |
| A totals / summary line under a table | `<tfoot>` row | [Tables](#tables) |

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

## Using these in cashy (React + Tailwind)

The markup above is framework-agnostic HTML + classes, so it works in a `.tsx` return
as-is (remember `className`, and self-close void tags). For the recommended React
component wrappers, CVA variants, and how the tokens plug into Tailwind/shadcn, see
`cashy-integration.md`.

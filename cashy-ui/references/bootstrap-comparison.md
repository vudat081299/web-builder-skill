# Cashy UI vs Bootstrap 5.3 — coverage & structure

Why this file: to answer "are we missing anything?" honestly, and to record *deliberate* omissions so
nobody re-adds them by reflex. Bootstrap is the yardstick for **breadth**; Cashy UI is re-cut minimalist,
finance-first, and defers interactive behaviour to Radix/shadcn (see `cashy-integration.md`). Matching
Bootstrap 1:1 is a non-goal.

## Component inventory (Bootstrap 5.3 → Cashy UI)

| Bootstrap component | Cashy UI | Notes |
|---|---|---|
| Accordion | ✅ `cash-accordion` | native `<details>` |
| Alerts | ✅ `cash-alert` | soft tint + outline, × top-right |
| Badge | ✅ `cash-cap` (+ `cash-tag`) | capsules cover badges; tags add `#` |
| Breadcrumb | ✅ `cash-breadcrumb` | |
| Buttons | ✅ `cash-btn` | + social-login, `--icon`, `--block` |
| Button group | ✅ `cash-btn-group` | segmented |
| Card | ✅ `cash-card` | + `--dashed/--flat/--hover` |
| Carousel | ❌ **skipped** | heavy/branded; a finance app rarely needs it |
| Close button | ✅ `cash-close` | always top-right |
| Collapse | 🟡 partial | `cash-accordion` covers the common case; no generic toggle-collapse |
| Dropdowns | ✅ `cash-dropdown` / `cash-menu` | behaviour → Radix |
| List group | ✅ `cash-list` | settings/accounts |
| Modal | ✅ `cash-modal` + `cash-overlay` | behaviour → Radix Dialog |
| Navbar | ✅ `cash-navbar` | **added** — top app bar |
| Navs & tabs | ✅ `cash-nav` + `cash-tabs` | nav = page links; tabs = panel switch |
| Offcanvas | ✅ `cash-drawer` | slide-in over the scrim |
| Pagination | ✅ `cash-pagination` | |
| Placeholders | ✅ `cash-skeleton` | loading shimmer |
| Popovers | 🟡 via dropdown + tooltip | no separate primitive (kept minimal) — style a Radix Popover with `cash-menu`/`cash-card` + `cash-tooltip__bubble` |
| Progress | ✅ `cash-progress` | also budget "đã chi / hạn mức" |
| Scrollspy | ❌ **skipped** | a docs-nav behaviour; the app uses its router |
| Spinners | ✅ `cash-spinner` | on buttons + `.is-loading` |
| Toasts | ✅ `cash-toast` / `cash-toaster` | behaviour → sonner |
| Tooltips | ✅ `cash-tooltip` | pure-CSS bubble |
| Forms (controls, select, checks, range, input-group, validation) | ✅ full | + colour input, file dropzone, **switch locked** state — beyond Bootstrap |
| Floating labels | ❌ not used | Cashy uses top `cash-label` (clearer for dense finance forms) |
| Layout (12-col grid, breakpoints, gutters) | 🟡 by design | flex-first utilities instead — see below & design-principles §17 |

**Only in Cashy UI (finance-specific, no Bootstrap equivalent):** tags (`#` category chips), stat/KPI cards,
charts (line/bars/combo/donut/sparkline + budget), category **tree** (drag reorder/reparent), **sortable**
list/grid/rows, **receipt** (hoá đơn — torn-paper slip), tinted category capsules, social-login buttons,
and the live **Config** token playground.

## The popup family — do we have it?

Yes: **modal, drawer (offcanvas), dropdown/menu, tooltip, toast** — the full practical set. The one
Bootstrap piece we don't ship as its own class is **popover**; it's covered by dropdown (click panel) +
tooltip (hover bubble). Add a dedicated `cash-popover` only if a real screen needs an anchored, titled,
click-triggered card that neither covers — not preemptively.

## Layout: Bootstrap makes it a *foundation*; we don't (on purpose)

Bootstrap treats layout as core: `.container` → `.row` → `.col-{bp}-{n}`, a 12-column grid, five
breakpoints (sm/md/lg/xl/xxl), and gutter utilities. Most Bootstrap pages are scaffolded on it.

Cashy UI keeps layout as a **small flex-first utility set** — `.cash-cluster` (wrap row), `.cash-stack`
(column), `.cash-grid` (`--auto/-2/-3/-4/--equal`), `.cash-container`, `.cash-ratio` — each collapsing
sensibly on mobile, no breakpoint bookkeeping. Reasoning (full version in `design-principles.md §17`):
in the cashy app **Tailwind already owns** responsive columns/breakpoints, so a second 12-col system would
collide and double the vocabulary; and finance dashboards need "wrap these chips / stack this form / reflow
these cards", which the five utilities already express. **Recommendation: do not adopt a Bootstrap-style
grid foundation.**

## Docs sidebar (BOC) structure — Bootstrap vs ours

- **Bootstrap** groups its left nav by **technical layer**: *Getting started · Customize · Layout · Content
  · Forms · Components · Helpers · Utilities · Extend*. Layout and Utilities are first-class top sections.
- **Cashy UI** groups by **user intent / job-to-be-done**: *Nền tảng (foundation) · Hành động (actions) ·
  Nhập liệu (input) · Hiển thị dữ liệu (data) · Phản hồi (feedback) · Điều hướng (navigation) · Biểu đồ
  (charts) · Cấu trúc (structure)*. A builder thinks "I need to show data" → **Hiển thị dữ liệu**, not
  "is this a Component or a Utility?".

Both open with a foundation section (Bootstrap: Getting started/Customize; Cashy: Nền tảng — colour ladder,
tokens, typography). The difference: Cashy folds **layout into "Cấu trúc"** as utilities rather than a
foundational grid section — consistent with the layout decision above.

## Honest pros / cons

**Cashy UI wins:** minimal + neutral-first; finance-tuned (tabular money, budget progress, receipt, tags,
debt tables); token-driven theming with real dark mode + a live Config export; ships **zero JS** and sits
beside Radix/Tailwind without lock-in; docs organised by intent.

**Cashy UI trade-offs:** not drop-in interactive — you must wire Radix/dnd-kit/sonner for behaviour; no
responsive 12-col grid (delegated to Tailwind); a far smaller utility API than Bootstrap; depends on the
Material Symbols icon font for a few `::before` glyphs. All are deliberate consequences of "styling layer,
not a framework."

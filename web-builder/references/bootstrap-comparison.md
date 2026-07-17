# Web Builder vs Bootstrap 5.3 — coverage & structure

Why this file: to answer "are we missing anything?" honestly, and to record *deliberate* omissions so
nobody re-adds them by reflex. Bootstrap is the yardstick for **breadth**; Web Builder is re-cut minimalist
and **standalone** (zero-build, drop-in), owning the *look* and leaving interactive behaviour to a
behaviour engine (Radix/shadcn etc.; see `integration.md`). Finance is its flagship use, not its limit.
Matching Bootstrap 1:1 is a non-goal — and neither is matching Tailwind's utility firehose (see the
Tailwind note below).

## Component inventory (Bootstrap 5.3 → Web Builder)

| Bootstrap component | Web Builder | Notes |
|---|---|---|
| Accordion | ✅ `wb-accordion` | native `<details>` |
| Alerts | ✅ `wb-alert` | soft tint + outline, × top-right |
| Badge | ✅ `wb-cap` (+ `wb-tag`) | capsules cover badges; tags add `#` |
| Breadcrumb | ✅ `wb-breadcrumb` | |
| Buttons | ✅ `wb-btn` | + social-login, `--icon`, `--block` |
| Button group | ✅ `wb-btn-group` | segmented |
| Card | ✅ `wb-card` | + `--dashed/--flat/--hover` |
| Carousel | ❌ **skipped** | heavy/branded; rarely needed and hard to keep minimal |
| Close button | ✅ `wb-close` | always top-right |
| Collapse | ✅ `wb-collapse` | one standalone show/hide region (`wb-accordion` for grouped) |
| Dropdowns | ✅ `wb-dropdown` / `wb-menu` | behaviour → Radix |
| List group | ✅ `wb-list` | settings/accounts |
| Modal | ✅ `wb-modal` + `wb-overlay` | behaviour → Radix Dialog |
| Navbar | ✅ `wb-navbar` | **added** — top app bar |
| Navs & tabs | ✅ `wb-nav` + `wb-tabs` | nav = page links; tabs = panel switch |
| Offcanvas | ✅ `wb-drawer` | slide-in over the scrim |
| Pagination | ✅ `wb-pagination` | |
| Placeholders | ✅ `wb-skeleton` | loading shimmer |
| Popovers | ✅ `wb-popover` | click-toggled card + arrow + × — richer than tooltip, not a menu; behaviour → Radix Popover |
| Progress | ✅ `wb-progress` | also budget "đã chi / hạn mức" |
| Scrollspy | ❌ **skipped** | a docs-nav behaviour; the app uses its router |
| Spinners | ✅ `wb-spinner` | on buttons + `.is-loading` |
| Toasts | ✅ `wb-toast` / `wb-toaster` | behaviour → sonner |
| Tooltips | ✅ `wb-tooltip` | pure-CSS bubble |
| Forms (controls, select, checks, range, input-group, validation) | ✅ full | + a **custom colour picker** + **preset colour swatches** + colour input, file dropzone, **switch locked** state — beyond Bootstrap |
| Floating labels | ❌ not used | we use a top `wb-label` (clearer for dense forms; a deliberate call, not a gap) |
| Layout (12-col grid, breakpoints, gutters) | 🟡 by design | flex-first utilities instead — **with full flex alignment** (justify / align / self / grow); no 12-col scaffold. See below & design-principles §17 |
| Flex/align utilities (justify-content, align-items, align-self, flex-fill) | ✅ | on `.wb-cluster` / `.wb-stack` (`--start/end/center/between/around/evenly`, `--top/middle/bottom/baseline`) + `.wb-grow` / `.wb-self--*` |

**Only in Web Builder (no Bootstrap 5 equivalent):** tags (`#` category chips), stat/KPI cards,
charts (line/bars/combo/donut/sparkline + budget), category **tree** (drag reorder/reparent), **sortable**
list/grid/rows, **receipt** (hoá đơn — torn-paper slip), tinted category capsules, social-login buttons,
a **steps/stepper** (`wb-steps` — wizard · timeline; Bootstrap has none), a **media object** (`wb-media` —
figure + body; Bootstrap 5 dropped its `.media`), and the live **Config** token playground.

## The popup family — do we have it?

Yes — the full practical set: **modal, drawer (offcanvas), dropdown/menu, tooltip, toast, and popover**.
`wb-popover` is a click-toggled, anchored card with an arrow + × dismiss (richer than a tooltip, not a
menu); it closed the last Bootstrap popup gap, so every overlay Bootstrap ships now has a Web Builder
primitive. Behaviour still delegates to a behaviour engine (Radix Popover/Dialog etc.; see `integration.md`).

## Layout: Bootstrap makes it a *foundation*; we don't (on purpose)

Bootstrap treats layout as core: `.container` → `.row` → `.col-{bp}-{n}`, a 12-column grid, five
breakpoints (sm/md/lg/xl/xxl), and gutter utilities. Most Bootstrap pages are scaffolded on it.

Web Builder keeps layout as a **small flex-first utility set** — `.wb-cluster` (wrap row), `.wb-stack`
(column), `.wb-grid` (`--auto/-2/-3/-4/--equal`), `.wb-container`, `.wb-ratio` — each collapsing
sensibly on mobile, no breakpoint bookkeeping. The set carries **full flex alignment** so a row/column is
never hand-styled: cluster justifies (`--start/end/center/between/around/evenly`) and aligns
(`--top/middle/bottom/baseline`), stack aligns (`--start/center/end`), plus `.wb-grow` and `.wb-self--*` for
per-item control. What we skip is only the 12-column scaffold, not alignment. Reasoning (full version in `design-principles.md §17`):
a 12-col foundation is a lot of vocabulary (five breakpoints × twelve columns × gutters) for what real
pages actually need — "wrap these chips / stack this form / reflow these cards" — which the five utilities
already express. Keeping the set small is the **minimalist** call, not a deferral: the utilities are
**self-sufficient** (no Tailwind or any framework required), and if you *do* run Tailwind its grid is right
there for the rare true-12-col case. **Recommendation: do not adopt a Bootstrap-style grid foundation.**

## vs Tailwind (utility-first) — what we borrow, what we don't

Bootstrap measures **breadth of components**; Tailwind measures **breadth of low-level utilities**. Web
Builder is component-first, so it deliberately does **not** replicate Tailwind's utility firehose (a full
spacing scale, every flex/grid/position/type atom, arbitrary values). What it *does* take — kept minimal and
token-based:

- **Layout utilities** — `wb-cluster / wb-stack / wb-grid / wb-container / wb-ratio` plus their alignment
  modifiers (justify / align / `wb-grow` / `wb-self--*`) — the common flex/grid jobs *including* full
  alignment, but not hundreds of spacing/sizing atoms.
- **Design tokens** — one `--wb-*` variable set for colour / space / radius / shadow, editable live in
  Config: Tailwind's "constraints in a config", but as plain CSS variables with no build.
- **Dark mode off a class** — the same `.dark` model as Tailwind's `darkMode: "class"`.

What it intentionally leaves to Tailwind (if you run it) or to a one-off inline style: **generic spacing /
sizing / positioning utilities**. A full `m-*/p-*/w-*` scale would balloon the API and fight the minimalist
ethos, and component padding/gaps are already tokenised. Net: on Tailwind, the two compose (Web Builder for
the look, Tailwind for one-off spacing); off Tailwind, the built-ins are enough to build real pages.

## Docs sidebar (BOC) structure — Bootstrap vs ours

- **Bootstrap** groups its left nav by **technical layer**: *Getting started · Customize · Layout · Content
  · Forms · Components · Helpers · Utilities · Extend*. Layout and Utilities are first-class top sections.
- **Web Builder** groups by **user intent / job-to-be-done**: *Nền tảng (foundation) · Hành động (actions) ·
  Nhập liệu (input) · Hiển thị dữ liệu (data) · Phản hồi (feedback) · Điều hướng (navigation) · Biểu đồ
  (charts) · Cấu trúc (structure)*. A builder thinks "I need to show data" → **Hiển thị dữ liệu**, not
  "is this a Component or a Utility?".

Both open with a foundation section (Bootstrap: Getting started/Customize; Web Builder: Nền tảng — colour
ladder, tokens, typography, **and the flex-first layout utilities**). The difference from Bootstrap: Web
Builder keeps layout as a small utility set *inside* that foundation rather than as a separate 12-column
grid section — consistent with the layout decision above. **Cấu trúc** then holds only the structural
pieces: the drag-and-drop tree + sortable.

## Honest pros / cons

**Web Builder wins:** minimal + neutral-first; **standalone & zero-build** — one drop-in stylesheet that
composes with any stack (or none) without lock-in; finance-tuned as its flagship (tabular money, budget
progress, receipt, tags, debt tables); token-driven theming with real dark mode + a live Config export;
ships **zero JS**; docs organised by intent.

**Web Builder trade-offs:** not drop-in interactive — you pair it with a behaviour engine
(Radix/dnd-kit/sonner) for a11y; no responsive 12-col grid (a minimalism choice — the flex-first utilities
cover the real cases); a far smaller utility API than Bootstrap or Tailwind *by design*; depends on the
Material Symbols icon font for a few `::before` glyphs. All are deliberate consequences of "styling layer,
not a framework."

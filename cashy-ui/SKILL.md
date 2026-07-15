---
name: cashy-ui
description: >-
  Bộ component + design system cho web quản lý tài chính cá nhân (dự án cashy). LUÔN dùng
  skill này khi build hoặc sửa BẤT KỲ giao diện/UI nào cho cashy hay app tài chính cá nhân —
  thay vì tự thiết kế lại từ đầu (tốn token và lệch phong cách). Cung cấp: design tokens
  (ưu tiên trắng-đen-xám, có dark mode), typography & gợi ý font, form input (prefix/suffix, validation), capsule/badge, tag (#)
  cho giao dịch, và bảng (table) đẹp cho dữ liệu tiền (giao dịch, số dư, ngân sách, công
  nợ, thu/chi); biểu đồ (line/cột/donut/sparkline + thang màu), cây danh mục (tree) + kéo–thả sắp xếp (list/grid/bảng), tiện ích grid/layout, bộ icon (icon-font), và trang Config để tinh chỉnh token trực tiếp. Trigger: "build trang
  cashy", "thêm/làm component", "làm giao diện", "làm UI", "thiết kế bảng", "làm table",
  "badge/capsule/tag trạng thái", "card số dư/thu chi", "dashboard tài chính", "màn hình
  giao dịch", "màn hình công nợ", "build a cashy page", "financial table", "finance
  dashboard UI", "transaction list UI", "component library", "tag/nhãn giao dịch",
  "typography/kiểu chữ", "chọn font", "biểu đồ/chart/donut/sparkline", "cây danh mục/tree",
  "modal/dialog", "dropdown/menu", "tabs", "toast/thông báo", "card", "alert", "avatar",
  "pagination/phân trang", "tooltip", "accordion", "empty state", "skeleton", "config/tweak/playground", "grid/layout/wrap", "icon", "border/viền/bo
  góc", "kéo thả sắp xếp/sortable/list kéo thả". KHÔNG dùng cho logic
  backend/tính toán không liên quan giao diện, hay project không phải tài chính cá nhân.
---

# Cashy UI

A reusable component library + design system for **cashy**, a personal-finance web app.
Its reason to exist: designing UI from scratch every time is slow and burns tokens because
it triggers round after round of "fix this colour / this padding / this shape." This skill
removes that loop — the visual decisions are **already made and approved** and captured as
tokens, ready-made components, and copy-paste snippets. Your job is to **assemble approved
parts**, so the user reviews *content and layout*, not aesthetics.

## The one rule that saves tokens

**Do not invent styling.** Before writing any UI for cashy:

1. Read `references/components-catalog.md` to find the component that fits, then open its
   one-page demo `assets/pages/<id>.html` for the exact markup (a small, focused file).
2. Copy its snippet, swap in real data. Use `cash-*` classes and tokens — never hardcode
   colours, paddings, or radii.
3. If nothing fits, build the new piece **from existing tokens in the existing spirit**
   (see `references/design-principles.md`), add it to `cashy-ui.css`, create a demo page
   `assets/pages/<id>.html`, register it in `app.js` (the `NAV` list), and record it in the
   catalog. Then reuse it forever.

If you find yourself picking a hex value or a pixel padding by hand, stop — there is
almost certainly a token or class for it.

## What's in the box

| File | What it is | Read when |
|---|---|---|
| `assets/cashy-ui.css` | The library: design tokens + components (self-contained, no build). **The only file that ships to cashy.** | You need class names / token names, or are adding a component |
| `assets/pages/<id>.html` | Living docs, **one small file per primitive** (buttons, tables, tags, input, select, charts, config, layout…). | You want the exact markup for one component — open just that file, not a monolith |
| `assets/index.html` + `app.js` + `docs.css` | The docs **shell** (reused by every page): tree sidebar, hash router that loads one page at a time, theme toggle, copy, and the dual light/dark preview. | You're changing the docs site itself (nav, routing, chrome) — not a component |
| `references/components-catalog.md` | "Building X → use Y, here's the snippet" lookup | **Start here** for any build task |
| `references/design-principles.md` | The colour ladder, neutral shadow rule, number/typography/font rules | Building something new or making an aesthetic call |
| `references/cashy-integration.md` | How the CSS + tokens + React wrappers plug into cashy's React/Vite/Tailwind/shadcn/next-themes | Wiring the library into the actual cashy repo |
| `references/bootstrap-comparison.md` | Coverage vs Bootstrap 5.3 (what we have / skip / do differently), the popup set, the layout-foundation decision, and BOC structure | Deciding whether to add a component, or "do we have X?" |

## The colour ladder (summary — full version in design-principles.md)

Spend colour, don't sprinkle it. Lowest tier that does the job:

1. **white / black / grey** — the default for nearly everything.
2. **bright solid colour** — only for unmistakable status (paid = green, overdue / bad
   debt = red, due-soon = amber, info = blue).
3. **bright colour + low opacity (soft)** — the calm version of tier 2; default for status
   capsules and subtle row tints.

Classification (a category/method tag) is **not** status → keep it neutral grey. Only real
status earns colour.

## Current scope

Coverage maps to the **eight intent-groups** in the docs sidebar (this is the map; the exhaustive
roster with every modifier + copy-paste markup lives in `components-catalog.md` — **that's the single
source of truth**, kept in sync per-component, so it never drifts here):

- **Nền tảng** — colour ladder, tokens, typography scale, fonts guidance (system stack by default, swap
  `--cash-font`), border & radius, and a live **Config** playground that edits tokens and exports a `.md`.
- **Hành động** — buttons (incl. button-group, social-login with brand logos), dropdown / menu.
- **Nhập liệu** — text input (prefix/suffix + icon addons), select, textarea, checkbox/radio, switch
  (incl. a **locked** state), range, file + dropzone, colour; validation via the `.is-invalid` state.
- **Hiển thị dữ liệu** — card, tables (basic → transactions → striped/compact/bordered/sticky/debt),
  list group, stat/KPI cards, capsules/badges (incl. `--tinted` category hue), tags, avatar, **receipt**
  (hoá đơn — a torn-paper slip).
- **Phản hồi** — alert, toast, modal/dialog, drawer/offcanvas, progress, skeleton, empty state, tooltip.
- **Điều hướng** — navbar, nav / menu, sidenav (app rail), tabs, breadcrumb, pagination, accordion, divider.
- **Biểu đồ** — line/area, income-vs-expense bars, combo bar+line, horizontal ranked bars, donut / thin
  donut / progress ring, budget progress, sparkline + finance palette, mono/blue schemes with count-aware ramps.
- **Cấu trúc** — drag-and-drop **tree** (reorder + reparent), flat **sortable** list/grid/rows, and the
  grid/layout utilities (`.cash-cluster`, `.cash-grid`, `.cash-stack`, `.cash-container`, `.cash-ratio`).

Three standing decisions shape the set:

1. **Dogfooded docs.** Every page is built from the library's own `cash-*` primitives (cluster / grid /
   stack / nav / sidenav / card…); `docs.css` holds only chrome the library has no equivalent for.
2. **Style here, behaviour in the app.** Interactive components run on a tiny vanilla toggle in the docs
   and map onto Radix/shadcn + sonner + dnd-kit in cashy (see `cashy-integration.md`).
3. **Bootstrap-benchmarked, re-cut minimalist** (white-black-grey first) — incl. a minimal navbar / nav /
   sidenav for app shells; only heavy or branded pieces (carousel, scrollspy) are intentionally skipped.
   Layout stays a small flex/grid utility set — **not** a 12-column foundation — because in the app Tailwind
   already owns responsive columns/breakpoints (see `design-principles.md` §17).

**House conventions to keep:** icons come from an **icon font** — Material Symbols, `@import`ed in
`cashy-ui.css`; use `<span class="cash-ico">name</span>` (weight ~600 so they're crisp), **never
hand-drawn** — or an emoji when one fits; a tone is shown with an **outline + soft background** (like
a capsule) — **no left-accent bars** on components (a documented non-default variant on the Border page);
form validation is a **state**, `.is-invalid` (not `--invalid`); border width is one knob (`--cash-bw`);
lean on **dashed** borders for "empty / droppable / optional". On **dark**, shadows flip to a soft
**light** lift (a black shadow is invisible on a dark canvas) — build with `--cash-shadow-*` and it's
automatic. Scroll regions get a thin **theme-aware scrollbar + tail room** (`.cash-scroll-y`, and the
built-in table/menu) so the last item scrolls clear and the bar doesn't clash. **Disabled** and **locked**
are distinct states: *disabled* reads inert (dim neutral track, `not-allowed`); *locked* keeps the real
on/off value but puts a lock **beside** the control that **shakes** when a blocked change is attempted —
**never overlay** a lock on the control itself. A dismiss **×** (`.cash-close`) always sits **top-right**
of its container (alert / toast / modal / drawer), never vertically centred. Brand/provider logos (social
login) are the **one** allowed colour exception — the rest of the button stays neutral. Watch the
dark-mode `:where()` rule (design-principles §6) so tones don't grey out. When asked for a new component, build it in the same system and add it to the
library (new `cash-*` classes + a `pages/<id>.html` demo + an `app.js` `NAV` entry + a catalog entry).

## Working with the user

The user iterates visually and prefers to review in the browser. The docs are a small
client-side app (the router `fetch`es `pages/*.html`), so they **must be served over HTTP** —
opening `index.html` via `file://` will fail to load pages. Serve the assets folder:

```bash
cd cashy-ui/assets && python3 serve.py 8777   # open http://localhost:8777
```

`serve.py` is a thin wrapper over `http.server` that adds `Cache-Control: no-store`, so a **normal
reload shows edits** to `cashy-ui.css` / `docs.css` / `app.js` / `pages/*` — no hard-refresh needed
(the router also `fetch`es pages with `cache: "no-store"`). Plain `python3 -m http.server 8777` still
works, but it caches, so you'd have to **hard-refresh** (Cmd/Ctrl+Shift+R) after each edit.

Deep-link to a group with the hash, e.g. `http://localhost:8777/#/tables` or `#/tags`. Icons + the Config
font picker load from Google Fonts (Material Symbols + web fonts), so the docs want **internet**;
the **Config** panel (gear in the topbar) tweaks tokens live and exports a `.md`.

Default the docs preview to the look the user prefers judging first: **light mode,
white-black-grey**. Colour and dark mode are there, but neutral-first is the house style.
When the user gives feedback, change the **token or component once** so every screen
benefits — never patch a single page.

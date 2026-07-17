---
name: web-builder
description: >-
  Thư viện component CSS + design system tối giản (minimalism) để build giao diện web nói chung —
  viết tay, token-based, không cần build, drop-in một file CSS, prefix wb-* nên ghép được với mọi
  stack mà không xung đột. Dùng skill này khi build hoặc sửa bất kỳ UI web nào theo phong cách
  trắng-đen-xám (có dark mode): ráp từ các thành phần đã duyệt (class wb-* + design tokens) thay vì
  thiết kế lại từ đầu (tốn token, lệch phong cách). Mạnh nhất cho web tài chính cá nhân (bảng tiền,
  số dư/thu-chi, ngân sách, công nợ, hoá đơn) vì bộ component hiện tại hợp — nhưng dùng tốt cho web
  bất kỳ: buttons/dropdown, form input, card, capsule/badge/tag, biểu đồ (chart/donut/sparkline),
  điều hướng (navbar/sidenav/tabs), modal/drawer/toast, cây kéo-thả, tiện ích grid/layout, và trang
  Config chỉnh token. Ví dụ: build web/trang tối giản, dashboard, bảng dữ liệu, form, landing,
  finance/financial UI. KHÔNG dùng cho backend/logic không liên quan giao diện.
---

# Web Builder

A **standalone, minimalist CSS component library + design system** for building web UIs —
hand-written, token-based, **zero-build**, one drop-in stylesheet, every class `wb-*`-prefixed
so it composes with any stack and needs none. Its reason to exist: designing UI from scratch
every time is slow and burns tokens because it triggers round after round of "fix this colour /
this padding / this shape." This skill removes that loop — the visual decisions are **already
made and approved** and captured as tokens, ready-made components, and copy-paste snippets. Your
job is to **assemble approved parts**, so the user reviews *content and layout*, not aesthetics.
It's tuned first for **personal-finance UI** (money tables, budgets, receipts, tags — its flagship
use), but the primitives are general-purpose: use it for any minimalist web build.

## The one rule that saves tokens

**Do not invent styling.** Before writing any UI:

1. Read `references/components-catalog.md` to find the component that fits, then open its
   one-page demo `assets/pages/<id>.html` for the exact markup (a small, focused file).
2. Copy its snippet, swap in real data. Use `wb-*` classes and tokens — never hardcode
   colours, paddings, or radii.
3. If nothing fits, build the new piece **from existing tokens in the existing spirit**
   (see `references/design-principles.md`), add it to `web-builder.css`, create a demo page
   `assets/pages/<id>.html`, register it in `app.js` (the `NAV` list), and record it in the
   catalog. Then reuse it forever.

If you find yourself picking a hex value or a pixel padding by hand, stop — there is
almost certainly a token or class for it.

## What's in the box

| File | What it is | Read when |
|---|---|---|
| `assets/web-builder.css` | The library: design tokens + components (self-contained, no build). **The only file that ships to the app.** | You need class names / token names, or are adding a component |
| `assets/pages/<id>.html` | Living docs, **one small file per primitive** (buttons, tables, tags, input, select, charts, config, layout…). | You want the exact markup for one component — open just that file, not a monolith |
| `assets/index.html` + `app.js` + `docs.css` | The docs **shell** (reused by every page): tree sidebar, hash router that loads one page at a time, theme toggle, copy, and the dual light/dark preview. | You're changing the docs site itself (nav, routing, chrome) — not a component |
| `references/components-catalog.md` | "Building X → use Y, here's the snippet" lookup | **Start here** for any build task |
| `references/design-principles.md` | The colour ladder, neutral shadow rule, number/typography/font rules | Building something new or making an aesthetic call |
| `references/integration.md` | How the CSS + tokens + optional React wrappers plug into any app's stack (React/Vite/Tailwind/shadcn/next-themes as the worked example) | Wiring the library into a real app |
| `references/bootstrap-comparison.md` | Coverage vs Bootstrap 5.3 (what we have / skip / do differently), the popup set, the layout-foundation decision, and BOC structure | Deciding whether to add a component, or "do we have X?" |

## The colour ladder (summary — full version in design-principles.md)

Spend colour, don't sprinkle it. Lowest tier that does the job:

1. **white / black / grey** — the default for nearly everything.
2. **bright solid colour** — only for unmistakable status (paid = green, overdue / bad
   debt = red, due-soon = amber, info = blue).
3. **bright colour + low opacity (soft)** — the calm version of tier 2 (same meaning, dialled down).

Tiers 2–3 are colour-spend **levels, not per-component styles** — either can ride on any component (capsule,
tag, number, border, row tint, card, chart), not just capsules. Classification (a category/method tag) is
**not** status → keep it neutral grey. Only real status earns colour.

## Current scope

Coverage maps to the **eight intent-groups** in the docs sidebar (this is the map; the exhaustive
roster with every modifier + copy-paste markup lives in `components-catalog.md` — **that's the single
source of truth**, kept in sync per-component, so it never drifts here):

- **Nền tảng** — colour ladder, tokens, typography scale, fonts guidance (system stack by default, swap
  `--wb-font`), border & radius, the **grid/layout utilities** (`.wb-cluster`/`.wb-grid`/`.wb-stack`/`.wb-container`/`.wb-ratio`
  with full row/column **alignment** + `.wb-self--*` per-item + `.wb-grow` — they're the base every component composes on),
  **sticky** (`.wb-sticky` / `--bottom` — pin a bar/card to an edge on scroll), **scroll** (`.wb-scroll-y`/`-x` themed overflow regions + `.wb-scrollbars` — theme any scrollbar incl. the whole-page viewport), and a live **Config** playground that edits tokens and exports a `.md`.
- **Hành động** — buttons (incl. button-group, social-login with brand logos), dropdown / menu.
- **Nhập liệu** — text input (prefix/suffix + icon addons), select, textarea (themed scrollbar both axes + a custom round-capped resize handle via `.wb-textarea-wrap`; `--code` for no-wrap horizontal scroll), checkbox/radio, switch
  (incl. a **locked** state + an **I/O** on/off variant), range (single + **dual min–max** band), file + dropzone,
  **colour** — a preset **swatch palette** (`.wb-swatches`, pick from approved hues), a custom **colour picker** (`.wb-colorpicker` — SV area · hue · hex · presets; replaces the OS dialog); validation via the `.is-invalid` state.
- **Hiển thị dữ liệu** — card, tables (basic → transactions → striped/compact/bordered/sticky/debt),
  **filter bar** (search + multi-field dropdown + removable tag/status/amount-range tokens), list group,
  stat/KPI cards, capsules/badges (incl. `--tinted` category hue), tags, avatar, **media object**
  (`.wb-media` — a leading figure + title/text body: ranked rows, feature lists; pairs with card), **receipt**
  (hoá đơn — a torn-paper slip; **4 edge styles** scallop (default) / `--wave` / `--zigzag` / `--dashed`, plus `--bottom`/`--flat`, `__barcode`; bill · transfer · voucher templates).
- **Phản hồi** — alert, toast, modal/dialog, drawer/offcanvas (backdrop options on `.wb-overlay`: `--blur` /
  `--clear`, or `--pass` = **non-modal**, page below stays usable), progress (+ indeterminate/loading),
  skeleton, empty state, tooltip, **popover** (click-toggled card w/ arrow + × — richer than tooltip, not a menu).
- **Điều hướng** — navbar (+ a **theme sáng/tối toggle**), nav / menu, sidenav (app rail), tabs, **steps/stepper** (`.wb-steps` — numbered or `--dot`; vertical timeline + `--horizontal` wizard; `.is-todo`/`.is-active`/`.is-done` states), breadcrumb, pagination, accordion, **collapse** (one standalone show/hide region), divider.
- **Biểu đồ** — line/area, income-vs-expense bars, combo bar+line, horizontal ranked bars, donut / thin
  donut / progress ring, budget progress, sparkline + finance palette, mono/blue schemes with count-aware ramps.
- **Cấu trúc** — drag-and-drop **tree** (reorder + reparent) and a flat **sortable** list/grid/rows.
  (The grid/layout utilities moved up to **Nền tảng** — they're a foundation, not a structural component;
  a row/column is still a class, never an inline `align-items`.)

Three standing decisions shape the set:

1. **Dogfooded docs.** Every page is built from the library's own `wb-*` primitives (cluster / grid /
   stack / nav / sidenav / card…); `docs.css` holds only chrome the library has no equivalent for.
2. **Style here, behaviour in the app.** Interactive components run on a tiny vanilla toggle in the docs
   and map onto a behaviour engine in your app (Radix/shadcn + sonner + dnd-kit in the React example; see
   `integration.md`).
3. **Bootstrap-benchmarked, re-cut minimalist** (white-black-grey first) — incl. a minimal navbar / nav /
   sidenav for app shells; only heavy or branded pieces (carousel, scrollspy) are intentionally skipped.
   Layout stays a small flex/grid utility set — **not** a 12-column foundation — as a *minimalism* choice:
   the five utilities (cluster / stack / grid / container / ratio) cover real page layout without the
   vocabulary weight of a breakpoint grid, and they are **self-sufficient** (no Tailwind required — see
   `design-principles.md` §17). That small set still carries **full flex alignment** (justify + cross-axis
   align + `.wb-self--*` + `.wb-grow`); only the 12-col scaffold is skipped, never alignment.

**House conventions to keep:** icons come from an **icon font** — Material Symbols, `@import`ed in
`web-builder.css`; use `<span class="wb-ico">name</span>` (weight ~600 so they're crisp), **never
hand-drawn** — or an emoji when one fits; a tone is shown with an **outline + soft background** (like
a capsule) — **no left-accent bars** on components (a documented non-default variant on the Border page);
form validation is a **state**, `.is-invalid` (not `--invalid`); border width is one knob (`--wb-bw`);
lean on **dashed** borders for "empty / droppable / optional". On **dark**, shadows flip to a soft
**light** lift (a black shadow is invisible on a dark canvas) — build with `--wb-shadow-*` and it's
automatic. Scroll regions get a thin **theme-aware scrollbar + tail room** (`.wb-scroll-y`, and the
built-in table/menu) so the last item scrolls clear and the bar doesn't clash. **Disabled** and **locked**
are distinct states: *disabled* reads inert (dim neutral track, `not-allowed`); *locked* keeps the real
on/off value but puts a lock **beside** the control that **shakes** when a blocked change is attempted —
**never overlay** a lock on the control itself. A dismiss **×** (`.wb-close`) always sits **top-right**
of its container (alert / toast / modal / drawer), never vertically centred. Brand/provider logos (social
login) are the **one** allowed colour exception — the rest of the button stays neutral. Watch the
dark-mode `:where()` rule (design-principles §6) so tones don't grey out. When asked for a new component, build it in the same system and add it to the
library (new `wb-*` classes + a `pages/<id>.html` demo + an `app.js` `NAV` entry + a catalog entry).

## Working with the user

The user iterates visually and prefers to review in the browser. The docs are a small
client-side app (the router `fetch`es `pages/*.html`), so they **must be served over HTTP** —
opening `index.html` via `file://` will fail to load pages. Serve the assets folder:

```bash
cd web-builder/assets && python3 serve.py 8777   # open http://localhost:8777
```

`serve.py` is a thin wrapper over `http.server` that adds `Cache-Control: no-store`, so a **normal
reload shows edits** to `web-builder.css` / `docs.css` / `app.js` / `pages/*` — no hard-refresh needed
(the router also `fetch`es pages with `cache: "no-store"`). Plain `python3 -m http.server 8777` still
works, but it caches, so you'd have to **hard-refresh** (Cmd/Ctrl+Shift+R) after each edit.

Deep-link to a group with the hash, e.g. `http://localhost:8777/#/tables` or `#/tags`. Icons + the Config
font picker load from Google Fonts (Material Symbols + web fonts), so the docs want **internet**;
the **Config** panel (gear in the topbar) tweaks tokens live and exports a `.md`.

Default the docs preview to the look the user prefers judging first: **light mode,
white-black-grey**. Colour and dark mode are there, but neutral-first is the house style.
When the user gives feedback, change the **token or component once** so every screen
benefits — never patch a single page.

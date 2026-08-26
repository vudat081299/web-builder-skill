---
name: web-builder
description: >-
  Thư viện component CSS + design system tối giản (trắng-đen-xám, dark mode, zero-build, prefix
  wb-*) để build giao diện web ĐẸP và NHẤT QUÁN — ráp từ thành phần đã duyệt (class wb-* + design
  tokens) thay vì thiết kế lại từ đầu (tốn token, lệch phong cách). Kèm theo: chọn mức tổ chức cho
  chính project web đó — web nhỏ/một trang đi one-file fast path (một index.html, không kiến trúc
  thừa); web lớn/dài hạn/nhiều route mới dựng cấu trúc tối thiểu vừa đủ. Dùng khi: bắt đầu
  website/trang mới; ráp hoặc thiết kế UI đáng kể; đổi shell/layout/design-system; thêm screen-flow
  lớn; chọn lại cấu trúc file của một site; điều tra bug nghi thuộc thư viện này. Mạnh nhất cho
  finance UI và learning site, dùng tốt cho web bất kỳ (landing, portfolio, docs, dashboard, CRUD,
  content). KHÔNG dùng khi: chỉ sửa copy/nội dung, update data/lesson, fix bug nhỏ local, tái dùng
  component local, thiết kế kiến trúc backend/hệ thống, hay backend/logic không liên quan giao diện.
---

# Web Builder

**v0.6** — the same string the stylesheet carries as `var(--wb-version)`, so you can tell which build an
app is actually holding (the CSS is copied into projects, not installed; there is no package.json to read).
Newest first in `CHANGELOG.md`.

A **standalone, minimalist CSS component library + design system** for building web UIs —
hand-written, token-based, **zero-build**, one drop-in stylesheet, every class `wb-*`-prefixed
so it composes with any stack and needs none. Its reason to exist: designing UI from scratch
every time is slow and burns tokens because it triggers round after round of "fix this colour /
this padding / this shape." This skill removes that loop — the visual decisions are **already
made and approved** and captured as tokens, ready-made components, and copy-paste snippets. Your
job is to **assemble approved parts**, so the user reviews *content and layout*, not aesthetics.
It's tuned first for **personal-finance UI** (money tables, budgets, receipts, tags — its flagship
use), but the primitives are general-purpose: use it for any minimalist web build.

## Before you build: one file, or architecture?

Web Builder does two jobs. The first — **making the UI beautiful and consistent** — is everything below and
applies to **every** build. The second — **choosing how the project is organized** — is an *adaptive* capability
you reach for **only when the build is big enough to need it.** Most builds are small: **default to one file.**

**Level 0 — the one-file fast path (the default).** Create or keep a single `index.html` (markup +
`web-builder.css` via one `<link>` + a little inline JS) when **all** hold: one page; ≤ ~1,000 lines / ~100 KB
of hand-written code; ≤ 3 small behaviours; no backend / auth / database; no router / build / SSR; no
collection of independently-updated units (lessons, posts, records); no complex state; not maintained
feature-by-feature across many sessions. At Level 0 **do not** create `.agent/`, architecture docs, ADRs, a
handoff, or folders "for later" — that's friction, not future-proofing. Just ship semantic HTML, a beautiful
Web-Builder UI, responsive + accessible, and a quick render check. The line/KB numbers are a safe-fast-path
**heuristic, not a split law**: over them you *evaluate*, you don't auto-split (a cohesive 10,000-line file can
be right; see `references/large-static-sites.md`).

**More than that? Don't improvise a structure.** Run the complexity gate and synthesize the *smallest*
architecture that fits — **read `references/project-architecture.md`** (the Level 0/1/2 gate, constraint-based
synthesis, capability vocabulary, patterns, file-decomposition, evolution rules). Then load only what the task
needs: `references/site-profiles.md` (priors per site type) and `references/learning-sites.md` (the deep,
~60%-of-use profile); `references/large-static-sites.md` (a big or monolith file); `references/project-protocol.md`
(the short `AGENTS.md` contract a build leaves so a routine agent continues **without** this skill);
`references/problem-routing.md` (is a bug local or upstream?); `references/verification.md` (how to prove it
works). Architecture is **never mandatory ceremony** — never impose `.agent/` or a folder tree on a build that
doesn't need one.

**Invocation boundary.** Reach for Web Builder when: starting a new site/page; assembling or designing
significant UI; shaping or reshaping **how the web project's own files are organized**; adding a screen flow or
a large capability; adding UI with no local equivalent; changing the shell / layout / design system;
refactoring a monolithic site file; or investigating a bug that might be **upstream** in this library.
Routine work does **not** need it — copy/content edits, data/lesson updates, small local fixes, reusing a
local component, changes inside an existing boundary, adding a local test, or resuming from a handoff. It is also
**not** a system-architecture skill: backend/service/data-platform design belongs to whatever skill your
project uses for that. (Packaging and releasing Web Builder itself is upstream-repo work — see the repo's
`/wb-release`, not this skill.) When inside an existing project, read its `AGENTS.md` first, reuse local
solutions, and don't restructure just to match a Web Builder profile.

## The one rule that saves tokens

**Do not invent styling.** Before writing any UI:

1. Read `references/components-catalog.md` to find the component that fits, then open its
   one-page demo `assets/pages/<id>.html` for the exact markup (a small, focused file).
2. Copy its snippet, swap in real data. Use `wb-*` classes and tokens — never hardcode
   colours, paddings, or radii.
3. If nothing fits, build the new piece **from existing tokens in the existing spirit**
   (see `references/design-principles.md`), add it to `web-builder.css`, create a demo page
   `assets/pages/<id>.html`, register it in `app.js` (the `SECTIONS` model), and record it in the
   catalog. Then reuse it forever.

**Building a whole page, not just one part? START FROM A TEMPLATE — this is a rule, not a suggestion.**
`assets/templates/` ships seven finished screens, each a standalone HTML document built from these parts:

| Recipe | Template |
|---|---|
| Dashboard / home | `assets/templates/dashboard.html` |
| Records / transactions list | `assets/templates/list.html` |
| Add / edit form | `assets/templates/form.html` |
| Detail / record view | `assets/templates/detail.html` |
| Settings | `assets/templates/settings.html` |
| Auth / login (no shell) | `assets/templates/auth.html` |
| Landing / marketing (no shell) | `assets/templates/landing.html` |

Open the closest one, **replace the copy and the data, keep the frame**. Change text, numbers, icons, how
many rows or fields; do not change the `wb-shell` frame, the `wb-page-head` → `wb-section` → `wb-block`
nesting, or the spacing (it comes from tokens — if a gap feels wrong, set `--wb-section-gap` /
`--wb-block-gap`, never a `margin` on one element). Only when no template fits the *shape* of the screen do
you compose from the **Composing a page — recipes** section of `components-catalog.md` — and then fold the
result back as a new recipe **plus** a new template, so the next build reuses it.

Why the rule is hard: a table of parts cannot state the hundred small calls a finished page makes — which
heading level, where the breadcrumb goes, when a row is `--2` instead of `--auto`, how much colour is
enough. The templates already made them, the way the docs were tuned over many review rounds.

The frame and the spacing are **shipped parts, not advice**: `body.wb-app` (the baseline: border-box, font,
colours, line-height, links), `.wb-shell` + its slots, and the heading ladder (catalog § *App shell & page
scaffold*). No `min-height:100vh`, no hand-picked `margin-top`, no re-inventing a mobile rail. **A
hand-rolled shell or a one-off margin is the single biggest reason a build stops looking like this system.**

**Before you deliver a page, run `references/page-review.md`.** Nine gates, four of them measurable with a
console snippet the file gives you (invented classes · the colour ladder · horizontal overflow · the bar
wrapping). It is the other half of the template rule: the template makes the page start right, the review
checks it still ends right. Don't skip the mechanical four — an invented class renders as *nothing* and no
tool will tell you.

If you find yourself picking a hex value or a pixel padding by hand, stop — there is
almost certainly a token or class for it.

**Closing the loop.** If you're using this skill inside another app and you build a part in the same spirit
(neutral-first, tokenised, `wb-*`-prefixed), it isn't a one-off — capture it (the markup + which tokens it
uses) and contribute it **back upstream** to `web-builder-skill`, so the library keeps compounding instead of
each app re-deriving the same piece. New to the shipped set since you last looked? See `CHANGELOG.md`.

## What's in the box

| File | What it is | Read when |
|---|---|---|
| `assets/web-builder.css` | The library: design tokens + components (self-contained, no build). **The only file that ships to the app at runtime.** | You need class names / token names, or are adding a component |
| `assets/templates/<screen>.html` | **Seven finished screens** (dashboard · list · form · detail · settings · auth · landing), standalone HTML on the shipped scaffold. Ships with the skill; they are source you copy, so the runtime payload is still one CSS file. | **Building a whole screen — open the closest one first.** Not for looking up a single component |
| `assets/pages/<id>.html` | Living docs, **one small file per primitive** (buttons, tables, tags, input, select, charts, config, layout…). | You want the exact markup for one component — open just that file, not a monolith |
| `assets/index.html` + `app.js` + `docs.css` | The docs **shell** (reused by every page): tree sidebar, hash router that loads one page at a time, theme toggle, copy, and the dual light/dark preview. | You're changing the docs site itself (nav, routing, chrome) — not a component |
| `references/components-catalog.md` | "Building X → use Y, here's the snippet" lookup **+ a *Composing a page* recipe section** (app-shell skeleton + the recipe→template table) for whole screens | **Start here** for a single part; for a whole screen it points you at the template |
| `references/design-principles.md` | The colour ladder, neutral shadow rule, number/typography/font rules | Building something new or making an aesthetic call |
| `references/page-review.md` | The **nine-gate self-review** you run on a finished page — four of them measurable with a console snippet (invented classes · colour ladder · overflow · a wrapping bar), plus the specific smells this library invites | **Before you deliver any page.** The other end of the "start from a template" rule |
| `references/integration.md` | How the CSS + tokens + optional React wrappers plug into any app's stack (React/Vite/Tailwind/shadcn/next-themes as the worked example) | Wiring the library into a real app |
| `references/bootstrap-comparison.md` | Coverage vs Bootstrap 5.3 (what we have / skip / do differently), the popup set, the layout-foundation decision, and BOC structure | Deciding whether to add a component, or "do we have X?" |
| `references/docs-site.md` | How the docs **site** is built — SPA architecture (index.html shell + app.js `SECTIONS`/router + docs.css chrome), the page-grammar skeleton, the docs-chrome class inventory, and the Config/search/dual-preview/theme features | Rebuilding or extending the docs site itself (not a component). The docs **never ship**, but the skill stays self-sufficient to recreate them at the same quality |
| `references/project-architecture.md` | **Architecture knowledge** (hub) — the Level 0/1/2 complexity gate, constraint-based synthesis, capability vocabulary, patterns, file-decomposition, evolution rules; routes to `site-profiles` · `learning-sites` · `large-static-sites` · `project-protocol` · `problem-routing` · `verification` | Deciding how a **Level 1/2** project is organized — **skip for a one-file build** |

## The colour ladder (summary — full version in design-principles.md)

Spend colour, don't sprinkle it. Lowest tier that does the job:

1. **white / black / grey** — the default for nearly everything.
2. **bright solid colour** — only for unmistakable status (paid = green, overdue / bad
   debt = red, due-soon = amber, info = blue).
3. **bright colour + low opacity (soft)** — the calm version of tier 2 (same meaning, dialled down).

Tiers 2–3 are colour-spend **levels, not per-component styles** — either can ride on any component (capsule,
tag, number, border, row tint, card, chart), not just capsules. Classification (a category/method tag) is
**not** status → keep it neutral grey. Only real status earns colour.

**Single-colour parts pick from the neutral ladder.** A divider, progress track, muted icon, tick mark or
scroll thumb defaults to one of four tokens — `--wb-neutral-weak` / `--wb-neutral` / `--wb-neutral-strong` /
`--wb-neutral-ink` (xám *nhẹ / vừa / đậm / đen*, auto-flips in dark) — never a hand-picked grey; that's what
keeps one page from drawing three dividers in three greys. A part that *also* shows status (a progress bar
going red/amber/green) rides tier-2 colour on top. **Icon size** is likewise one scale: the `.wb-ico--xs…--xl`
steps (16/18/20/24/32, tokens `--wb-ico-*`), never ad-hoc `font-size`.

**A transparent control hovers to translucent ink** — `--wb-ink-hover`, never an opaque grey. A ghost/outline
button or a dismiss × shows whatever is behind it (card · canvas · tinted alert · toned chip), and no opaque
colour is right on all of them: `--wb-surface-2` *equals* `--wb-canvas`, so an opaque hover disappears on the
canvas. Opaque `--wb-surface-hover` is still right on a **known** surface (menu item, table row, calendar day).

## Current scope

Coverage maps to **eleven intent-groups** — foundation (**Foundation**, the docs' *Design* section) plus
the **ten component groups** of the *Components* section (this is the map; the exhaustive roster with every
modifier + copy-paste markup lives in `components-catalog.md` — **that's the single source of truth**, kept in
sync per-component, so it never drifts here):

- **Foundation** — the **app baseline `.wb-app`** (on `<body>`: border-box for every `wb-*` element, the font,
  canvas/ink colours, `line-height`, links that inherit instead of going browser-blue — `.wb-shell` implies it,
  a shell-less screen must say it or it falls through to the browser's serif default), the colour ladder,
  tokens, typography scale, fonts guidance (system stack by default, swap `--wb-font`), border & radius,
  **page templates** (`assets/templates/*.html` — seven finished screens; start any whole-screen build there),
  and a live **Config** playground that edits tokens and exports a `.md`.
- **Layout & utilities** — the **app shell & page scaffold** (`.wb-shell` + `__body`/`__side`/`__main` — the frame of a
  whole screen: sticky bar, a rail slot that sticks and folds to an off-canvas drawer + scrim below 900px via
  `.is-side-collapsed`/`.is-side-open` with `.wb-shell__side-toggle` = the ☰ that appears at exactly that fold width —
  the **scrolling lives on the slot's `.wb-sidenav` child**, never on the sticky slot, and a rail needing a pinned part
  above that nav says `.wb-shell__side--stack` + `.wb-scroll-y` on the one child that scrolls,
  and a content column `.wb-container--pad`; plus the heading rhythm
  `.wb-eyebrow` / `.wb-page-head` (`--lg` hero) / `.wb-section` / `.wb-block`, each styling whatever `h1…h6` sits inside
  it, all driven by the `--wb-text-*` scale + `--wb-section-gap`/`--wb-block-gap`/`--wb-measure` knobs — **start any new
  screen here**, it's what keeps a build from re-deriving its own frame and drifting), the **grid/layout utilities**
  (`.wb-cluster`/`.wb-grid`/`.wb-stack`/`.wb-container`/`.wb-ratio`
  with full row/column **alignment** + `.wb-self--*` per-item + `.wb-grow` — the base every component composes on),
  **sticky** (`.wb-sticky` / `--bottom` — pin a bar/card to an edge on scroll), **scroll** (`.wb-scroll-y`/`-x` overflow regions + tail room; the **themed scrollbar is a page-wide default declared once** in CSS section 27 — every scroller incl. the viewport gets it with **no class**, and `.wb-scrollbars--os` hands one subtree back to the OS bar), and **divider** (`.wb-divider` — neutral line styles solid/dotted/dashed/long-dash/fade + `--strong` ink, ray/label, horizontal + vertical; no status hues).
- **Actions** — buttons (incl. button-group, social-login with brand logos, a borderless icon-`×` close button; **shapes** `--icon` square · `--round` pill/circle · `--block`; a **reveal-on-hover icon button** = `--ghost --icon` [+`--round`] that shows a grey chip only on hover — toolbars, row actions), dropdown / menu (chevron caret that flips; an **expandable row** `.wb-menu__group` > `--expand` + `.wb-menu__sub` for a collapsible sub-list).
- **Inputs** — text input (prefix/suffix + icon addons; a **clickable affix button** `.wb-input-group__btn` for password show/hide, clear ×; **`--seamless`** = no outline / no addon dividers, melts into the page; **masked inputs** that format *while typing* via `data-mask` — date · time · datetime · card · daterange, no popup; **`.wb-input-tpl`** = a segmented date/time field whose ` / : – ` separators are real inked characters with left-aligned, grey-placeholder parts that auto-advance; tapping the field resumes focus at the first empty / last filled segment; within-date `/`·`:` stay tight, a between-cluster `–` takes `.wb-input-tpl__sep--gap` for a space each side), select, textarea (themed scrollbar both axes + a custom round-capped resize handle via `.wb-textarea-wrap`; `--code` for no-wrap horizontal scroll), **format toolbar** (`.wb-toolbar` — a horizontal rich-text/markdown bar Aa/H1/H2/bold/italic/underline/strike/highlight+colour/clear over a textarea; `--attached` fuses it on top), checkbox/radio (radio fills: default / `--ring` / `--solid`; both take `--locked`), switch
  (incl. a **locked** state + an **I/O** on/off variant), range (single + **dual min–max** band + tick-mark scale `.wb-range-ticks` — labels centre on the mark, or `--labels-left`/`--labels-right`), file + dropzone; validation via the `.is-invalid` state.
- **Pickers** — **calendar** (`.wb-calendar` — month grid; single date or `--range` date-range; selection = tier-1 neutral chip, today = neutral ring, range = soft band), **time picker** (`.wb-timepicker` — iOS-style scroll columns hour : minute, `--ampm` for 12-hour), and the **colour** pickers: a preset **swatch palette** (`.wb-swatches`, pick from approved hues) + a custom **colour picker** (`.wb-colorpicker` — SV · hue · hex · presets; replaces the OS dialog). All host inline or in `.wb-popover` for a trigger→popup (calendar/time pair with an `.wb-input-group` field you can **type into via `data-mask` OR pick from**, kept two-way in sync); behaviour (grid maths, drag, mask) is a tiny driver in docs, a headless lib in an app.
- **Data display** — card (`--dashed` / `--flat` / `--hover` / **`--pad`** = padding on the card itself for a
  one-part card with no `__head`/`__body`/`__foot`), tables (basic → transactions → striped/compact/bordered/sticky/debt; **column sort** via `wb-th-sort`+`aria-sort`; drag row-reorder via `--sortable`),
  **filter bar** (search + multi-field dropdown + removable tag/status/amount-range tokens), list group,
  stat/KPI cards, capsules/badges (incl. `--tinted` category hue + `--dashed` optional/add-new), tags, avatar, **media object**
  (`.wb-media` — a leading figure + title/text body: ranked rows, feature lists; pairs with card), **receipt**
  (hoá đơn — a torn-paper slip; **3 edge styles** scallop (default) / `--wave` / `--dashed`, plus `--bottom`/`--flat`/`--ticket` (vé xé — dashed tear + real half-circle side cuts), `__barcode`; geometry knobs `--wb-receipt-d`/`--wb-receipt-gap`; bill · transfer · voucher templates), and **charts** — line/area,
  income-vs-expense bars, combo bar+line, horizontal ranked bars, donut / thin donut / progress ring, budget progress, sparkline + finance palette, mono/blue schemes with count-aware ramps.
- **Feedback** — alert/banner (tone outline, or `--plain` = no outline/flat), toast, progress (+ indeterminate/loading, status tones + `--info`), skeleton, empty state.
- **Overlays** — modal/dialog, drawer/offcanvas (backdrop options on `.wb-overlay`: `--blur` /
  `--clear`, or `--pass` = **non-modal**, page below stays usable), tooltip, **popover** (click-toggled card w/ arrow + × — richer than tooltip, not a menu).
- **Navigation** — navbar (+ a **theme sáng/tối toggle**; height = `--wb-navbar-h`; `--glass` = translucent + blurred for a sticky bar over scrolling content; **responsive** — a container-query collapse where `.wb-nav.wb-navbar__menu` tucks into a `.wb-navbar__toggle` ☰ menu on a narrow bar, no overlap; the threshold is 640 for an app bar, **`--collapse-lg`** = 900 for a public bar carrying a full menu + text CTAs; **`__actions` is icon-only** — it never collapses, so a text CTA goes at the end of `__menu` after a nested `__spacer`, or it scrolls the page sideways on a phone), nav / menu, sidenav (app rail — inside a shell it goes in the `.wb-shell__side` slot, which owns the surface + sticky + mobile drawer), tabs, **steps/stepper** (`.wb-steps` — numbered or `--dot`; vertical timeline + `--horizontal` wizard; `.is-todo`/`.is-active`/`.is-done` states + per-item `--dashed` tentative/optional step), breadcrumb, pagination, **pager** (`.wb-pager` — prev/next **page** links for the foot of a page, `[`/`]` keyboard shortcuts via a tiny guarded driver; ≠ pagination which pages through rows) + **`.wb-kbd`** keycap chip, and **footer** (`.wb-footer` — site footer: brand + link columns + copyright/social bar; `--slim` one-liner; greyscale).
- **Disclosure** — accordion (`<details>` FAQ) and **collapse** (one standalone show/hide region).
- **Structure** — drag-and-drop **tree** (reorder + reparent), a flat **sortable** list/grid/rows (grip top-left in grid; `--no-grip` = drag the whole card), and a **slot grid** (`.wb-slotgrid` — fixed cells `--1`…`--6`; drop an item into any slot, empty gaps are kept; drop on an occupied slot **swaps**).

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
automatic. **Theme default** (asked for dark/light and nothing more): **first visit follows the OS** — a
pre-paint boot script sets `.dark` from `prefers-color-scheme` — and the toggle is **2-state light⇄dark**
(persisted in `localStorage["wb-theme"]`; **no "system" button state**); copy a `templates/*.html`, which ships
this exact wiring (design-principles §6). The thin **theme-aware scrollbar is page-wide by default** — CSS section 27 declares it once on `:root` + `*`,
so the viewport bar, the built-in table/menu areas, a hand-written `overflow:auto` div and a third-party widget
all follow the theme with **no class to add** (`.wb-scrollbars--os` opts a subtree back to the OS bar); pair it
with **tail room** (`.wb-scroll-y`/`-x`, `--pad`) so the last item scrolls clear and the bar doesn't clash. **Disabled** and **locked**
are distinct states: *disabled* reads inert (dim neutral track, `not-allowed`); *locked* keeps the real
on/off value but puts a lock **beside** the control that **shakes** when a blocked change is attempted —
**never overlay** a lock on the control itself. A dismiss **×** always sits **top-right**
of its container (alert / toast / modal / drawer), never vertically centred, and is **one** glyph across the
system — the icon-font `close` (`.wb-close` for panels, `.wb-tag__x` / `.wb-filter-token__x` for chips) —
**never** a literal `×`/`✕` character. Likewise a **✓** is the icon-font `check` everywhere (stepper marker,
and the checkbox tick traces the same shape) — not a literal `✓`. Brand/provider logos (social
login) are the **one** allowed colour exception — the rest of the button stays neutral. Watch the
dark-mode `:where()` rule (design-principles §6) so tones don't grey out. When asked for a new component, build it in the same system and add it to the
library (new `wb-*` classes + a `pages/<id>.html` demo + an `app.js` `SECTIONS` entry + a catalog entry).

**Three more conventions round out the taste** (full text in design-principles §19–21): write **Vietnamese-first
copy** (labels/statuses are data — swap freely; keep one number/date locale per screen); hold an **a11y
baseline** (icon-only controls get `aria-label`, invalid fields set `aria-invalid` beside `.is-invalid`, build
on native inputs so keyboard + roles come free); and let everything **collapse gracefully on mobile** (grids
reflow, `.wb-cluster` / breadcrumb wrap, the navbar folds to ☰ via a container query — no breakpoint bookkeeping).

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

# Integrating Web Builder into an app

Web Builder is **standalone and zero-build**: one drop-in stylesheet (`web-builder.css`), every class
`wb-`-prefixed, all theming through `--wb-*` CSS variables. It needs no framework, no build step, and no
other CSS library — drop it into plain HTML and it works. This guide shows how it plugs into a **real app**;
the worked example is a common stack (**React 19 + Vite + TypeScript + Tailwind + shadcn/ui (Radix) +
next-themes**), but every step degrades gracefully to "you don't have that tool."

**It's a styling layer by design.** Web Builder owns the *look* (tables, capsules, cards, numbers, forms,
charts…). For interactive behaviour + accessibility — focus-trapping dialogs, keyboard menus, toasts — you
pair it with a **behaviour engine** (Radix/shadcn in the example; native elements or your framework's
equivalents work just as well). That split is a deliberate **minimalism** choice — ship zero JS, stay
drop-in — **not** a dependency: static/display components need nothing but the classes.

Nothing collides: every class is `wb-`-prefixed and every token `--wb-`-prefixed.

---

## Step 1 — Add the stylesheet (the only required step)

**Plain HTML** — just link it:

```html
<link rel="stylesheet" href="web-builder.css" />
```

**Bundled app** (Vite / webpack / …) — import it. If you use Tailwind, import Web Builder **after** it so
its component classes win over Tailwind's utility resets:

```ts
// src/main.tsx
import "./index.css";              // Tailwind base/components/utilities (only if you use Tailwind)
import "./styles/web-builder.css"; // Web Builder tokens + components
```

That's enough to use every `wb-*` class from the catalog anywhere.

## Step 2 — Dark mode

Web Builder themes entirely off a `.dark` class on a root element — so toggle that class however you like:
`next-themes` (`attribute="class"`), your framework's theme store, or a one-liner. With next-themes the
app's existing switch drives the library automatically — nothing to wire:

```tsx
<ThemeProvider attribute="class" defaultTheme="system" enableSystem>
```

No framework? `document.documentElement.classList.toggle("dark")` is the whole toggle.

## Icons — the library expects an icon font

`web-builder.css` `@import`s **Material Symbols Rounded** from Google Fonts, so `.wb-ico`
(`<span class="wb-ico">expand_more</span>`) and the few `::before` icons (accordion caret, tree
toggle, close ×) work out of the box **online**. Two ways to handle it:

- **Keep Material Symbols** (simplest) — the `@import` already pulls it; nothing to wire. To avoid a
  render-blocking CDN import, self-host the font (or move it to a `<link>` in your HTML) and drop
  the `@import`.
- **Use your own set** (e.g. `lucide-react`) — render your icons for inline cases and point
  `--wb-icon-font` at your set. Caveat: the handful of `::before` codepoint icons are
  Material-specific, so either keep Material Symbols just for those or override those few spots
  (accordion caret, tree toggle, close ×, `.wb-select-wrap` chevron). Simplest is to keep one font.

Icon size/weight are tunable via `--wb-ico-size` / `--wb-ico-weight` (default 600 = crisp).

## Step 3 (optional) — expose tokens to Tailwind

If you use Tailwind and want utilities that read the Web Builder palette (e.g. `text-success`), map the
tokens in `tailwind.config.js`. Optional — the `wb-*` classes don't need it.

```js
// tailwind.config.js → theme.extend.colors
colors: {
  success: "var(--wb-success)",
  danger:  "var(--wb-danger)",
  warning: "var(--wb-warning)",
  info:    "var(--wb-info)",
}
```

---

## React wrappers (optional — if you're on React with CVA + `cn`)

Plain HTML from the catalog works directly in JSX (`class` → `className`). In a shadcn-style project you
already have `class-variance-authority` + `cn`, so thin wrappers are ergonomic. These only pick `wb-*`
classes — no styling logic of their own.

```tsx
// src/components/ui/capsule.tsx
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "@/lib/utils"; // clsx + tailwind-merge

const capsule = cva("wb-cap", {
  variants: {
    tone: { neutral: "", success: "wb-cap--success", danger: "wb-cap--danger",
            warning: "wb-cap--warning", info: "wb-cap--info" },
    fill: { soft: "", solid: "wb-cap--solid", outline: "wb-cap--outline",
            elevated: "wb-cap--elevated" },
    size: { md: "", sm: "wb-cap--sm", lg: "wb-cap--lg" },
  },
  defaultVariants: { tone: "neutral", fill: "soft", size: "md" },
});

type CapsuleProps = React.HTMLAttributes<HTMLSpanElement> &
  VariantProps<typeof capsule> & { dot?: boolean };

export function Capsule({ tone, fill, size, dot, className, children, ...props }: CapsuleProps) {
  return (
    <span className={cn(capsule({ tone, fill, size }), className)} {...props}>
      {dot && <span className="wb-cap__dot" />}
      {children}
    </span>
  );
}
```

```tsx
// usage
<Capsule tone="success" dot>Đã trả</Capsule>
<Capsule tone="danger" fill="solid">Quá hạn</Capsule>
<Capsule>Ăn uống</Capsule>
```

Tables are usually clearer as plain JSX with the `wb-table` classes (map your data
with `.map`). A wrapper only pays off if you want a data-driven `columns`/`rows` API —
defer that until the visual language is locked.

---

## Which components need a behaviour primitive

Web Builder styles everything, but the interactive parts need an accessible engine in the app.
Keep the `wb-*` classes for the look and wire behaviour to (Radix/shadcn shown as the example engine —
substitute your framework's equivalent, or a native element):

| Web Builder look | Drive with (behaviour engine) |
|---|---|
| `wb-dropdown` / `wb-menu` | Radix **DropdownMenu** |
| `wb-overlay` / `wb-modal` | Radix **Dialog** (focus-trap + portal) |
| `wb-drawer` (+ `wb-overlay`) | Radix **Dialog** — or **vaul** for a draggable side/bottom sheet; keep the classes |
| `wb-tabs` / `wb-tab` | Radix **Tabs** |
| `wb-tooltip` | Radix **Tooltip** (smart positioning + delay) |
| `wb-toast` / `wb-toaster` | **sonner** |
| `wb-accordion` (native `<details>`) | native — or Radix **Accordion** if you need controlled state |
| `wb-tree` (drag to reorder / reparent) | **dnd-kit** (`@dnd-kit/core` + sortable) for the drag; keep the classes |
| `wb-sortable` (flat list/grid reorder) + `wb-table--sortable` (row reorder) | **dnd-kit** (`@dnd-kit/sortable`); keep the classes + the dashed `__ph` / `wb-row-ph` look. `--no-grip` = the whole card is the drag handle (no `wb-grip` node) |
| `wb-slotgrid` (fixed cells; place items in any slot, keep empty gaps) | **dnd-kit** with `rectSwappingStrategy` (drop on an occupied slot swaps); keep the `wb-slotgrid*` classes. Empty cells are real reservable slots — don't let the layout reflow and close gaps |
| `wb-select` in `wb-select-wrap` (chevron = a `.wb-ico`) | native — or Radix **Select** for custom option rendering |
| `wb-range` (slider) | native — or Radix **Slider** for keyboard + range (two thumbs); keep the class |
| `wb-switch--locked` (locked toggle) | native + your **plan / permission** gate for the real logic; keep the class for the beside-lock + shake affordance (a tiny click handler cancels the flip — see `app.js`) |
| social-login buttons (Apple / Google) | plain `wb-btn` + brand `<svg>`; wire the click to your **OAuth** provider (next-auth / Supabase Auth). Logo colour is the one allowed exception |
| `wb-file` / `wb-dropzone` | native `<input type=file>` — add drag events or **react-dropzone** for the dropzone; keep the classes |
| `wb-swatches` / `wb-swatch` (preset colour picker — single-select) | native radios, **or** a trivial click handler that moves `.is-selected` (one chip at a time), like a segmented `wb-btn-group`; no library. Set each chip's hue via `--wb-swatch-color`. Pair with `wb-colorpicker` (the custom panel) for a free colour |
| `wb-colorpicker` (custom SV + hue + hex panel) | a headless colour engine — **react-colorful** (`HexColorPicker`) or your own pointer handlers driving HSV↔hex; keep the `wb-colorpicker__*` classes for the look and move `__thumb` via `left`/`top`, set the `__area` base with `--wb-cp-hue`. Host in `wb-popover` for a trigger→popup. The docs ship a tiny vanilla driver (`initColorPicker` in `app.js`) as the reference — don't port it verbatim into a real app |
| `wb-calendar` (month grid — single date or `--range`) | a headless date engine — **react-day-picker** — or your own month maths; keep the `wb-calendar__*` classes + state classes (`.is-selected` / `.is-today` / `.is-in-range` / `.is-range-start`\|`end`). Host inline or in `wb-popover` with a `wb-input-group` trigger field that is **type-or-pick** (`data-mask="date"` on the `[data-picker-out]` input formats typing; field↔picker two-way). The docs ship a small vanilla driver (`initCalendar` + `syncFieldToPicker`, emits a bubbling `wb-cal-input`) as the reference — don't port it verbatim |
| `wb-timepicker` (scroll columns hour : minute, `--ampm`) | your own click/scroll handler (docs ship `initTimePicker`, emits `wb-time-input`) or a headless time lib; keep the `__col` (+ `.wb-scroll-y`) / `__opt` / `.is-selected` look. The trigger field is **type-or-pick** too (`data-mask="time"` → `HH:MM`). Pair a `wb-calendar` beside it for a **datetime** picker |
| masked `wb-input` (`data-mask="date\|time\|datetime\|card\|daterange"`) | a mask lib — **imask** or **cleave.js** — for caret-safe mid-string formatting; the docs ship a tiny append-only `initMask` as the reference. A password `wb-input-group__btn` reveal is a one-line `type` flip (`initReveal`) |
| `.wb-ico` (icons — Material Symbols font) | keep the font, **or** set `--wb-icon-font` to your own set / render `lucide-react` (see Icons note) |
| `.wb-grid` / `.wb-cluster` / `.wb-stack` / `.wb-container` / `.wb-ratio` (layout) | use as-is (self-sufficient) — or swap for Tailwind `flex`/`grid`/`aspect-*` if you already run Tailwind |
| charts (`wb-chart*`, `wb-bars`, combo, donut, `wb-spark`) | **Recharts**, fed the `--wb-chart-*` tokens (combo bar+line → `ComposedChart`); for a grey/one-hue chart put `.wb-chart-scheme--mono`/`--blue` + `.wb-chart-ramp--N` (N = series count) on the wrapper so Recharts reads an evenly-spread ramp; keep `wb-chart__tip` for the tooltip look. **Horizontal ranked bars** need no lib — they're just `.wb-progress` rows |
| `wb-navbar` / `wb-nav` / `wb-sidenav` (app-shell navigation) | plain markup + classes; drive `.is-active` from your **router** (React Router `NavLink`), and wire the mobile menu/collapse toggle in app JS |
| card, alert, stat, table, **list group**, **button group**, capsule, tag, avatar, **receipt** (hoá đơn), progress, breadcrumb, pagination, skeleton, empty, divider, buttons, inputs (incl. the native **colour** input), tabs | no JS engine — plain markup + classes |

Rule of thumb: if it opens/closes, traps focus, or needs keyboard nav → **the behaviour engine owns
behaviour, Web Builder owns pixels**. Static/display components are just classes. The docs site uses a tiny
vanilla toggle for demos only — don't port that toggle into a real app.

## What to change in your repo (your call — nothing is destructive)

**Do:**
- ✅ Add `web-builder.css` + the import (Step 1). This is the whole integration.
- ✅ (Optional) add `capsule.tsx` above and use it for all status/category tags.

**Don't remove:**
- ❌ Keep your behaviour libs (shadcn/Radix + `sonner` + `vaul` + `cmdk` in the example) — they provide
  behaviour Web Builder intentionally does not (focus trapping, portals, a11y). They are **partners**.
- ❌ Keep your chart runtime (Recharts in the example). Web Builder ships a **charts look** (palette tokens
  + SVG/CSS demos); the runtime engine stays — style it with the `--wb-chart-*` tokens so it matches.

**Watch for overlap:**
- If your app already has a component-library `<Table>` (e.g. shadcn), pick one source of truth for data
  tables. Recommended: use the `wb-table` classes for the look (tuned for money data — tabular numbers,
  totals, row states). You can even apply `wb-table` classes to an existing `<table>` to keep its structure
  but adopt this styling.

The whole integration, end to end: add the stylesheet + import, optionally add `capsule.tsx`, and convert
one table as a reference. Nothing else is required, and nothing is destructive.

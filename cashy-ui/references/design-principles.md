# Cashy UI — Design Principles

These are the rules that keep every screen looking like one product. Follow them
whenever you build or extend a component. They exist so the user does **not** have
to re-review basic aesthetic decisions on every page — the decisions are made here.

---

## 1. The colour ladder (most important rule)

Colour is spent, not sprinkled. Reach for the lowest tier that does the job.

| Tier | Palette | Use for |
|------|---------|---------|
| **1 — default** | white / black / grey | Almost everything: backgrounds, text, borders, most capsules, most numbers. |
| **2 — meaningful, solid** | bright solid colour | Only when a status must be unmistakable: paid = green, overdue / bad debt = red, due-soon = amber, info/processing = blue. |
| **3 — meaningful, soft** | bright colour + low alpha | The quiet version of tier 2 — soft tinted background + same-hue text. Preferred over tier 2 when the signal should be present but calm (default for status capsules, subtle row tints). |

**Decision rule:** if a colour is not carrying meaning, it should not be there. A
category tag ("Ăn uống", "Nhà ở") is *classification, not status* → keep it neutral
grey (tier 1). A payment state ("Đã trả", "Quá hạn") *is* status → tier 2/3 colour.
The same holds for a `#`-tag (`.cash-tag`): neutral by default; give it a hue only when
the category genuinely owns one, set once via `--cash-tag-color` so both themes stay right.

Do not colour every expense red or every income green by reflex. In a transaction
list, expenses stay neutral dark (`.cash-num--strong`); reserve green (`.cash-num--pos`)
for genuine inflows and red (`.cash-num--neg`) for genuine problems (over budget, loss).

## 2. The neutral shadow/contrast rule

The user's signature look for neutral elements:

- **Light background:** a white/light element (e.g. `.cash-cap--elevated`, `.cash-card`)
  sits on the surface with a **soft grey shadow** (dark ink at low alpha), a **hairline
  grey border**, and **near-black / dark-grey text**. Never pure `#000` — use `--cash-gray-900`.
- **Dark background:** invert it — dark surface, a subtle lighter border, light-grey/near-white
  text. And the shadow flips **colour**: a black shadow is invisible on a dark canvas (shadow ==
  background), so `--cash-shadow-sm|md` become a **soft light lift** — white/grey at low alpha,
  never black-on-black. The hairline border still draws the hard edge; the light shadow supplies
  the gentle elevation (turn it up via the Config panel's "Đổ bóng component" if a surface needs more).

**Rule:** a shadow's colour must *contrast* with the surface behind it — dark ink on light, light
on dark — never the same tone as the background. Both directions are already wired through the
tokens, so if you build with the tokens you get this free in light and dark. Never hardcode a hex
where a token exists.

## 3. Numbers are financial data — treat them well

- Right-align every numeric/money column: add `cash-num` to the `<th>` and `<td>`.
- `cash-num` sets `tabular-nums` so digits line up column-to-column. Keep it.
- Emphasis without colour: `.cash-num--strong` (weight only). With meaning:
  `.cash-num--pos` (green inflow), `.cash-num--neg` (red problem).
- Use the locale format the app uses (`1.234.567 ₫`), and a non-breaking space before `₫`.

## 4. Typography & density

- One type family (`--cash-font`, the system stack). Don't introduce new fonts casually.
- Hierarchy is weight + colour, not size explosions: strong = `--cash-fg` @ 600–650,
  secondary = `--cash-fg-muted`, tertiary/labels = `--cash-fg-subtle`.
- Table headers are small, uppercase, letter-spaced, muted — quiet scaffolding that
  lets the data be the loudest thing on screen.
- Prefer `--compact` tables for data-dense finance views; default density for hero lists.
- The **type scale** and **font** choices have their own doc pages (`pages/typography.html`,
  `pages/fonts.html`). Default is the system stack; to adopt a finance-friendly typeface
  (Inter is the recommended default — also Plus Jakarta Sans / IBM Plex Sans / Manrope),
  load it and swap the single `--cash-font` token and every component follows. Keep
  `tabular-nums` on numeric columns (`.cash-num` already sets it).

## 5. Elevation & shape

- Radii come from tokens: `--cash-radius-sm|radius|radius-lg`, and `--cash-radius-pill`
  for capsules. Capsules are pills by default — that's the "capsule" the user asked for.
- Two shadow levels only: `--cash-shadow-sm` (resting cards/tables) and
  `--cash-shadow-md` (raised/floating — menus, popovers later). Don't invent more.

## 6. Theming rules

- Light is the default (`:root`). Dark is the `.dark` class on `<html>` — this is
  exactly what cashy's `next-themes` toggles, so the library and the app agree.
- Every colour must come from a token so both themes stay correct. If you need a new
  colour, add a token in **both** `:root` and `.dark`, then use the token.
- **Don't let a dark base rule out-rank variant colours.** `.dark .cash-cap { color: … }`
  (specificity 0-2-0) beats a variant like `.cash-cap--success { color: … }` (0-1-0) and
  silently greys it out in dark — the same trap hit buttons and tags. Wrap the base class in
  `:where()`: `.dark :where(.cash-cap) { … }` stays at 0-1-0 so the tone/variant rules win.
  Applied to `.cash-btn`, `.cash-cap`, `.cash-tag`, `.cash-bar`, `.cash-progress__bar`; do the same
  for any future component whose dark base sets `color`/`background` while variants also set them.
  (Symptom of the trap: a tone renders grey/near-white in dark mode — e.g. income/expense bars or a
  success/warning/danger progress bar losing its colour.)

## 7. When you need something the library doesn't have yet

1. First check `components-catalog.md` — it may already exist.
2. If not, build it **from the existing tokens and in the existing spirit** (neutral
   first, colour only for meaning). Add it to `cashy-ui.css` with the `cash-` prefix
   and a matching demo + snippet in `index.html`, then note it in the catalog.
3. Keep the change small and composable (modifier classes over one-off components),
   the way the tables use `--striped`, `--compact`, `--bordered`.

The goal is always: the next page should be **assembled from approved parts**, so the
user reviews *content and layout*, not colours and paddings, ever again.

## 8. Interactive components: style here, behaviour in the app

Cashy UI owns the *look* of interactive parts (dropdown, modal/dialog, tabs, toast,
tooltip). In the docs they run on a tiny vanilla toggle purely to demo. In the cashy app,
drive them with the accessible primitive — Radix/shadcn **Dialog, DropdownMenu, Tabs,
Tooltip**, and **sonner** for toasts — and keep the `cash-*` classes for styling. Never
hand-roll focus traps, portals, or keyboard navigation. **Accordion** is the exception: it's
built on native `<details>`, so it needs no JS anywhere. See `cashy-integration.md` for the
component → primitive mapping.

## 9. Borders: outline + soft, not left-accent bars

On this site a tone is expressed with a **full outline in the tone colour + a soft
same-hue background** — the capsule idiom — applied consistently to alert, toast, and note.
**Do not use left-accent bars** (`border-left: 3px …` or `box-shadow: inset 3px 0 …`) on
components; they were removed in favour of the outline idiom. The left-accent pattern is
**documented as a non-default variant** on the Border page — a thin tone marker that suits
feed / notification lists or quotes — available with intent, but never the default here. Border widths come from
`--cash-border` (hairline) / `--cash-border-strong`; radii from the `--cash-radius-*` tokens
(or `0` for the deliberately sharp boxed look). Use **dashed** borders as an affordance —
"empty / droppable / optional / add-new" (`.cash-card--dashed`, `.cash-divider--dashed`, the
sortable `.cash-sortable__ph`); dashed reads as "not final", which helps users parse the UI fast.

## 10. Icons come from an icon font — do not hand-draw them

Use a real **icon font** (Material Symbols Rounded, `@import`ed at the top of `cashy-ui.css`) —
never CSS-drawn shapes or hand-authored SVG. Inline with `<span class="cash-ico">name</span>` (the
name is a ligature: `expand_more`, `close`, `drag_indicator`, `search`, …); a few components inject
theirs via a `::before` codepoint and stay empty in markup (accordion caret, tree toggle, close ×),
and a `<select>` gets its chevron from a `.cash-ico` inside `.cash-select-wrap`. Keep icons a touch
heavy so they never look hair-thin — `--cash-ico-weight` defaults to 600, size is `--cash-ico-size`;
both are single knobs the Config panel tunes, and `--cash-icon-font` can be swapped to another set
(e.g. lucide) in the app. When an icon is genuinely pictographic (folder, receipt, category), an
**emoji** (📁 🧾 🍜) is still fine — zero dependencies. The docs are online-first, so a CDN icon font
is acceptable; keep it to **one** font and don't make pages heavy. (History: an earlier pass drew
icons in CSS to avoid thin glyphs — that was reverted; a proper icon font at weight 600 is crisper
and simpler.)

## 11. Naming: `cash-block__element--modifier` (BEM-ish) + `.is-*` for state

Structure classes follow **block / element / modifier**: `.cash-input-group` (block), `.cash-input-group__addon`
(element), `.cash-btn--outline` (a *variant* modifier). **Runtime state** — anything toggled while
the app runs, *including form validation* — uses the `.is-*` prefix: `.is-active`, `.is-open`,
`.is-collapsed`, `.is-dragging`, and **`.is-invalid`** on a control
(`<input class="cash-input is-invalid" aria-invalid="true">`). Validation *is* a state, so it's
`.is-invalid`, not a `--invalid` modifier — that keeps the "variant vs state" line clean and reads
identically on every control (input / select / textarea). An invalid field shows a **red border that
stays red on focus** (a red ring, not the neutral one) — so a bad field still reads as wrong while you
type in it. Keep to these two patterns; don't add a third. (History: the CSS briefly only matched
`.cash-input--invalid`, so `.is-invalid` silently did nothing — the border went neutral/black on
focus; fixed to key off `.is-invalid` to match this rule.)

## 12. Chart colour

Charts get their own palette so a visual reads like the rest of cashy: **income = green,
expense = red** — but the chart tokens `--cash-chart-income` / `--cash-chart-expense` are a
**brighter ~*-500** (`#22c55e` / `#ef4444`), *not* the deeper semantic `--cash-success/-danger`,
because a whole bar filled with the -600 shade reads muddy/heavy. Plus a calm categorical set
`--cash-chart-1…8` for slices/series (a harmonious ~*-500 set) — all brighter in dark mode. Grid/axis use
`--cash-chart-grid` / `--cash-chart-axis`. Don't hand-pick chart hex values; use these tokens (and
feed the same ones to Recharts in the app) so every chart shares one key. When multi-colour is too
busy, wrap a chart in `.cash-chart-scheme--mono` (grey) or `--blue` (one-hue) — each series is mixed
from a single ink toward the canvas. **Spread the intensity by count:** add `.cash-chart-ramp--N`
(N = number of series) so they fan out evenly from 100% → 25% strength and no two steps look alike —
a fixed grey-900…-200 set clumps at the dark end and reads the same; without a count class an even
up-to-8 spread is used. Both invert light↔dark. Give donut slices a ~1-unit gap over a
surface-coloured track so segments read crisply — and for the **thin rounded** donut
(`.cash-arc--round`), widen the gaps (~5 path-units) so the pill-shaped caps actually show; too tight
and it just reads as a plain thin ring. A one-value **progress ring** follows the progress-bar tones
(neutral/`chart-1` &lt; ~80% · warning ~80–99% · danger ≥100%) — don't paint a 68% ring amber.

Chart *types* are plain SVG/CSS — reuse a primitive before inventing one: line/area, grouped bars,
**combo** (draw `<rect>` bars first, then overlay `.cash-series-line` + points), **horizontal ranked**
bars (just `.cash-progress` rows inside a `.cash-stack`, tinted per category), donut / thin-rounded
donut / progress ring, sparkline.

## 13. Scroll areas — themed bar + tail room

Any region that scrolls follows two habits (both baked into `.cash-scroll-y`):

1. **Themed scrollbar** — a thin bar with a **transparent track** and a neutral-border thumb, so it
   follows the theme instead of showing a bright OS bar that clashes on a dark canvas or reads as a
   second divider. (The built-in scroll areas — table body, dropdown menu — already carry it.)
2. **Breathing room past the last item** — `scroll-padding` + a bottom pad so the final rows scroll
   clear of the edge and are easy to read and to tap/select, instead of being pinned to the frame.

Scale the tail to the case: a short menu needs little, a long category list or sidebar wants more
(`.cash-scroll-y--pad`). Don't leave a long list flush against its container's bottom edge.

## 14. Disabled vs locked are two different states

Both are "you can't change this now", but they say different things and look different:

- **Disabled** = *not applicable here.* The control reads inert: a dim neutral track (never the
  on/off colour), `cursor: not-allowed`. It doesn't claim to hold a meaningful value.
- **Locked** (`--locked`) = *has a real value you're not allowed to change* (gated by plan, role, a
  prerequisite). Keep showing the true on/off state, and put a small lock **beside** the control (low
  opacity, brighter on hover). When the user tries to change it, the lock snaps to amber and **shakes**
  for ~0.4s, then settles — feedback exactly when they act, no permanent "LOCKED" clutter.

**Never overlay a lock on the control itself** (e.g. on a switch thumb) — it's cramped and ugly at
16–20px; the earlier thumb-glyph approach was dropped for this. Keep the lock a sibling so layout can
place it left or right. In the app, real form/permission logic does the gating; the class only styles
the look + the deny feedback.

## 15. A dismiss × sits top-right

Every close/dismiss control (`.cash-close`) belongs in the **top-right** corner of its container —
alert, toast, modal, drawer. It's `align-self: flex-start` (top) and pushed right (the body flexes to
fill, or `margin-left:auto`). Don't let it drift to the vertical middle of the row: users reach for
the top-right corner, and a centred × next to wrapping text reads as accidental.

## 16. The docs eat their own dog food

The docs site is built **from the primitives it documents.** Demo markup should use `.cash-stack` /
`.cash-cluster` / `.cash-grid` / `.cash-container` for layout rather than one-off
`style="display:flex…"`, and reuse real components (a "chart" that's really `.cash-progress` rows, a
row header that's `.cash-cluster--between`). If a demo needs a layout the utilities can't express,
that's a signal the utility set has a gap — add the utility, don't hand-roll inline styles.

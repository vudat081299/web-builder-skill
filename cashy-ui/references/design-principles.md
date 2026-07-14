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

Do not colour every expense red or every income green by reflex. In a transaction
list, expenses stay neutral dark (`.cash-num--strong`); reserve green (`.cash-num--pos`)
for genuine inflows and red (`.cash-num--neg`) for genuine problems (over budget, loss).

## 2. The neutral shadow/contrast rule

The user's signature look for neutral elements:

- **Light background:** a white/light element (e.g. `.cash-cap--elevated`, `.cash-card`)
  sits on the surface with a **soft grey shadow**, a **hairline grey border**, and
  **near-black / dark-grey text**. Never pure `#000` — use `--cash-gray-900`.
- **Dark background:** invert it. The element uses a dark surface, a subtle lighter
  border, light-grey/near-white text, and a deeper (not lighter) shadow. Shadows
  barely read on dark, so **borders do the separating** there.

Both directions are already wired through the tokens — if you build with the tokens,
you get this behaviour free in light and dark. Never hardcode a hex where a token exists.

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

## 7. When you need something the library doesn't have yet

1. First check `components-catalog.md` — it may already exist.
2. If not, build it **from the existing tokens and in the existing spirit** (neutral
   first, colour only for meaning). Add it to `cashy-ui.css` with the `cash-` prefix
   and a matching demo + snippet in `index.html`, then note it in the catalog.
3. Keep the change small and composable (modifier classes over one-off components),
   the way the tables use `--striped`, `--compact`, `--bordered`.

The goal is always: the next page should be **assembled from approved parts**, so the
user reviews *content and layout*, not colours and paddings, ever again.

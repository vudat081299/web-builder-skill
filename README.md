# web-builder-skill

A collection of [Claude](https://claude.com/claude-code) **skills** for building web UIs. Today it holds
one skill: **cashy-ui**. (New skills get their own top-level folder + a section here.)

---

## cashy-ui — a minimalist design system for personal-finance apps

Pre-approved visual decisions, packaged so you (or an AI) **assemble approved parts** instead of
redesigning from scratch every time. White-black-grey first, colour only when it carries meaning, one soft
shadow scale, real dark mode — tuned for money data (tables, budgets, receipts, tags). It's a **styling
layer**: it owns the look; interactive behaviour is delegated to Radix/shadcn + friends in the app.

### The three parts

| Part | Where | What it does |
|---|---|---|
| **1 · Skill** (for an AI) | `cashy-ui/SKILL.md` + `cashy-ui/references/` | Instructions + a component catalog an AI reads so it builds finance UI from `cash-*` parts instead of inventing styles. |
| **2 · Docs** (for a human) | `cashy-ui/assets/` | A living component gallery — **43 pages**, light/dark, browsable. Ships `cashy-ui.css`, the one file the real app consumes. |
| **3 · Code docs** (inside the docs) | every page + the source | Each page shows its copy-paste markup; the source (`cashy-ui.css`, `app.js`, `docs.css`) is heavily commented. |

### What each part contains

**1 · Skill** — the AI-facing knowledge:
- `SKILL.md` — entry point: the one rule ("don't invent styling"), the colour ladder, current scope, house conventions.
- `references/components-catalog.md` — "building X → use Y, here's the snippet" lookup (**start here** for a build task).
- `references/design-principles.md` — the colour ladder, token discipline, dogfooding, layout stance, and every convention, numbered.
- `references/cashy-integration.md` — how the CSS + tokens + React wrappers plug into cashy's Vite/Tailwind/shadcn/next-themes.
- `references/bootstrap-comparison.md` — coverage vs Bootstrap 5.3 (what we have / skip / do differently), for "do we need component X?" calls.

**2 · Docs** — the living gallery in `cashy-ui/assets/`:
- `cashy-ui.css` — **the library** (design tokens + all `cash-*` components). **The only file that ships to the app.**
- `index.html` + `app.js` + `docs.css` — the docs **shell** (hash router, sidebar tree, theme toggle, config drawer). Docs chrome — **never ships**.
- `pages/<id>.html` — one small, markup-only page per component/foundation (43 total).
- `serve.py` — a `no-store` dev server so a normal reload shows edits.

**3 · Code documentation** — no separate manual needed: every component page renders its own copy-paste
snippet (the `demo__code` block), and the source files are commented section-by-section. This README + the
skill cover "how the whole thing fits together."

### Run the docs

```bash
cd cashy-ui/assets && python3 serve.py        # → http://127.0.0.1:8777   (pass a port to override 8777)
```

`serve.py` sends `Cache-Control: no-store`, so a **normal reload shows your edits** (no hard-refresh).
Deep-link to a page with the hash: `#/tables`, `#/receipt`, `#/charts`. The docs load Google Fonts
(Material Symbols icons + font picker), so keep internet on.

---

## Adding a primitive component (and keeping everything in sync)

A component is **one change across five places** — if they drift, the skill starts lying to the next AI.

1. **CSS** — add a numbered section to `cashy-ui/assets/cashy-ui.css`: `.cash-<name>` (+ `__element`,
   `--modifier`). Build from **tokens**, never raw hex/px (hairline = `var(--cash-bw)`, pill =
   `var(--cash-radius-pill)`; see design-principles §18). Dark mode is automatic if you use `--cash-*`.
2. **Demo page** — create `cashy-ui/assets/pages/<id>.html`. Markup only (no `<html>`/shell). Copy the
   `doc-page-head` → `doc-sec` → `doc-block` → `demo` / `demo__code` structure from an existing page, and
   use the library's own layout utilities (`.cash-cluster` / `.cash-stack` / `.cash-grid`), not inline flex.
3. **Nav** — add `{ id: "<id>", label: "…" }` to the right group in the `NAV` array in
   `cashy-ui/assets/app.js`. `NAV` is the single source of truth for the sidebar **and** the router.
   Groups are by user intent: *Nền tảng · Hành động · Nhập liệu · Hiển thị dữ liệu · Phản hồi · Điều hướng
   · Biểu đồ · Cấu trúc*.
4. **Catalog** — add a section + a "Quick decision guide" row to `cashy-ui/references/components-catalog.md`.
5. **If relevant** — a new convention → `design-principles.md`; needs an app behaviour engine (Radix,
   dnd-kit, sonner…) → a row in `cashy-integration.md`; a Bootstrap-coverage note → `bootstrap-comparison.md`.

Then verify route ↔ page parity (they must match, no orphans):

```bash
diff <(grep -oE 'id: "[a-z0-9-]+"' cashy-ui/assets/app.js | sed -E 's/id: "(.*)"/\1/' | sort -u) \
     <(ls cashy-ui/assets/pages | sed 's/\.html$//' | sort -u) && echo "OK: routes == pages"
```

> An AI working in this repo gets the same rule automatically from `CLAUDE.md`.

## Conventions (the short list)

White-black-grey first; colour only for real status/meaning; **tokens over magic numbers**; the docs are
**dogfooded** (pages are built from `cash-*` primitives; `docs.css` holds only chrome with no library
equivalent); on dark, shadows flip to a soft **light** lift; a dismiss **×** sits **top-right**; **no
left-accent bars**; icons come from an icon font (never hand-drawn). Layout stays a small flex/grid utility
set — **not** a Bootstrap-style 12-column foundation (Tailwind owns responsive columns in the app). Full,
numbered rules: [`cashy-ui/references/design-principles.md`](cashy-ui/references/design-principles.md).

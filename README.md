# web-builder-skill

A collection of [Claude](https://claude.com/claude-code) **skills** for building web UIs. Today it holds
one skill: **web-builder**. (New skills get their own top-level folder + a section here.)

---

## web-builder — a minimalist CSS component library for building web UIs

Pre-approved visual decisions, packaged so you (or an AI) **assemble approved parts** instead of
redesigning from scratch every time. White-black-grey first, colour only when it carries meaning, one soft
shadow scale, real dark mode. **Standalone and zero-build** — one drop-in `wb-*`-prefixed stylesheet that
composes with any stack and needs none. It's a **styling layer**: it owns the look; interactive behaviour is
delegated to a behaviour engine (Radix/shadcn + friends) in the app. Tuned first for money data (tables,
budgets, receipts, tags — its **flagship** use), but general-purpose for any minimalist web build.

### The three parts

| Part | Where | What it does |
|---|---|---|
| **1 · Skill** (for an AI) | `web-builder/SKILL.md` + `web-builder/references/` | Instructions + a component catalog an AI reads so it builds web UI from `wb-*` parts instead of inventing styles. |
| **2 · Docs** (for a human) | `web-builder/assets/` | A living component gallery — **40+ pages**, light/dark, browsable. Ships `web-builder.css`, the one file the real app consumes. |
| **3 · Code docs** (inside the docs) | every page + the source | Each page shows its copy-paste markup; the source (`web-builder.css`, `app.js`, `docs.css`) is heavily commented. |

### What each part contains

**1 · Skill** — the AI-facing knowledge:
- `SKILL.md` — entry point: the one rule ("don't invent styling"), the colour ladder, current scope, house conventions.
- `references/components-catalog.md` — "building X → use Y, here's the snippet" lookup (**start here** for a build task).
- `references/design-principles.md` — the colour ladder, token discipline, dogfooding, layout stance, and every convention, numbered.
- `references/integration.md` — how the CSS + tokens + optional React wrappers plug into any app's stack (React/Vite/Tailwind/shadcn/next-themes as the worked example).
- `references/bootstrap-comparison.md` — coverage vs Bootstrap 5.3 (what we have / skip / do differently), for "do we need component X?" calls.

**2 · Docs** — the living gallery in `web-builder/assets/`:
- `web-builder.css` — **the library** (design tokens + all `wb-*` components). **The only file that ships to the app.**
- `index.html` + `app.js` + `docs.css` — the docs **shell** (hash router, sidebar tree, theme toggle, config drawer). Docs chrome — **never ships**.
- `pages/<id>.html` — one small, markup-only page per component/foundation (one per `NAV` route — kept in parity; see the self-check below).
- `serve.py` — a `no-store` dev server so a normal reload shows edits.

**3 · Code documentation** — no separate manual needed: every component page renders its own copy-paste
snippet (the `demo__code` block), and the source files are commented section-by-section. This README + the
skill cover "how the whole thing fits together."

### Run the docs

```bash
cd web-builder/assets && python3 serve.py        # → http://127.0.0.1:8777   (pass a port to override 8777)
```

`serve.py` sends `Cache-Control: no-store`, so a **normal reload shows your edits** (no hard-refresh).
Deep-link to a page with the hash: `#/tables`, `#/receipt`, `#/charts`. The docs load Google Fonts
(Material Symbols icons + font picker), so keep internet on.

---

## Adding a primitive component (and keeping everything in sync)

A component is **one change across six places** — if they drift, the skill starts lying to the next AI.

1. **CSS** — add a numbered section to `web-builder/assets/web-builder.css`: `.wb-<name>` (+ `__element`,
   `--modifier`). Build from **tokens**, never raw hex/px (hairline = `var(--wb-bw)`, pill =
   `var(--wb-radius-pill)`; see design-principles §18). Dark mode is automatic if you use `--wb-*`.
2. **Demo page** — create `web-builder/assets/pages/<id>.html`. Markup only (no `<html>`/shell). Copy the
   `doc-page-head` → `doc-sec` → `doc-block` → `demo` / `demo__code` structure from an existing page, and
   use the library's own layout utilities (`.wb-cluster` / `.wb-stack` / `.wb-grid`), not inline flex.
3. **Nav** — add `{ id: "<id>", label: "…" }` to the right group in the `NAV` array in
   `web-builder/assets/app.js`. `NAV` is the single source of truth for the sidebar **and** the router.
   Groups are by user intent: *Nền tảng · Hành động · Nhập liệu · Hiển thị dữ liệu · Phản hồi · Điều hướng
   · Biểu đồ · Cấu trúc*.
4. **Catalog** — add a section + a "Quick decision guide" row to `web-builder/references/components-catalog.md`.
5. **Skill** — update `web-builder/SKILL.md`, the AI's first read: add the component to the right per-intent
   scope group (*Nền tảng · … · Cấu trúc*), or note a new capability on a family already listed. Miss it and
   the next AI trusts SKILL.md's scope and assumes the part isn't there.
6. **If relevant** — a new convention → `design-principles.md`; needs an app behaviour engine (Radix,
   dnd-kit, sonner…) → a row in `integration.md`; a Bootstrap-coverage note → `bootstrap-comparison.md`.

Then verify route ↔ page parity (they must match, no orphans):

```bash
diff <(grep -oE 'id: "[a-z0-9-]+"' web-builder/assets/app.js | sed -E 's/id: "(.*)"/\1/' | sort -u) \
     <(ls web-builder/assets/pages | sed 's/\.html$//' | sort -u) && echo "OK: routes == pages"
```

> An AI working in this repo gets the same rule automatically from `CLAUDE.md`.

## Conventions (the short list)

White-black-grey first; colour only for real status/meaning; **tokens over magic numbers**; the docs are
**dogfooded** (pages are built from `wb-*` primitives; `docs.css` holds only chrome with no library
equivalent); on dark, shadows flip to a soft **light** lift; a dismiss **×** sits **top-right**; **no
left-accent bars**; icons come from an icon font (never hand-drawn). Layout stays a small flex/grid utility
set — **not** a Bootstrap-style 12-column foundation — a *minimalism* choice, and self-sufficient (no
Tailwind required). Full, numbered rules:
[`web-builder/references/design-principles.md`](web-builder/references/design-principles.md).

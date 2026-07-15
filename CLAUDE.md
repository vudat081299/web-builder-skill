# CLAUDE.md

This repo packages the **web-builder** skill — a minimalist, zero-build CSS component library for building
web UIs (personal-finance is its flagship use, not its boundary). See `README.md` for the project map, and
`web-builder/SKILL.md` for how to build UI with it.

The repo's north star is **reuse**: assemble web UI from approved `wb-*` parts, and when you build
something genuinely new, fold it back into the library + docs (the sync steps below) so the next build reuses it.

## Working here

- **Use the web-builder skill. Don't invent styling** — assemble from `wb-*` classes + tokens
  (look up the fit in `web-builder/references/components-catalog.md`). If you're typing a hex or a px, there is
  almost certainly a token for it.
- **Only `web-builder/assets/web-builder.css` ships** to the app. `index.html` / `app.js` / `docs.css` are docs
  chrome and never ship.
- **Preview:** `cd web-builder/assets && python3 serve.py` → http://127.0.0.1:8777 (no-store, so a normal
  reload shows edits). Drive the SPA by setting the hash, e.g. `#/receipt`; after editing `app.js`, do a
  full reload (its in-memory `NAV`/`ROUTES` is stale until then).

## Adding or changing a component — sync ALL of these in one change

1. `web-builder/assets/web-builder.css` — the `.wb-*` rules (numbered section; **tokens, not magic numbers** —
   hairline `var(--wb-bw)`, pill `var(--wb-radius-pill)`).
2. `web-builder/assets/pages/<id>.html` — the demo page (markup only; use `.wb-cluster/.wb-stack/.wb-grid`
   for layout, not inline `display:flex`).
3. `web-builder/assets/app.js` — a `{ id, label }` in the `NAV` array (the single source of truth for the
   sidebar + router).
4. `web-builder/references/components-catalog.md` — a section + a decision-guide row.
5. If relevant: `design-principles.md` (a convention), `integration.md` (needs an app behaviour
   engine), `bootstrap-comparison.md` (coverage note).

If these drift, the skill misleads the next AI. Verify: number of `NAV` routes == number of `pages/*.html`.

## Conventions to keep

The **colour ladder is the most important rule** (design-principles §1): white-black-grey first (tier 1);
bright **solid** colour only for real status (tier 2 — paid / overdue / due-soon); the same colour **soft**
when the signal should stay calm (tier 3). Tiers 2–3 are colour-spend *levels* that ride on **any** component
(capsule, tag, number, border, row tint, card, chart) — not just capsules. Classification (a category) is
*not* status — keep it grey.

Then: **tokens over magic numbers**; the docs are **dogfooded** (built from `wb-*` primitives); dark flips
shadows to a soft light lift; dismiss **×** top-right; **no left-accent bars**; layout is a small flex/grid
utility set, **not** a 12-column foundation. Full numbered rules: `web-builder/references/design-principles.md`.

## Git

Solo repo, committed directly to `main` (the user's established workflow). Branch only if asked.
End commit messages with `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`.

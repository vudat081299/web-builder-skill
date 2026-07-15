# CLAUDE.md

This repo packages the **cashy-ui** skill — a minimalist design system for personal-finance web apps.
See `README.md` for the project map, and `cashy-ui/SKILL.md` for how to build UI with it.

## Working here

- **Use the cashy-ui skill. Don't invent styling** — assemble from `cash-*` classes + tokens
  (look up the fit in `cashy-ui/references/components-catalog.md`). If you're typing a hex or a px, there is
  almost certainly a token for it.
- **Only `cashy-ui/assets/cashy-ui.css` ships** to the app. `index.html` / `app.js` / `docs.css` are docs
  chrome and never ship.
- **Preview:** `cd cashy-ui/assets && python3 serve.py` → http://127.0.0.1:8777 (no-store, so a normal
  reload shows edits). Drive the SPA by setting the hash, e.g. `#/receipt`; after editing `app.js`, do a
  full reload (its in-memory `NAV`/`ROUTES` is stale until then).

## Adding or changing a component — sync ALL of these in one change

1. `cashy-ui/assets/cashy-ui.css` — the `.cash-*` rules (numbered section; **tokens, not magic numbers** —
   hairline `var(--cash-bw)`, pill `var(--cash-radius-pill)`).
2. `cashy-ui/assets/pages/<id>.html` — the demo page (markup only; use `.cash-cluster/.cash-stack/.cash-grid`
   for layout, not inline `display:flex`).
3. `cashy-ui/assets/app.js` — a `{ id, label }` in the `NAV` array (the single source of truth for the
   sidebar + router).
4. `cashy-ui/references/components-catalog.md` — a section + a decision-guide row.
5. If relevant: `design-principles.md` (a convention), `cashy-integration.md` (needs an app behaviour
   engine), `bootstrap-comparison.md` (coverage note).

If these drift, the skill misleads the next AI. Verify: number of `NAV` routes == number of `pages/*.html`.

## Conventions to keep

White-black-grey first; colour only for real meaning; **tokens over magic numbers**; the docs are
**dogfooded** (built from `cash-*` primitives); dark flips shadows to a soft light lift; dismiss **×**
top-right; **no left-accent bars**; layout is a small flex/grid utility set, **not** a 12-column foundation.
Full numbered rules: `cashy-ui/references/design-principles.md`.

## Git

Solo repo, committed directly to `main` (the user's established workflow). Branch only if asked.
End commit messages with `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`.

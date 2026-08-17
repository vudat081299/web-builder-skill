# 0001 — Progress persistence: localStorage behind an adapter

**Status:** accepted · **Date:** 2026-08-16 · **Decided by:** user

## Context
Progress ("which lessons are done, where am I") must survive reload. No backend exists or is planned yet.

## Options considered
1. **localStorage behind a `store/progress.js` adapter** — simple, synchronous, enough for a set of ids.
2. **IndexedDB** — more capacity/structure, but async and heavier than this data needs.
3. **A backend account** — real sync, but adds auth + server + a release cadence we don't want yet.

## Decision
Option 1: `localStorage` behind `store/progress.js` (get/set/markComplete/version). The app never touches
`localStorage` directly. A future server sync goes **behind the same adapter interface**.

## Why it won't be revisited lightly
The adapter boundary is what makes options 2 and 3 cheap later. Revisit only if progress data outgrows
localStorage limits, or accounts/sync become a requirement — then add a layer behind the adapter, don't
rewrite call sites.

> A resuming agent that reads this does **not** re-ask "how should we store progress?" — it's settled here.

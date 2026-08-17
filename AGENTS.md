# AGENTS.md — working in the web-builder-skill repo

Tool-agnostic entrypoint for any coding agent. (Claude Code also loads `CLAUDE.md` every turn — the full
house rules live there; this file is the **map + commands**, kept short so it doesn't duplicate them.) This
repo is itself a **Level 2** project, so this file is also a live example of the contract described in
`web-builder/references/project-protocol.md`.

## What this is
The repo produces **one product: the `web-builder` skill** — a zero-build CSS component library + design
system, now paired with an **AI-native architecture layer** (help an agent pick the right project
organization). Everything else (docs site, `.claude/`, `scripts/`, `tests/`) is *instrumentation* that
exists only to build and protect the skill.

## Where things live (ownership map)
- **The skill (the product)** — `web-builder/SKILL.md` (router, < 500 lines) + `web-builder/references/*.md`
  (depth) + `web-builder/assets/web-builder.css` (**the only file that ships to a running app**) +
  `web-builder/assets/templates/*.html` (copy-source screens).
  - Component knowledge: `components-catalog.md` · `design-principles.md` · `page-review.md` ·
    `integration.md` · `bootstrap-comparison.md`.
  - Architecture knowledge (new): `project-architecture.md` (hub — the Level 0/1/2 gate + synthesis) →
    `site-profiles.md` · `learning-sites.md` · `large-static-sites.md` · `project-protocol.md` ·
    `problem-routing.md` · `verification.md`.
- **Docs site (instrumentation, never ships)** — `web-builder/assets/index.html` + `app.js` + `docs.css` +
  `pages/*.html`. Renders the living gallery for humans.
- **Tooling (instrumentation)** — `scripts/` (agent-agnostic core), `.claude/` (thin adapters + hooks),
  `tests/` (fixtures + forward tests).
- **Repo docs** — `README.md` (project map + trade-offs T#), `CLAUDE.md` (house rules), `HANDOFF.md` (open
  questions).

## Source-of-truth map (don't create a second copy of any of these)
- Component roster/markup → `components-catalog.md`. Design rules → `design-principles.md` (`§N`).
- Nav / routes → `app.js` `SECTIONS` (CHECK 1 + 10 guard it).
- Version → `--wb-version` in `web-builder.css` (CHECK 15 keeps CHANGELOG/CSS/SKILL/docs in step).
- What the `.skill` ships → `scripts/skill-manifest.txt`.
- Trade-offs → `README.md` `T#` (mirrored on `#/decisions`, CHECK 13).

## Commands
```bash
# Preview the docs (living gallery)
cd web-builder/assets && python3 serve.py        # → http://127.0.0.1:8777

# Verify everything deterministic (docs site + skill + architecture/forward-tests)
bash scripts/verify.sh                            # exit 0 = OK · exit 2 = drift (with a BLOCK reason)

# Architecture forward tests only
bash tests/forward-tests.sh

# Build / verify / release the packaged skill
bash scripts/package-skill.sh                     # deterministic build of web-builder.skill
bash scripts/verify-package.sh                    # parity + stale detection + checksum
bash scripts/release-skill.sh                     # verify → package → verify (one shot)
bash scripts/install-skill.sh [--target DIR] [--apply]   # dry-run by default; --apply needs your OK
```

## Which workflow (they don't overlap)
- **`/wb-change`** — add/modify a `wb-*` component/token, or restructure the library (the 6-place cascade).
- **`/wb-architect`** — bootstrap a site, design/refactor architecture, migrate a monolith (project shape).
- **`/wb-intake`** — classify a downstream finding as local vs upstream and route it.
- **`/wb-release`** — validate, package, verify, prepare install of the skill artifact.
- Just building UI with the library → the `web-builder` skill itself (no workflow needed).

## Conventions & boundaries
- Reuse `wb-*` + tokens; never invent styling (see `SKILL.md`). Colour ladder is rule #1 (design-principles §1).
- Docs chrome is English; page copy is Vietnamese-first (§20).
- **Protected in normal work:** `web-builder.css`, `templates/`, component docs, component behaviour in
  `app.js`. Changing a component is the `/wb-change` cascade, not an ad-hoc edit.
- Commit gate runs `scripts/verify.sh` (via `.claude/hooks/`) — fix `BLOCK ·` reasons in place, don't restart.

## Verify before you commit
The pre-commit hook blocks on drift. Run `bash scripts/verify.sh` yourself first; for a release, `bash
scripts/release-skill.sh`. Nothing commits, pushes, or installs without an explicit act.

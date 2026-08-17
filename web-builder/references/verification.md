# Verification — proving a build (and the skill) works

Verification runs in **tiers**, cheapest first, so a fast check catches most drift and the expensive checks
run only when they can prove something. It applies in two places: **upstream** (this repo — the skill
deliverable) and **downstream** (a project the skill builds). Match the depth to what a change can actually
affect — don't start a server that can't exercise the change, and don't turn a subjective visual judgment
into a noisy hard gate.

## Table of contents

- [Upstream: verifying the skill](#upstream-verifying-the-skill)
- [Downstream: verifying a build](#downstream-verifying-a-build)
- [What each tier is for](#what-each-tier-is-for)
- [Principles](#principles)

## Upstream: verifying the skill

Run from the repo root. The core is one script; `.claude` only adapts it.

```bash
bash scripts/verify.sh            # all deterministic checks (docs site + skill deliverable)
bash scripts/verify-package.sh    # after packaging: unpack, parity, stale-detect, checksum
```

**Fast (always):** shell/JS syntax, missing references, route↔page parity, profile/manifest validity, and —
for this task — the protected-file checksums. This is `scripts/verify.sh` (the former `validate-sync.sh`,
now agent-agnostic core; the `.claude` hook is a thin adapter).

**Skill / tooling:** SKILL.md frontmatter + line count (< 500), progressive-disclosure links resolve, the
scripts run **outside** Claude, context routing is coherent, the one-file gate and architecture references
exist and are linked, the local/upstream classifier and its fixtures pass, handoff/decision behaviour is as
documented.

**Docs:** only the allow-listed meta pages changed; no new per-page `<style>`; new routes work; light/dark +
responsive smoke-check for **changed** pages; no console errors. **No** full visual regression over unchanged
component pages.

**Release:** `verify-package.sh` — deterministic package, two-way manifest parity, unpacked validation, stale
artifact detection, checksum/content parity, and an install **dry-run** (never an unauthorized install).

## Downstream: verifying a build

The point of verification downstream is **parity with intent** — the build does what was asked, still. Choose
by what the change touched:

- **Level 0** — open the page: it renders, no console errors, the one or two behaviours work, responsive +
  light/dark look right. That's the whole check.
- **Level 1/2** — the project's own commands: `dev` to view, `build` to confirm it compiles, `test`/`verify`
  for logic and regressions. A migration checks **parity against the baseline** after every step
  (`large-static-sites.md`).
- **UI, always** — run the **nine-gate page review** (`page-review.md`): invented classes, the colour ladder,
  horizontal overflow, a wrapping bar (the four are a console snippet), plus the qualitative gates. The
  template makes a page start right; the review checks it ends right.
- **Behaviour** — exercise it in the browser (the preview tools), don't assume; confirm loading/error/empty
  states for anything remote.

Record the project's canonical verify command in `AGENTS.md` so a routine agent runs the same check.

## What each tier is for

| Tier | Answers | Cost |
|---|---|---|
| Fast | "Did I break something structural / mechanical?" | ~free |
| Skill / tooling | "Is the skill still coherent and self-sufficient?" | cheap |
| Docs | "Did the docs site stay valid and self-contained?" | medium (browser) |
| Release | "Is the package honest — fresh, complete, installable?" | medium |
| Downstream | "Does the build still do what was asked?" | project-specific |

## Principles

- **Cheapest first.** A fast check that catches 90% of drift beats a slow one you skip.
- **Only verify what the change can affect.** No server for a non-previewable change.
- **Deterministic gates are model-free** — they're free and can gate every commit. Keep them low-noise: a
  gate that cries wolf trains everyone to ignore it (why §18 magic-number and 6-place coherence stay eyeball
  checks, not gates — see the repo's decisions/trade-offs).
- **Subjective visual quality is a review, not a hard gate.** The nine-gate review is judgment with four
  measurable anchors — don't try to mechanize the other five into a blocking check.
- **Prove it, don't claim it.** Show the screenshot / the passing output / the parity result. If a check was
  skipped, say so.
</content>

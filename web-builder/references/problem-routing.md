# Problem routing — is this local, or does it belong upstream?

A finding in a downstream build is either the **project's own** problem or the **Web Builder skill's**
problem. Routing it correctly is what lets the skill *compound*: real upstream issues flow back and get fixed
once for everyone, while project-specific quirks stay local instead of polluting the library.

> **Never auto-edit the Web Builder repository (or any other repo) from a downstream session.** An upstream
> finding is **reported**, not silently patched. The downstream fix (a local workaround, if any) and the
> upstream report are separate acts.

## Table of contents

- [The classifier](#the-classifier)
- [The reproduction test](#the-reproduction-test)
- [The upstream report format](#the-upstream-report-format)
- [Examples](#examples)

## The classifier

Assign exactly one class:

| Class | Condition |
|---|---|
| `skill-bug` | Reproduces using the **latest shipped `web-builder.css` / template**, with **no custom code**. |
| `project-local` | **Disappears** when you remove the project's custom CSS/JS; or it's business
  rule / content / data / branding specific to this project. |
| `upstream-candidate` | A **reusable** primitive or pattern the library lacks — many projects would use it. |
| `skill-integration` | A **framework-integration** gap that applies broadly (e.g. an SSR/hydration note true
  for any Next app), not one project's wiring. |
| `project-architecture` | A workaround forced by **this project's** current architecture, not the library. |
| `needs-triage` | Not enough evidence yet — reduce it first (below). |

The three that flow upstream are `skill-bug`, `upstream-candidate`, and `skill-integration`. `project-local`
and `project-architecture` stay in the project. `needs-triage` means *keep investigating*.

## The reproduction test

The decisive move is a **minimal reproduction on the shipped skill**:

1. Rebuild the symptom using **only** shipped `wb-*` classes / a stock template + the latest `web-builder.css`
   — no project CSS/JS.
2. **Reproduces?** → `skill-bug` (the library is wrong). Report upstream.
3. **Doesn't reproduce?** → strip the project's custom CSS/JS from the failing view.
   - Symptom **vanishes** with the custom code removed → `project-local`.
   - Symptom is really "the library can't do X, so I had to hand-roll it" → is X reusable? Yes →
     `upstream-candidate`. No (project-specific) → `project-local`.
4. Still unclear → `needs-triage`: capture what you tried and what's missing, don't force a class.

Classification is **evidence-driven**, never a guess from the description.

## The upstream report format

When (and only when) upstream work is genuinely needed, the downstream session's **final response** must
include this block, verbatim in shape, so the upstream repo can intake it (`/wb-intake`):

```
WEB-BUILDER UPSTREAM REQUIRED

ID:                 <short-slug>
Type:               skill-bug | upstream-candidate | skill-integration
Evidence:           <minimal repro on shipped skill, or why the primitive is reusable>
Suggested change:   <the smallest change that fixes it>
Affected skill files: <web-builder.css / SKILL.md / catalog / template / reference …>
Release required:   <yes/no — does this need a repackage + reinstall?>
```

Keep it factual and minimal. "Suggested change" is a proposal for the upstream maintainer, not a licence to
edit the upstream repo from here.

## Examples

- A modal dismisses when you press inside and release on the backdrop, using the **stock** modal markup and
  latest CSS → `skill-bug`. (This exact bug shipped once — see the repo's HANDOFF history.) Report upstream.
- A chart's bars are the wrong colour, but only because the project overrode `--wb-*` tokens in its own CSS →
  `project-local`. Fix the project's overrides.
- You keep re-implementing a "stat card with a sparkline and a delta" across projects because the library has
  stat cards and sparklines but not the combination → `upstream-candidate`. Report it; keep a local version
  meanwhile.
- Hydration mismatch on a `wb-shell` in Next.js because the mobile-drawer toggle reads `window` on first
  render — true for any Next app using the shell → `skill-integration`. Report with the SSR-safe fix.
- A debt-calculation rounding rule is wrong → `project-local` (business rule), never upstream.
- The shell needs an extra slot that only this dashboard uses → `project-architecture`; solve it locally.

# Page review — the gate you run on your own page before delivering it

You have just built a screen with this library. **Run this before you say it's done.** It takes one pass and
catches the failures that actually happen — every gate below exists because a real build failed it, not
because it sounded like good practice.

Read it as a checklist, not an essay. Gates are ordered by *how often they're the thing that's wrong*, so a
short review that only gets through G1–G4 still catches most of it.

> **Where this fits:** `SKILL.md` tells you to start from `assets/templates/<screen>.html`. This file is the
> other end — the check that what you produced still belongs to the system. A page that passes all nine gates
> looks like the docs; that is the whole claim.

---

## The mechanical gates — run these, don't eyeball them

Four of the nine are *measurable*, and measuring beats judgement every time. Paste these into the browser
console (or your test runner) on the finished page.

### G1 · Did you start from a template? (the one that invalidates the rest)

`SKILL.md` makes this a rule: a whole screen starts from `assets/templates/`. If you composed from the
catalog instead, stop and say so out loud in your hand-off, with the reason no template fit the *shape*.

Then fold it back — a new screen shape means **a catalog recipe row AND a template file**
(`validate-sync.sh` CHECK 14 enforces both directions). A one-off page that never becomes a template is the
next build's re-invention.

**Fails when:** you can't name which template you opened.

### G2 · Every class you used exists

The single most damaging failure mode: an invented class renders as *nothing*, silently. `wb-cap--paid`
looks plausible, does nothing, and no tool complains.

```js
// Paste in the console on your page. Lists any wb-*/is-* class no stylesheet defines.
(() => {
  const defined = new Set();
  const walk = rules => {
    for (const r of rules) {
      if (r.selectorText) r.selectorText.replace(/\.((?:wb|is)-[\w-]+)/g, (_, c) => defined.add(c));
      if (r.cssRules) walk(r.cssRules);        // MUST recurse: @container / @media / @supports
    }
  };
  for (const sheet of document.styleSheets) {
    let rules; try { rules = sheet.cssRules } catch { continue }        // cross-origin
    walk(rules);
  }
  const used = new Set();
  document.querySelectorAll('[class]').forEach(el => el.classList.forEach(c =>
    /^(wb|is)-/.test(c) && used.add(c)));
  const missing = [...used].filter(c => !defined.has(c)).sort();
  return missing.length ? { MISSING: missing } : 'OK — no invented classes';
})()
```

The recursion matters: a fair chunk of this library (every responsive collapse) lives inside `@container`,
and a non-recursing version reports all of it as missing. Sanity-check the count — `defined` should be in
the high hundreds (549 at the time of writing), not a few dozen.

Known false positive: `.wb-theme-toggle` is a JS/namespace hook with no rule of its own (only its
`__to-light` / `__to-dark` children are styled). Anything else in the list is a real bug — on its first run
this check found `.is-done`, a state the docs promised and the CSS never defined, used in two shipped
templates. It "worked" only because it happened to match the default.

**Fix:** find the real class in `components-catalog.md`. If it genuinely doesn't exist, that's the
`SKILL.md` step-3 path (build it from tokens, add a demo page, register it, catalog it) — not an inline style.

### G3 · The colour ladder holds (§1) — the rule most often broken

Tier 1 is white-black-grey. **Bright colour only for real status** (paid / overdue / due-soon). A category,
a plan tier, a "recommended" badge, a brand accent — none of those are status. They stay grey; emphasis
comes from *contrast* and *size*.

```js
// Lists every element painting a non-neutral background. Each hit must be real status.
[...document.querySelectorAll('main *, .wb-shell__main *')].flatMap(el => {
  const bg = getComputedStyle(el).backgroundColor.match(/[\d.]+/g);
  if (!bg) return [];
  const [r, g, b, a = 1] = bg.map(Number);
  return (a > 0.02 && Math.max(r, g, b) - Math.min(r, g, b) > 12)
    ? [`${el.tagName}.${el.className} → ${getComputedStyle(el).backgroundColor}`] : [];
})
```

An **empty list is the expected result** for most screens — a dashboard, a form, a settings page and a
landing page all pass with zero coloured backgrounds. A list screen showing overdue debts should have a few,
and every one should be explainable in a sentence: *"red soft tint = overdue"*.

**Fails when:** a hit can't be named as a status. Swap it for grey, or for a solid **neutral** chip
(solid black on a *small* element is tier 1 — it spends contrast, not colour).

### G4 · No horizontal overflow, at every width that matters

```js
// > 0 means the page scrolls sideways. Run it at each width below.
document.documentElement.scrollWidth - document.documentElement.clientWidth
```

Check **1280 · 900 · 700 · 390**. Those aren't arbitrary: 900 is where `.wb-shell` folds its rail and
`.wb-navbar--collapse-lg` collapses, 640 is where a default `.wb-navbar` collapses. The gaps *between* two
breakpoints are where real bugs live — both responsive bugs this library has shipped (no rail-open button
between 640–900px; a public navbar wrapping to two rows between ~660–840px) were invisible at 1280 and at
390, and only appeared in the band between.

Also check the bar didn't **wrap**: `document.querySelector('.wb-navbar').getBoundingClientRect().height`
should stay at `--wb-navbar-h` (56) at every width. A taller bar means its contents don't fit and it hasn't
collapsed yet.

---

## The judgement gates — look at the page

### G5 · The frame is shipped parts, not your own

- `<body class="wb-app">` — the baseline (border-box, font, canvas/ink colours, line-height, link colour).
  Without it the page falls back to browser defaults: serif text, blue underlined links.
- The shell is `.wb-shell` + its slots, or — for a public page — plain `wb-navbar` + `wb-container` +
  `wb-footer`. Never a hand-rolled grid.
- **No `min-height: 100vh`, no hand-picked `margin-top`, no one-off `padding` on a section.** Spacing comes
  from `--wb-section-gap` / `--wb-block-gap`. If a gap feels wrong, retune the token.

A hand-rolled shell or a one-off margin is the single biggest reason a build stops looking like this system.

### G6 · The heading ladder is intact

`wb-eyebrow` → `wb-page-head` → `wb-section` → `wb-block`, each with its `__title` / `__desc`. Exactly one
`<h1>` (or one `wb-page-head` title) per page, and heading levels don't skip — the ladder styles whatever
`h1…h6` you nest, so a valid outline costs nothing.

Nest a breadcrumb **inside** `.wb-page-head` (it carries no margin of its own; as a sibling above it
collides with the eyebrow).

### G7 · Both themes

Toggle `.dark` on `<html>` and look again. Specifically: does anything disappear? The failure mode is a
colour that happens to equal its background in one theme only. Re-run **G3** in dark too.

Shadows flip to a soft *light lift* in dark — if you wrote a shadow by hand instead of using
`--wb-shadow-sm/md`, it will look wrong here.

### G8 · Accessibility floor

- Every icon-only button has `aria-label` (`wb-btn--icon`, `wb-close`, `wb-tag__x`, toggles). No exceptions.
- Interactive things are `<button>` / `<a>`, not a `<div>` with a click handler.
- A dismiss × is `.wb-close` with the glyph from `::before` — never a typed `×`.
- Don't remove focus rings; `:focus-visible` is already styled.

### G9 · Copy is data (§20)

Real domain copy in the real product language — **no lorem ipsum, no `Label 1 / Label 2`**. Sample numbers
should be plausible for the domain (a Vietnamese money app shows `6.800.000 ₫`, not `$1,234`). Placeholder
copy hides layout bugs that only real text lengths reveal: a long name that wraps, a number that overflows
its column.

---

## Smells — specific mistakes this library invites

Each of these was a real bug, not a hypothetical:

| Smell | Why it's wrong | Do this |
|---|---|---|
| `wb-grid` + `--wb-grid-min` and nothing reflows | the min is only read by the `--auto` modifier | add `wb-grid--auto` |
| `wb-section--flush` right above an `<h2>` | `--flush` removes the gap the heading needs | drop `--flush` on a section that has a heading |
| A `<div class="wb-divider wb-divider--label"><span>…</span></div>` | not the shipped markup | `<div class="wb-divider--label">HOẶC</div>` |
| Inline `display:flex` on a demo/page wrapper | layout is a utility set | `wb-cluster` / `wb-stack` / `wb-grid` |
| A hex or a px in a `style=` attribute | there is almost certainly a token | look it up in `tokens` before typing a literal |
| `.wb-num` on a standalone number (a price, a hero figure) | it is `text-align: right` **on purpose** — for money in a table column, where digits must line up. In a card it shoves the number to the edge | `.wb-stat__value` (a big standalone number; not scoped to `.wb-stat`) |
| `.wb-shell__side-toggle` vs `.wb-navbar__toggle` | different jobs — one opens the rail, one collapses the bar's inline links | rail → `__side-toggle`; public bar links → `__navbar-toggle` + `--collapse-lg` |
| A "recommended" plan tinted green | recommended is not a status | small solid **neutral** capsule + the row's only solid button |

---

## When a gate fails

Fix the page, then **ask whether the library should have prevented it**. If you had to invent something to
make a normal screen look right, that thing belongs in `web-builder.css`, not in your page —
design-principles **§25**. Three shipped-CSS bugs were found exactly this way, by building a real screen with
only what ships and noticing what had to be invented. Fold the fix back through the sync cascade
(`CLAUDE.md` § *Adding or changing a component*) so the next build starts from a better floor.

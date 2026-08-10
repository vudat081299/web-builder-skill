# Hand-off — open questions & pending work

**Written 2026-07-31.** A working note, not product docs. State at the time of writing: working tree clean,
`bash .claude/hooks/validate-sync.sh` → **exit 0** (no mechanical drift). Everything below is a *judgment*
call still open, or a real gap found in review — nothing here is a failing check.

As items get resolved, **delete them from this file** and move the durable outcome into its permanent home
(`README.md` `T#` + `pages/decisions.html` for a decision · `CHANGELOG.md` + `SKILL.md` + the catalog for a
component). If this note ever contradicts those, **they win.**

---

## Backdrop dismiss — press *and* release must land on the scrim (fixed 2026-08-10)

**The gap.** The same modal/drawer footgun surfaced across several downstream projects at once:
pressing inside a modal, dragging out, and releasing on the backdrop **dismissed** it. Root cause is
here in the skill, on two reinforcing paths: (1) the docs-demo driver `assets/app.js` closed the
overlay on a bare `click` whose target was `.wb-overlay`, and a `click` fires on the nearest common
ancestor of press + release — which, when the overlay wraps the modal, is the overlay; (2) the catalog
said only "clicking the backdrop closes", so hand-written implementations downstream reinvented the
same `e.target === overlay`-on-`click` bug.

**Fixed.** `assets/app.js` — the click branch now only handles `[data-modal-close]`; backdrop dismiss
moved to a `pointerdown`/`pointerup` pair on `document` that clears `.is-open` only when **both** land
on the same `.wb-overlay`. `references/components-catalog.md` (Modal / Dialog) now spells out the
press+release rule and says to drive it with pointer events, not `click`.

**Still open (judgment):**
- Promote the rule to a numbered design principle (§15, "a dismiss × sits top-right", is the natural
  neighbour). Left out of this pass to avoid the `principles.html` render-sync — do it next time
  principles are touched.
- **Popover / dropdown outside-click** (`assets/app.js`, the popover branch) still closes on the same
  bare `click`: a drag that starts inside the card and releases outside can dismiss it. Lower stakes
  (no full-screen scrim) and not fixed here — decide whether it deserves the same guard.
- The docs site never ships, but `assets/app.js` **is** copied verbatim into live sites; any holder of
  a copy needs the same two-part change. The one known copy has already been patched.

---

## 0. The question that triggered this note

**Goal:** when another AI reads the `web-builder` skill and builds a web app, the resulting app code should be
fast to write, light, maintainable, reusable, SOLID, clean — by *calling ready-made components*.

**The hypothesis on the table:** *"plain HTML+CSS isn't OOP, so reuse is hard → I need to convert every
primitive to React."*

### What's off in that hypothesis

Reuse here is **not** achieved through OOP, and the absence of OOP is not what's limiting it.
`class="wb-cap wb-cap--success"` **is** the reuse unit — the library is composition-first by construction, and
a CSS class behaves more like a value/trait than an object. SOLID is a property of the *app's* modules
(components, services, boundaries), not of a styling layer; and the styling layer already holds the single
responsibility it should ("own the pixels, delegate behaviour" — see `SKILL.md` § *Three standing decisions*,
#2). Wrapping the same classes in `.tsx` adds **zero** reuse that the classes don't already have — the same
markup was always reusable by copy-paste from the catalog.

### What's right in it — and this is the real point

What a React kit actually buys is **call-site ergonomics for a code-generating AI**:

- **Typing** — an invalid combination fails at compile time instead of silently rendering wrong.
- **Discoverability** — the AI completes `tone="success"` instead of recalling `wb-cap--success` out of a
  1,479-line catalog.
- **Misuse-resistance** — today an AI can invent `wb-cap--paid`, and *nothing* complains: the class just
  doesn't exist and the element renders unstyled. This is the single strongest argument for a kit.
- **Fewer tokens per call site**, and one place to edit if a class name ever changes.

So the motivation is legitimate; the framing is not. Name it correctly: **this is an API-surface / typing
problem, not a paradigm problem.** That reframing matters because it changes the fix — you do *not* need to
rewrite 63 components. You need a typed façade over the ~10 that carry most of the modifier weight.

---

## 1. Where the React story actually stands (verified 2026-07-31)

- **Zero** `.tsx` / `.ts` / `.jsx` files in the repo.
- [`integration.md:83`](web-builder/references/integration.md:83) — *"React wrappers (optional)"*: **one**
  worked wrapper (`Capsule`, via CVA + `cn`), plus an explicit note that **tables are clearer as plain JSX**
  and that a data-driven `columns`/`rows` API should be *deferred until the visual language is locked*.
- [`integration.md:137`](web-builder/references/integration.md:137) — a 24-row *"which components need a
  behaviour primitive"* table (Radix · dnd-kit · sonner · react-day-picker · imask · TipTap · Recharts).
- Scale of the surface: **63** demo pages; **293** top-level `.wb-*` selectors (families + modifiers) in
  `web-builder.css`.

Net: **the pattern is documented, the kit is not built** — roughly 1 wrapper out of 63 primitives.

**Gap worth closing regardless of what you decide:** "no React kit" is **not recorded as a deliberate
trade-off.** `README.md` T1–T5 don't cover it, so a future reader (or AI) sees "optional React wrappers" in
`SKILL.md`, finds an empty repo, and can't tell **chosen** from **forgotten**. Whatever you land on — *including
"never build one"* — should become **T6** in `README.md` and be mirrored on `pages/decisions.html`
(`validate-sync.sh` CHECK 13 enforces the mirror). Right now the silence is the bug.

---

## 2. Does a kit require splitting the CSS? **No.**

The two are unrelated. A kit never touches `web-builder.css`:

```
web-builder.css   →  still one file, one <link>/import at the app root   (unchanged)
kit .tsx          →  only returns className="wb-cap wb-cap--success"
```

**T1 stays intact** — one file, no tree-shaking, zero-build. The kit adds no CSS, removes none, and doesn't
care which file the CSS lives in.

Splitting the CSS is a *different* idea: per-component style imports (CSS Modules / `import './capsule.css'`)
to enable tree-shaking. That one **violates T1 head-on** — it reintroduces exactly the build step the library
exists to avoid. **Do not conflate the two.**

---

## 3. Three ways to ship a kit

| | **A · Copy-paste snippets in the skill** | **B · `.tsx` files inside the skill** | **C · npm package** |
|---|---|---|---|
| Form | a `references/react-kit.md` of paste-ready wrappers (same model the catalog uses for HTML) | real files under `web-builder/` that a consumer copies into `src/components/ui/` | `@web-builder/react`, semver + releases |
| Build on our side | none | none (the app's own bundler compiles them — any React app already has one) | yes: tsup/rollup, `.d.ts`, publish |
| Keeps zero-build? | ✅ | ✅ | ❌ |
| Consumer effort | paste per component | copy a folder | `npm i` |
| Drift risk | low (small surface) | medium | medium + release process |

A and B both preserve the current philosophy. **C changes what the product *is*** — from a styling layer into a
framework, with a release cadence to maintain. That's the genuinely large decision; A/B are not.

---

## 4. The real cost of a kit: a 7th sync surface

`CLAUDE.md` mandates a **6-place** sync per component change. A kit makes it **7** — every new modifier in the
CSS must also land in the kit's variant map. And `validate-sync.sh` currently knows **nothing** about `.tsx`.

A kit that drifts from the CSS is precisely the "the skill starts lying to the next AI" failure mode the whole
guardrail apparatus exists to prevent — just on a new surface with no guard on it.

**Hard prerequisite:** if a kit ships, it ships **with** a new check — every variant string in the kit resolves
to a class that actually exists in `web-builder.css` (same shape as the existing catalog↔CSS check). No check,
no kit. Note this is *cheap* precisely because the kit contains no styling logic: it's a string-existence test.

---

## 5. Recommendation

Go **light and incremental** (option A or B), and let the value concentrate where the modifiers are:

1. **Wrap only the high-modifier primitives** — about ten: `Btn`, `Capsule`, `Tag`, `Card`, `Alert`, `Stat`,
   `Progress`, `Input` (+ `InputGroup`), `Toast`, `Cap`-family tones. These are where an AI most often picks a
   wrong or non-existent modifier.
2. **Leave plain JSX** for `table`, layout utilities, `receipt`, and charts. `integration.md` already reached
   that conclusion for tables — don't reverse it without a reason.
3. **Write them dependency-free** (plain template strings + a filter), with CVA + `cn` shown as an *optional*
   variant. The current example silently assumes a shadcn-style project; a kit shouldn't.
4. **Add the kit↔CSS check** to `validate-sync.sh` (see §4) in the *same* change, not later.
5. **Record the decision as T6** in `README.md` and mirror it on `pages/decisions.html`.

Cheapest high-value alternative if you'd rather not build a kit at all: keep HTML, and make the *catalog* the
misuse guard — an explicit, exhaustive modifier list per family so an AI can't invent one. Then T6 says
"pattern only, on purpose" and the question is closed either way.

---

## 6. Other pending work found in the same review

Independent of the kit question, ordered by value against the flagship use (money data):

1. **Column sort on tables — missing.** `wb-table--sortable`
   ([`web-builder.css:1751`](web-builder/assets/web-builder.css:1751)) is *row drag-reorder*, not header sort.
   No `.is-sorted` asc/desc, no indicator, no demo, and `bootstrap-comparison.md` doesn't record it as skipped.
   Sorting by amount/date is the #1 need of a transactions or debt table.
2. **Row selection / bulk actions — missing.** `wb-tree__row.is-selected` exists; `wb-table` has no selected-row
   state, no select-all, no action bar. Paired with `wb-filterbar`, this is the most common list-screen combo.
3. **`@media print` — zero lines** in `web-builder.css` and `docs.css`. Receipts (hoá đơn) and debt tables are
   exactly what people print.
4. **Code block is docs-only chrome.** `.demo__code` lives in `docs.css` (never ships); the library has no
   `wb-code`/`pre` primitive — mildly against the §2 dogfood stance, and an app needing a monospace block has
   nothing to reach for.
5. **Counter badge exists only as `wb-sidenav__badge`** ([`web-builder.css:2428`](web-builder/assets/web-builder.css:2428)).
   No shared counter for navbar / tabs / buttons.
6. **a11y §19 is half-done.** `:focus-visible` (14 sites) and `prefers-reduced-motion` (3) are good;
   `forced-colors` and `prefers-contrast` are **0**. RTL is 0 too — that one should be **recorded as a non-goal**
   rather than built.
> Items 7 (version drift) and 8 (stale positioning in the shipped file) were **resolved in `03b8a4c`** and
> deleted from this list per the rule above. Their durable homes: `CHANGELOG.md` v0.6, the `--wb-version`
> token, and `validate-sync.sh` CHECK 15 (rendered on `#/tooling`) so the drift can't come back silently.

**Already recorded, still open:** T3 (manual `.skill` packaging) and T4 (no inlined manual `/wb-change`) remain
*deferred*; T5 (no §18/coherence gate) remains *chosen — keep it*. `carousel` / `scrollspy` / floating labels
stay skipped on purpose (`bootstrap-comparison.md`).

---

## 7. When you pick this up

- Anything in §6 that touches a component or token → run **`/wb-change`**; it drives the 6-place sync and the
  commit gate runs `validate-sync.sh` for you.
- Of what's left in §6, items **1–2** (table column sort, row selection / bulk actions) carry the most weight
  against the flagship use — a transactions or debt table can't be sorted or acted on in bulk today.
- The kit question (§0–§5) is a **decision first, code second**. Land T6 before writing `.tsx`.

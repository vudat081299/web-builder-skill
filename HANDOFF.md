# Hand-off — open questions & pending work

**Written 2026-07-31.** A working note, not product docs. State at the time of writing: working tree clean,
`bash .claude/hooks/validate-sync.sh` → **exit 0** (no mechanical drift). Everything below is a *judgment*
call still open, or a real gap found in review — nothing here is a failing check.

As items get resolved, **delete them from this file** and move the durable outcome into its permanent home
(`README.md` `T#` + `pages/decisions.html` for a decision · `CHANGELOG.md` + `SKILL.md` + the catalog for a
component). If this note ever contradicts those, **they win.**

---

## AI-native architecture layer — landed 2026-08-17

The skill gained a second job beside "build beautiful UI": **help an agent choose the right amount of project
architecture** (a one-file fast path by default; real structure only when a site is large/long-lived). No
component, template, runtime, or component doc changed — this is skill/tooling/architecture only. Durable homes
(don't re-derive from here):

- **Knowledge:** `web-builder/references/project-architecture.md` (hub: Level 0/1/2 gate + constraint-based
  synthesis + patterns + decomposition + evolution) → `site-profiles.md` · `learning-sites.md` ·
  `large-static-sites.md` · `project-protocol.md` · `problem-routing.md` · `verification.md`.
- **Router:** `web-builder/SKILL.md` (one-file gate + invocation boundary + architecture routing; frontmatter
  trigger extended; stays < 500 lines).
- **Tooling (agent-agnostic core, outside `.claude`):** `scripts/verify.sh` (former `validate-sync.sh`; the
  `.claude` hook is now a thin adapter), `package-skill.sh` + `verify-package.sh` + `release-skill.sh` +
  `install-skill.sh` + `skill-manifest.txt`; classifiers `classify-project.sh` / `classify-problem.sh`.
- **Workflows:** `/wb-architect` · `/wb-intake` · `/wb-release` (non-overlapping with `/wb-change`).
- **Proof:** `tests/forward-tests.sh` + `tests/fixtures/` + `tests/examples/` (L0 vs L2), folded into the gate.
- **Decisions:** `README.md` **T3** (packaging — now resolved), **T7** (`.skill` ships agent payload only),
  **T8** (architecture is adaptive, not a standard tree) — mirrored on `#/decisions`. Entrypoint: root
  `AGENTS.md`.

Nothing here is open; this note is a pointer so the next agent finds the homes fast.

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

**Tail resolved 2026-08-27** (moved to durable homes, per the rule at top):
- The rule is now a numbered principle — **design-principles §27** ("Dismiss on a full click outside, not a
  stray drag"), rendered in-site (`principles.html` accordion + the overview §-map). It reads wider than the
  original §15-neighbour idea: it covers modal/drawer *and* popover, and records the dropdown exception.
- **Popover** now uses the press+release guard (`assets/app.js`): an open `.wb-popover` closes only when
  neither the `pointerdown` nor the `pointerup` is inside it. **Dropdown deliberately kept on bare `click`**
  (click-to-select-and-close, no drag-interactive content) — documented as an exception in §27 + the catalog.
- The docs site never ships, but `assets/app.js` **is** copied verbatim into live sites; any holder of
  a copy needs the same change. (See `CHANGELOG.md` *Unreleased* → Fixed.)

---

## Scroll indicator — resolved 2026-08-10

> The themed scrollbar is now a **page-wide default declared once** (CSS section 27, on `:root` + `*`), with
> `.wb-scrollbars--os` as the escape hatch. Durable homes: `CHANGELOG.md` *Unreleased (v0.7-dev)*,
> `README.md` **T6** + the `#/decisions` mirror, `design-principles.md` §13, the catalog *Scroll areas*
> section, `SKILL.md`, and the `#/scroll` demo. Verified in Chrome 148: a scroller with **no** `wb-*` class
> inherits the theme in light + dark; `--os` returns `auto`. One fact worth keeping in mind while editing
> CSS section 27 — where `scrollbar-color`/`-width` applies, Chrome **ignores** that scroller's `::-webkit-scrollbar`
> rules, so the `::-webkit-*` half is a legacy-WebKit fallback, not a twin. Edit both halves.

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
"never build one"* — should become **T9** in `README.md` (T1–T8 are now taken — T7 = `.skill` payload, T8 =
adaptive architecture) and be mirrored on `pages/decisions.html`
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

Independent of the kit question, ordered by value against the flagship use (money data).

> **Items 1–6 were all resolved 2026-08-27** and deleted from this list per the rule at top. What they became,
> with their durable homes (all under `CHANGELOG.md` *Unreleased (v0.7-dev)*):
> 1. **Column sort** → `wb-th-sort` + `aria-sort` (CSS + docs `app.js` driver; catalog *Sort by column*; `#/tables`).
> 2. **Row selection + bulk actions** → `wb-table__check` + `wb-table-bulk` + `--wb-row-selected` (catalog *Row selection*).
> 3. **`@media print`** → CSS section 54; design-principles **§26**.
> 4. **Code block** → `.wb-code` (inline + `pre`), CSS section 55; new `#/code` page + catalog *Code*.
> 5. **Counter badge** → shared `.wb-badge` (+ `--dot`/`--float`/`--danger`), CSS section 56; on the Capsules/Badges page.
> 6. **a11y `forced-colors` + `prefers-contrast`** → CSS section 57; **RTL recorded as a deliberate non-goal** in design-principles **§19**.
>
> Items 7 (version drift) and 8 (stale positioning) were resolved earlier in `03b8a4c` (homes: `CHANGELOG.md`
> v0.6, the `--wb-version` token, `validate-sync.sh` CHECK 15 on `#/tooling`).

**Already recorded:** T3 (`.skill` packaging) is now **resolved** — a deterministic pipeline (see the landed
note at the top). T4 (no inlined manual `/wb-change`) remains *deferred*; T5 (no §18/coherence gate) remains
*chosen — keep it*. `carousel` / `scrollspy` / floating labels
stay skipped on purpose (`bootstrap-comparison.md`).

---

## 7. When you pick this up

Everything in §6 and the Backdrop tail is now **shipped** (v0.7-dev — see `CHANGELOG.md`). The **one item left
open is the React kit question (§0–§5)** — a *decision first, code second*.

- It was **deliberately kept open** (owner's call, 2026-08-27): don't record T9 or write any `.tsx` yet — the
  §0–§5 analysis stays here as the live brief.
- When it *is* decided, record it as **T9** in `README.md` + mirror on `#/decisions` (`validate-sync.sh`
  CHECK 13 enforces the mirror), whichever way it goes — *including "never build one."* Per §1, the recorded
  silence is the bug, not the absence of a kit. (§5/§7 earlier said "T6"; T6 is taken by the scrollbar
  decision, so the kit is **T9** as §1 states.)
- If you build one, §4 is a hard prerequisite: ship the kit↔CSS check in the *same* change.

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

**Part 1 — the skill — is the product.** Parts 2 and 3 are *instrumentation*: the docs site and its source
exist only to review, dogfood, and improve the skill, and never ship. Every change is judged by whether it
leaves the shipped skill better and coherent.

| Part | Where | What it does |
|---|---|---|
| **1 · Skill** (for an AI) | `web-builder/SKILL.md` + `web-builder/references/` | Instructions + a component catalog an AI reads so it builds web UI from `wb-*` parts instead of inventing styles. |
| **2 · Docs** (for a human) | `web-builder/assets/` | A living component gallery — **66 pages**, light/dark, browsable (incl. `#/principles` rendering §1–25 in full, `#/templates` for the seven page templates + the page-review rubric, `#/architecture` for the Level 0/1/2 gate + synthesis, `#/tooling` for serve/verify/hooks/packaging, and `#/decisions` mirroring the trade-offs). Ships `web-builder.css` + `templates/`. |
| **3 · Code docs** (inside the docs) | every page + the source | Each page shows its copy-paste markup; the source (`web-builder.css`, `app.js`, `docs.css`) is heavily commented. |

### What each part contains

**1 · Skill** — the AI-facing knowledge:
- `SKILL.md` — entry point: the one rule ("don't invent styling"), the colour ladder, current scope, house conventions.
- `references/components-catalog.md` — "building X → use Y, here's the snippet" lookup + a **Composing a page** section (app-shell skeleton + the recipe→template table) for whole screens (**start here** for a build task; for a whole screen it sends you to a template).
- `references/design-principles.md` — the colour ladder, token discipline, dogfooding, layout stance, and every convention, numbered.
- `references/page-review.md` — the **nine-gate self-review** an AI runs on a finished page before delivering it; four gates are measurable with a console snippet (invented classes · colour ladder · overflow · a wrapping navbar). The other end of the "start from a template" rule.
- `references/integration.md` — how the CSS + tokens + optional React wrappers plug into any app's stack (React/Vite/Tailwind/shadcn/next-themes as the worked example).
- `references/bootstrap-comparison.md` — coverage vs Bootstrap 5.3 (what we have / skip / do differently), for "do we need component X?" calls.
- `references/docs-site.md` — how the docs **site** is built (SPA shell + `app.js` `SECTIONS`/router + `docs.css` chrome, the page-grammar skeleton, the Config/search/dual-preview features), so the skill can rebuild the docs. Docs are instrumentation and **never ship**.

**2 · Docs** — the living gallery in `web-builder/assets/`:
- `web-builder.css` — **the library** (design tokens + all `wb-*` components). **The only file that ships to the app at runtime.**
- `templates/<screen>.html` — **seven finished screens** (dashboard · list · form · detail · settings · auth · landing) on the shipped scaffold. Part of the skill, but *source you copy*, not something an app links — so the runtime payload stays one CSS file.
- `index.html` + `app.js` + `docs.css` — the docs **shell** (hash router, sidebar tree, theme toggle, config drawer). Docs chrome — **never ships**.
- `pages/<id>.html` — one small, markup-only page per component/foundation (one per `SECTIONS` route — kept in parity; see the self-check below).
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

## Two jobs: beautiful UI, and the right amount of architecture

The skill is a **UI builder first** — assemble approved `wb-*` parts so a build looks consistent and takes few
tokens. On top of that it now helps an agent **choose how the project itself is organized**, as an *adaptive*
capability — never mandatory ceremony. The full logic is in `web-builder/SKILL.md` (the router) and
`web-builder/references/project-architecture.md` (the hub); the summary:

### The one-file fast path (the default)
Most builds are small. **Default to a single `index.html`** (markup + one `<link>` to `web-builder.css` + a
little inline JS) when it's one page, ≲ 1,000 lines / 100 KB, ≤ 3 small behaviours, and has no
backend/auth/db, no router/build, no independently-updated content collection, and isn't maintained
feature-by-feature across sessions. At this level there is **no `.agent/`, no architecture docs, no ADRs, no
folders "for later."** Architecture you don't need is friction, not future-proofing. (The line/KB numbers are
a *heuristic, not a split law* — a cohesive 10,000-line file can be right; you evaluate, you don't auto-split.)

### Three complexity levels
- **Level 0 — one-file fast path.** The default above.
- **Level 1 — compact long-lived.** Small but maintained regularly: a small tree following the framework's
  conventions + one short `AGENTS.md` as the discovery map.
- **Level 2 — structured/complex.** Many independently-changing units, real API/state/persistence, or a clear
  handoff need: `AGENTS.md` + `.agent/` + `docs/architecture` / ADRs **as needed** (nothing is mandatory just
  because it's Level 2). Pick the **smallest level that solves the real need**.

### Constraint-based synthesis (no universal tree)
There is **no** canonical folder layout to reach for. An architecture is synthesized from the forces —
requirements, responsibilities, units of change, source-of-truth, framework conventions, the existing repo,
runtime constraints, agent discoverability, verification. What's standardized is the **semantic discovery
contract** (what/where/how, captured in `AGENTS.md`), not the physical tree. `site-profiles.md` gives priors
per site type (learning sites are the deepest — `learning-sites.md`), but a profile is a starting point, not a
preset, and synthesizing a new tree is normal.

### Invocation boundary
Reach for Web Builder for a new site/page, significant UI, architecture design/refactor, a screen flow or
large capability, UI with no local equivalent, a shell/design-system change, a monolith refactor, a suspected
**upstream** bug, or packaging/releasing the skill. **Routine work does not need it** — content/copy edits,
data/lesson updates, small local fixes, reusing a local component, resuming a handoff. Inside an existing
project, read its `AGENTS.md` first and reuse local solutions.

### Two lifecycles (upstream ⇄ downstream)
- **Upstream** = this repo, the source of truth for the skill, the design system, the architecture knowledge,
  the protocols, and the packaging/release tooling.
- **Downstream** = a site the skill builds. It picks its own level, keeps its own `AGENTS.md`, and lets a
  *routine* agent continue **without** loading Web Builder. When a downstream finding looks reusable or like a
  library bug, it's **classified** (`problem-routing.md`) and, if genuinely upstream, **reported** (never
  auto-patched) via a `WEB-BUILDER UPSTREAM REQUIRED` block → intake → a skill change → verify → package →
  reinstall. That loop is how the skill compounds.

### Repository source-of-truth map & commands
`AGENTS.md` is the agent entrypoint (map + commands). The canonical sources: components →
`components-catalog.md`; design rules → `design-principles.md`; nav/routes → `app.js` `SECTIONS`; version →
`--wb-version` in `web-builder.css`; what ships in the `.skill` → `scripts/skill-manifest.txt`; trade-offs →
the `T#` list below. Core commands (all agent-agnostic, runnable outside Claude):

```bash
bash scripts/verify.sh            # all deterministic checks (docs site + skill + architecture/forward-tests)
bash tests/forward-tests.sh       # the architecture forward tests on their own
bash scripts/release-skill.sh     # verify → package (deterministic) → verify-package (parity + stale + checksum)
bash scripts/install-skill.sh     # dry-run by default; --target DIR / --apply (an explicit act)
```

---

## Adding a primitive component (and keeping everything in sync)

A component is **one change across seven places** — if they drift, the skill starts lying to the next AI.

1. **CSS** — add a numbered section to `web-builder/assets/web-builder.css`: `.wb-<name>` (+ `__element`,
   `--modifier`). Build from **tokens**, never raw hex/px (hairline = `var(--wb-bw)`, pill =
   `var(--wb-radius-pill)`; see design-principles §18). Dark mode is automatic if you use `--wb-*`.
2. **Demo page** — create `web-builder/assets/pages/<id>.html`. Markup only (no `<html>`/shell). Copy the
   `wb-page-head` → `wb-section` → `wb-block` → `demo` / `demo__code` structure from an existing page, and
   use the library's own layout utilities (`.wb-cluster` / `.wb-stack` / `.wb-grid`), not inline flex.
   (Everything there except `demo*` is a **shipped** primitive — the docs run on the same page scaffold an
   app gets, so a page that looks right here looks right in a build.)
3. **Nav** — add `{ id: "<id>", label: "…" }` to the right **section** in the `SECTIONS` model in
   `web-builder/assets/app.js` (the single source of truth for the section switcher, the sidebar **and** the
   router). Three sections: **Design** (foundations) · **Components** · **Project & skill** (meta). A new
   *component* goes under the right intent `group` in the `components` section (10, in order):
   *Layout & utilities · Actions · Inputs · Pickers · Data display · Feedback · Overlays · Navigation
   · Disclosure · Structure* (charts lives under *Data display*, not its own group); a foundation/meta page
   goes in the flat `items` of the `design` / `project` section. Docs **chrome is English** (nav, topbar,
   Tweak panel — and a page's `wb-eyebrow`, which echoes its group label); page bodies and every component's
   sample copy stay Vietnamese-first (§20).
4. **Catalog** — add a section + a "Quick decision guide" row to `web-builder/references/components-catalog.md`.
5. **Skill** — update `web-builder/SKILL.md`, the AI's first read: add the component to the right per-intent
   scope group (*Foundation · … · Structure*), or note a new capability on a family already listed. Miss it and
   the next AI trusts SKILL.md's scope and assumes the part isn't there.
6. **Templates** — if the change touches a whole-screen pattern (the shell, the page rhythm, a part every
   screen carries), update the affected `web-builder/assets/templates/<screen>.html`. Adding a **new page
   recipe** means adding both a row to the catalog's *Named recipes* table **and** its template file —
   `validate-sync.sh` CHECK 14 locks the two together in both directions.
7. **If relevant** — a new convention → `design-principles.md`; needs an app behaviour engine (Radix,
   dnd-kit, sonner…) → a row in `integration.md`; a Bootstrap-coverage note → `bootstrap-comparison.md`;
   a **user-visible** new/changed part → an entry in `web-builder/CHANGELOG.md` (else the shipped changelog rots).

Then verify route ↔ page parity (they must match, no orphans):

```bash
diff <(grep -oE 'id: "[a-z0-9-]+"' web-builder/assets/app.js | sed -E 's/id: "(.*)"/\1/' | sort -u) \
     <(ls web-builder/assets/pages | sed 's/\.html$//' | sort -u) && echo "OK: routes == pages"
```

### Verify (the guardrails)

One command runs every deterministic check — you rarely need it by hand (the commit/push gate runs it for you),
but here it is:

```bash
bash scripts/verify.sh    # exit 0 = OK · exit 2 + a "BLOCK ·" reason = drift to fix
```

The **agent-agnostic core** lives at `scripts/verify.sh` so any harness (CI, a bare shell) runs it; the
`.claude/hooks/validate-sync.sh` you may remember is now a thin **adapter** that just forwards to it (T3).

It validates **all three halves**. *Docs site:* routes == pages · pages are markup-only (no `<style>`) ·
`app.js` parses. *Shipped skill:* `SKILL.md` frontmatter + trigger length **+ stays < 500 lines** · `SKILL.md`
scope names every component `group` · every `references/*.md` exists · the catalog never documents a `wb-*`
class the CSS lacks · `web-builder.css` braces balance · every **"§N"** cited anywhere resolves to a real
design principle, the overview page indexes them all, **and** `pages/principles.html` renders every §N in
full · every README trade-off **`T#`** is mirrored on `pages/decisions.html` (docs stay self-contained — §23).
*Architecture layer:* the seven architecture references exist · every core script parses · the ship manifest
resolves · the **forward tests** pass (`tests/forward-tests.sh` — the Level 0/1/2 gate and local/upstream
routing can't silently regress). A failing check prints a `BLOCK ·` line saying exactly what drifted.

Packaging has its own trio (run by `scripts/release-skill.sh`): `package-skill.sh` builds `web-builder.skill`
**deterministically** from `scripts/skill-manifest.txt`, and `verify-package.sh` checks two-way manifest
parity, **detects a stale artifact** (packaged content must match source), and reports version + checksum.

### Prompting Claude in this repo — do I invoke a skill?

**No manual invocation needed.** When you ask Claude (Code) to add or change a component, `/wb-change`
**auto-triggers** because your prompt matches its description ("thêm component", "add primitive", "đổi token",
"restructure", "sửa wb-*"…). You *can* also type `/wb-change` explicitly, but you don't have to. Everything
around it is automatic too:

- `CLAUDE.md` is loaded **every turn**, so the AI always knows the rules even without any skill.
- Two `.claude/` **hooks** run on their own: a nudge injecting the 6-place checklist the moment `web-builder.css`
  is edited, and a commit/push **gate** that runs `scripts/verify.sh` (via the adapter) and blocks on drift.

So the flow is: *describe the change in plain language* → the skill + hooks engage → the 6-place sync + guardrails
follow. (Just "use the library to build UI" does **not** trigger `/wb-change` — that's the separate `web-builder`
skill; `/wb-change` is only for changing the library itself.)

**The workflow family (non-overlapping triggers).** `/wb-change` is one of four repo workflows, each
auto-triggering on its own description — you rarely type them:

| Workflow | For |
|---|---|
| `/wb-change` | Add/modify a `wb-*` component or token; restructure the library (the 6-place cascade). |
| `/wb-architect` | Bootstrap a site, design/refactor architecture, migrate a monolith (the project's shape). |
| `/wb-intake` | Classify a downstream finding as local vs upstream and route it. |
| `/wb-release` | Validate, package, verify, and prepare install of the `web-builder.skill` artifact. |

Their agent-agnostic logic lives in `scripts/`; the `.claude/skills/` files are thin adapters that orchestrate
and point at the references. Building UI with the library needs no workflow — that's the `web-builder` skill.

## Conventions (the short list)

White-black-grey first; colour only for real status/meaning; **tokens over magic numbers**; the docs are
**dogfooded** (pages are built from `wb-*` primitives; `docs.css` holds only chrome with no library
equivalent); on dark, shadows flip to a soft **light** lift; a dismiss **×** sits **top-right**; **no
left-accent bars**; icons come from an icon font (never hand-drawn). Layout stays a small flex/grid utility
set — **not** a Bootstrap-style 12-column foundation — a *minimalism* choice, and self-sufficient (no
Tailwind required). Full, numbered rules (§1–§25, human-readable — also rendered in full on the docs site at
`#/principles`):
[`web-builder/references/design-principles.md`](web-builder/references/design-principles.md) — this is the
canonical, numbered home of the design thinking (when a note references "§N", it means a rule there).

## Deliberate trade-offs & deferred decisions

Settled calls live here. Questions still **open** — including whether to build a React kit — live in
[`HANDOFF.md`](HANDOFF.md), a working note that empties itself as each item lands here (or in the changelog).

Recorded on purpose, so a future reader (or AI) understands these were **chosen**, not overlooked — don't
"rediscover" them as bugs. Revisit only if the stated reason stops holding. Each is tagged **T#** and mirrored
in full on the docs site at `#/decisions`; `validate-sync.sh` **CHECK 13** blocks a commit if a `T#` defined
here isn't rendered there, so this list can't silently go missing from the site again (§23 self-contained docs).

- **T1 · The shipped CSS is one ~176 KB file, no tree-shaking.** *Kept.* Zero-build, one-`<link>` drop-in is the
  whole point; per-consumer size is the fair price. A consumer who cares can delete unused numbered sections
  (each is self-contained) or minify. Splitting into modules would reintroduce the build step the library
  exists to avoid.
- **T2 · The CSS `@import`s Material Symbols from Google Fonts (one external request).** *Kept, documented.* Docs
  and most apps are online-first; a self-host path for offline/air-gapped/privacy is written up in
  `integration.md` ("Offline / privacy"). Not removed by default so the drop-in stays literally one line.
- **T3 · `web-builder.skill` packaging — now a deterministic pipeline (was: manual, deferred).** *Resolved.*
  The former hand-built zip is replaced by `scripts/package-skill.sh` (a deterministic build from an explicit
  manifest, `scripts/skill-manifest.txt`), `scripts/verify-package.sh` (two-way parity + stale detection +
  checksum), and `scripts/release-skill.sh` (verify → package → verify). The source (`web-builder/`) is still
  the truth and the `.skill` stays gitignored + generated on demand — but it can no longer drift silently (the
  old artifact was stale: it over-shipped the docs app and lagged 21 source files).
- **T4 · `CLAUDE.md` doesn't inline a manual `/wb-change` step-by-step for non–Claude-Code humans.**
  *Deferred (minor).* The "Adding a primitive" section above, the trigger note, and the docs-site `#/tooling`
  + overview workflow pages already lay out the manual flow, the hooks, and the verify checks for a human.
- **T5 · A read-only locator (`.claude/tools/wb.sh`) exists, but no automated §18 / coherence *gate*.**
  *Chosen.* `wb locate <class>` does `/wb-change` step 1's "grep → `Read` offset/limit clusters + blast-radius"
  dance in shell, so discovery (and everyday dogfooding) costs fewer tokens. It only *prints* the `Read`
  commands — it never edits or judges, so it cannot block or mislead. We deliberately did **not** turn §18
  (token-over-magic-number) or a "6-place coherence" completeness check into a commit gate: tested against the
  real CSS, both were far too noisy to gate on. §18 raw-hex: **26** hits under a loose rule, **8** under a
  value-match rule — almost all legitimate (mask-alpha `#000`/`#0000`, the colour-picker hue wheel,
  `var(--x, #hex)` fallbacks, chart-schemes whose literal value coincidentally equals a token). "Class used but
  undefined": **81** hits, ~all false (design tokens like `--wb-border`, prose like `/wb-change`, BEM examples
  inside `<code>`). Telling apart a magic-number from a necessary raw value needs *semantic* judgment; a noisy
  gate only trains you to ignore it. Trade-off: §18 and 6-place coherence stay **model/human eyeball** checks
  (`/wb-change` steps 8–9), not mechanical guarantees — revisit only if raw-hex abuse actually appears, or if a
  low-noise base-vs-modifier split ever makes a coherence *advisory* (never a gate) worth its upkeep.
- **T6 · CSS section 27 styles scrollbars page-wide from `:root` + `*` — the one place the CSS reaches outside the
  `wb-*` namespace.** *Chosen.* Everywhere else the prefix is a promise: drop the file in and nothing you didn't
  opt into changes. Scrollbars are the deliberate exception, because the opt-in version failed in practice —
  the theming was a fixed class list, so any scroller outside it (a hand-written `overflow:auto` div, a
  third-party widget) showed a bright OS bar right next to a wb surface, and the fix was to remember
  `.wb-scrollbars` on every one of them. A scrollbar is chrome, not content: getting it wrong is visible on
  every screen, and "declare it once" is the only version that stays true as a page grows. The escape hatch is
  `.wb-scrollbars--os` (an element **and** its subtree back to the native bar). Cost accepted: an app that
  wanted the OS bar on most of the page now opts *out* instead of in. Revisit if a real integration needs the
  native bar as the default.
- **T7 · The `.skill` ships the agent payload only — the docs SPA shell is excluded.** *Chosen.* The manifest
  (`scripts/skill-manifest.txt`) ships `SKILL.md` + `CHANGELOG.md` + `references/` + `web-builder.css` +
  `templates/` + `pages/` (the exact markup `SKILL.md` tells an agent to open). It **omits** `index.html` /
  `app.js` / `docs.css` / `serve.py`: the docs *app* renders the human gallery and is repository-only
  instrumentation — an agent building a site never needs it (interactive behaviour is wired via an external
  engine per `integration.md`, never by copying `app.js`). Decided by the *real dependency of the installed
  skill*, enforced two-ways by `verify-package.sh`. Cost accepted: an installed skill can't self-render its
  gallery — browse the docs from the repo. Revisit if an install target ever needs the rendered site inline.
- **T8 · Architecture is an adaptive capability, not a standardized project tree.** *Chosen.* The skill does
  **not** impose a canonical folder layout or mandate `.agent/`. Small builds take the one-file fast path
  (Level 0); structure appears only when the complexity gate says a site is large/long-lived, and is then
  *synthesized* from the project's constraints — what's standardized is the semantic discovery contract in
  `AGENTS.md`, not the physical tree (`references/project-architecture.md`). Chosen over a fixed scaffold
  because a universal tree becomes ceremony on the small builds that dominate real use; the trade-off is that
  there's no single "correct" layout to check against — the quality bar is discoverability + verification, not
  tree conformance. Revisit only if a concrete site type proves it needs a locked structure.

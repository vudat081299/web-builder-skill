# Học Tài Chính — agent guide

**What this is.** A long-lived learning site: many lessons, per-lesson quizzes, and saved progress.
Complexity level: **2** (many independently-updated content units + interactions + persistence + ongoing
maintenance — see `project-architecture.md` in the web-builder skill).

## Where things live
- UI / shell: `index.html` + `app.js` (built with the web-builder design system — reuse `wb-*`; no hand-rolled CSS).
- Content / source of truth: `content/manifest.json` (lesson order + metadata) and `content/lessons/*.html`.
  **Adding a lesson = one manifest entry + one file. Nothing else.**
- Behaviour / features: `features/quiz.js` (scans lessons for quiz hooks — the only interaction module today).
- State / persistence: `store/progress.js` (the ONLY place that touches localStorage; versioned for migration).

## Run & verify
- Dev: `python3 -m http.server 8080`  → open http://localhost:8080
- Verify: open a lesson, complete a quiz, reload → progress persists; no console errors.

## Conventions
- Reuse the design system's `wb-*` parts; styling comes from `web-builder.css` (one `<link>`).
- Copy is Vietnamese-first (labels are data). One number/date locale per screen.

## Decisions & state
- Durable decisions: `.agent/decisions/` (ADRs — read before re-litigating a settled choice).
- Handoff / active work: `.agent/handoff.md` (resume snapshot).

## Web Builder boundary
- Routine work here does **NOT** need Web Builder: adding/editing a lesson, fixing copy, updating the
  manifest, small local bug fixes, reusing an existing `wb-*` part.
- Call Web Builder back for: a new screen flow, a UI part with no local equivalent, changing the shell /
  layout / design system, a major refactor, or a bug that reproduces on the **stock** design system
  (see `problem-routing.md` — that's an upstream report, not a local fix).

## Selected / omitted capabilities
- In: static shell · content manifest · one interaction module (quiz) · local persistence.
- Out (on purpose): backend/auth/sync — progress is local only. Add a sync layer *behind* `store/progress.js`
  when accounts are needed (the adapter is why that stays cheap).
- Split/restructure when: a second interaction type appears (add `features/<type>.js`), or a lesson file
  starts mixing unrelated topics.
</content>

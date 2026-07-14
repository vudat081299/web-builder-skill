---
name: cashy-ui
description: >-
  Bộ component + design system cho web quản lý tài chính cá nhân (dự án cashy). LUÔN dùng
  skill này khi build hoặc sửa BẤT KỲ giao diện/UI nào cho cashy hay app tài chính cá nhân —
  thay vì tự thiết kế lại từ đầu (tốn token và lệch phong cách). Cung cấp: design tokens
  (ưu tiên trắng-đen-xám, có dark mode), capsule/badge/tag trạng thái, và bảng (table) đẹp
  cho dữ liệu tiền (giao dịch, số dư, ngân sách, công nợ, thu/chi). Trigger: "build trang
  cashy", "thêm/làm component", "làm giao diện", "làm UI", "thiết kế bảng", "làm table",
  "badge/capsule/tag trạng thái", "card số dư/thu chi", "dashboard tài chính", "màn hình
  giao dịch", "màn hình công nợ", "build a cashy page", "financial table", "finance
  dashboard UI", "transaction list UI", "component library". KHÔNG dùng cho logic
  backend/tính toán không liên quan giao diện, hay project không phải tài chính cá nhân.
---

# Cashy UI

A reusable component library + design system for **cashy**, a personal-finance web app.
Its reason to exist: designing UI from scratch every time is slow and burns tokens because
it triggers round after round of "fix this colour / this padding / this shape." This skill
removes that loop — the visual decisions are **already made and approved** and captured as
tokens, ready-made components, and copy-paste snippets. Your job is to **assemble approved
parts**, so the user reviews *content and layout*, not aesthetics.

## The one rule that saves tokens

**Do not invent styling.** Before writing any UI for cashy:

1. Open `assets/index.html` (the living docs) or read `references/components-catalog.md`
   to find the component that fits.
2. Copy its snippet, swap in real data. Use `cash-*` classes and tokens — never hardcode
   colours, paddings, or radii.
3. If nothing fits, build the new piece **from existing tokens in the existing spirit**
   (see `references/design-principles.md`), add it to `cashy-ui.css` + a demo in
   `index.html`, and record it in the catalog. Then reuse it forever.

If you find yourself picking a hex value or a pixel padding by hand, stop — there is
almost certainly a token or class for it.

## What's in the box

| File | What it is | Read when |
|---|---|---|
| `assets/cashy-ui.css` | The library: design tokens + components (self-contained, no build) | You need class names / token names, or are adding a component |
| `assets/index.html` | Living docs — every component rendered, with light/dark toggle and copy-paste code | The user wants to *see* the options; you want the exact markup |
| `references/components-catalog.md` | "Building X → use Y, here's the snippet" lookup | **Start here** for any build task |
| `references/design-principles.md` | The colour ladder, neutral shadow rule, number/typography rules | Building something new or making an aesthetic call |
| `references/cashy-integration.md` | How the CSS + tokens + React wrappers plug into cashy's React/Vite/Tailwind/shadcn/next-themes | Wiring the library into the actual cashy repo |

## The colour ladder (summary — full version in design-principles.md)

Spend colour, don't sprinkle it. Lowest tier that does the job:

1. **white / black / grey** — the default for nearly everything.
2. **bright solid colour** — only for unmistakable status (paid = green, overdue / bad
   debt = red, due-soon = amber, info = blue).
3. **bright colour + low opacity (soft)** — the calm version of tier 2; default for status
   capsules and subtle row tints.

Classification (a category/method tag) is **not** status → keep it neutral grey. Only real
status earns colour.

## Current scope

**v1 ships:** capsules/badges/tags and tables (basic, transactions, striped/compact,
bordered, sticky, debt/receivables with meaningful colour). Coming next: buttons, stat/KPI
cards, forms, navigation, modals, toasts, charts. When asked for one of those, build it in
the same system and add it to the library rather than doing a one-off.

## Working with the user

The user iterates visually and prefers to review in the browser. To show the current
library, serve the assets folder and open it, e.g.:

```bash
cd cashy-ui/assets && python3 -m http.server 8777   # then open http://localhost:8777/index.html
```

Default the docs preview to the look the user prefers judging first: **light mode,
white-black-grey**. Colour and dark mode are there, but neutral-first is the house style.
When the user gives feedback, change the **token or component once** so every screen
benefits — never patch a single page.

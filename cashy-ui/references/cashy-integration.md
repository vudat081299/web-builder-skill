# Using Cashy UI inside the `cashy` app

cashy is **React 19 + Vite + TypeScript + Tailwind 3.4 + shadcn/ui (Radix) + CVA +
next-themes**. Cashy UI is deliberately built to sit *alongside* that stack, not
replace it:

- **shadcn/Radix** keeps doing what it's good at: interactive behaviour + accessibility
  (Dialog, DropdownMenu, Select, Popover, Tabs, Toast…).
- **Cashy UI** owns the **visual language** for finance data — tables, capsules, cards,
  numbers — so those look identical everywhere and don't get re-designed each page.
- **Tailwind utilities** stay available for one-off layout (flex/grid/gap/spacing).

They don't fight: Cashy UI classes are all `cash-`-prefixed, so no collision.

---

## Step 1 — Add the stylesheet (the only required step)

Copy `assets/cashy-ui.css` into cashy, e.g. `src/styles/cashy-ui.css`, and import it
**after** Tailwind so its component classes win over utility resets:

```ts
// src/main.tsx
import "./index.css";          // Tailwind base/components/utilities
import "./styles/cashy-ui.css"; // Cashy UI tokens + components
```

That's enough to use every `cash-*` class from the catalog in any `.tsx`.

## Step 2 — Dark mode already lines up

next-themes toggles the `.dark` class on `<html>` (its default `attribute="class"`),
and Cashy UI themes entirely off `.dark`. So the app's existing theme switch drives the
library automatically — nothing to wire. Just confirm the provider is class-based:

```tsx
<ThemeProvider attribute="class" defaultTheme="system" enableSystem>
```

## Step 3 (optional) — expose tokens to Tailwind

If you want Tailwind utilities that use the Cashy palette (e.g. `text-success`), map the
tokens in `tailwind.config.js`. Optional — the `cash-*` classes don't need it.

```js
// tailwind.config.js → theme.extend.colors
colors: {
  success: "var(--cash-success)",
  danger:  "var(--cash-danger)",
  warning: "var(--cash-warning)",
  info:    "var(--cash-info)",
}
```

---

## React wrappers (recommended, using cashy's own CVA + `cn`)

Plain HTML from the catalog works directly in JSX (`class` → `className`). But for
ergonomics, wrap the two v1 components with `class-variance-authority` + `cn` (both
already in cashy). These are thin — they only pick `cash-*` classes.

```tsx
// src/components/ui/capsule.tsx
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "@/lib/utils"; // clsx + tailwind-merge (already present)

const capsule = cva("cash-cap", {
  variants: {
    tone: { neutral: "", success: "cash-cap--success", danger: "cash-cap--danger",
            warning: "cash-cap--warning", info: "cash-cap--info" },
    fill: { soft: "", solid: "cash-cap--solid", outline: "cash-cap--outline",
            elevated: "cash-cap--elevated" },
    size: { md: "", sm: "cash-cap--sm", lg: "cash-cap--lg" },
  },
  defaultVariants: { tone: "neutral", fill: "soft", size: "md" },
});

type CapsuleProps = React.HTMLAttributes<HTMLSpanElement> &
  VariantProps<typeof capsule> & { dot?: boolean };

export function Capsule({ tone, fill, size, dot, className, children, ...props }: CapsuleProps) {
  return (
    <span className={cn(capsule({ tone, fill, size }), className)} {...props}>
      {dot && <span className="cash-cap__dot" />}
      {children}
    </span>
  );
}
```

```tsx
// usage
<Capsule tone="success" dot>Đã trả</Capsule>
<Capsule tone="danger" fill="solid">Quá hạn</Capsule>
<Capsule>Ăn uống</Capsule>
```

Tables are usually clearer as plain JSX with the `cash-table` classes (map your data
with `.map`). A wrapper only pays off if you want a data-driven `columns`/`rows` API —
defer that until the visual language is locked.

---

## What to change in the cashy repo (your call — nothing is destructive)

**Do:**
- ✅ Add `src/styles/cashy-ui.css` + the import (Step 1). This is the whole integration.
- ✅ (Optional) add `capsule.tsx` above and use it for all status/category tags.

**Don't remove:**
- ❌ Keep shadcn/Radix + `sonner` + `vaul` + `cmdk` — they provide behaviour Cashy UI
  intentionally does not (focus trapping, portals, a11y). Cashy UI + shadcn are partners.
- ❌ Keep Recharts for charts (a charts module for Cashy UI can come later).

**Watch for overlap:**
- If cashy already has a shadcn `<Table>`, pick one source of truth for finance tables.
  Recommended: use the `cash-table` classes for the finance look (they're tuned for
  money data — tabular numbers, totals, row states). You can even apply `cash-table`
  classes to a shadcn Table's `<table>` if you want its structure + our styling.

When you're ready to integrate, tell me and I'll open a small PR-sized change against
cashy: add the stylesheet + import, add `capsule.tsx`, and convert one existing table as
a reference.

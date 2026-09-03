# apps/web

Next.js 16 (App Router) client for the booking-code product. A plain HTTP consumer of
`apps/api` — no server-side business logic, no direct Betway calls. Design and rationale:
[`docs/frontend.md`](../../docs/frontend.md), visual language: [`docs/design-system.md`](../../docs/design-system.md).

## Run

```bash
cp apps/web/.env.example apps/web/.env.local   # point API_URL at a running apps/api
npm run dev --workspace @booking-code/web      # http://localhost:3000 (Next picks 3001 if the API holds 3000)
```

The API must be running (`npm run dev` at the repo root) for reads and resolves to work; the
Decode form degrades gracefully when the "popular codes" fetch fails.

Or run the whole stack in containers — web + api + redis, wired together:

```bash
npm run docker:up     # web on http://localhost:3001, api on :3000
npm run docker:down
```

`Dockerfile` uses Next's `output: 'standalone'`. Production deployment is Vercel
(`docs/frontend.md` §9) — the image is for local end-to-end parity, not the deploy path.

## Scripts

```bash
npm run dev --workspace @booking-code/web
npm run build --workspace @booking-code/web
npm run lint --workspace @booking-code/web
npm run typecheck --workspace @booking-code/web
npm test --workspace @booking-code/web
```

## What's here so far

Basic setup plus the **Decode** screen wired end to end as the reference for the other two:

- `app/layout.tsx` — shell, `next/font` (Archivo + JetBrains Mono), dark-only
- `app/page.tsx` — Decode; server-fetches `popular` codes
- `app/actions.ts` — `resolveCode` Server Action (the only place `fetch` writes to the API)
- `components/ui/` — restyled primitives (`button`, `input`, `badge`, `card`, `alert`),
  `cva` variants over the design tokens — the design-system §4 layer, kept separate from
  feature components
- `components/` — feature composition only: `decode-form` (`useActionState`), `slip-card`,
  `popular-codes`
- `lib/api.ts` — the fetch wrapper; `lib/format.ts` — the display rules from design-system §6;
  `lib/cn.ts` — the `clsx` + `tailwind-merge` class helper
- `app/globals.css` — the design tokens, as CSS variables surfaced through the Tailwind theme
- `Dockerfile` — standalone production image, run via the root `docker-compose.yml`

Not built yet: `/create`, `/convert`, the shadcn/ui component layer, click-to-prefill on the
popular list.

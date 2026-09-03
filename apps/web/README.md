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

The **Decode** screen, complete — a port of `apps/mobile`'s `decode_screen.dart`: paste /
paste-from-clipboard / validate, the resolved slip (header, status, partial-slip notice,
selection rows, "show N more"), the copy / share / load-in-Betway footer (or "Rebuild with N
live legs" when legs are dead), the invalid-code and transport error states with their
recovery actions, a skeleton while resolving, and the popular-codes list with expand-in-place
tiles. `/create` and `/convert` are designed but not built (`/convert` has a placeholder so
Decode's "Rebuild" link has a target).

```
app/
  layout.tsx            shell + wordmark, next/font (Archivo + JetBrains Mono), dark-only
  [[...code]]/page.tsx  Decode — `/` is empty, `/<code>` server-resolves the slip
  actions.ts            loadPopular Server Action (paged read for "load more")
  not-found.tsx         branded 404
  convert/page.tsx      placeholder — reads the ?code= Decode passes over
components/
  ui/                   restyled primitives — cva variants over the tokens (design-system §4):
                        button, input, badge, card, alert, icon-button, skeleton,
                        dashed-border, modal (bottom sheet < 640px, centred dialog above)
  decode-screen.tsx     the client orchestrator (URL-driven + local UI state)
  code-input.tsx  slip-card.tsx  slip-header.tsx  selection-row.tsx  slip-skeleton.tsx
  slip-footer.tsx  share-dialog.tsx  popular-codes.tsx  popular-code-tile.tsx
lib/
  api.ts               the fetch wrapper + ApiRequestError
  resolve.ts           server-side decode → { slip } | { invalid } | { transport }
  format.ts            the display rules from design-system §6 (odds, kickoff, expiry, …)
  popular.ts           popular-list page size + page-merge (de-dupes by bookingCode)
  betway.ts            the pinned Betway host + share-text builder
  cn.ts                clsx + tailwind-merge
app/globals.css        the design tokens + motion, surfaced through the Tailwind theme
```

**The URL is the state.** `/<code>` is a shareable link — the route resolves the slip
server-side and renders it. Submitting, picking a popular code ("Decode this code"), and
"Decode another" are all `router.push`; one optional-catch-all route keeps `DecodeScreen`
mounted across code changes, so the popular-list pagination and the input survive. The
resolved code is filtered out of the popular list below to avoid a duplicate.

It pages through the `loadPopular` Server Action on "Load more" — driven by `hasMore`, never
`codes.length` (pages come back short; docs/backend-api.md §1). Motion is CSS only:
`animate-rise` on each result phase, a `grid-rows` 0fr→1fr expand on the tiles, and
`@starting-style` enter/exit on the modal — all under a `prefers-reduced-motion` guard.

Not built: the Decode / Create / Convert mode switch (design-system §4 — lands with the other
screens), `/create`, `/convert`, and click-a-popular-tile-to-auto-submit (it fills the input,
same as `apps/mobile`).

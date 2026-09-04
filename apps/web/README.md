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

All three screens — **Decode**, **Create**, **Convert** — ported from `apps/mobile`, plus the
mode tabs in the shell.

- **Decode** (`/`, `/<code>`) — paste / paste-from-clipboard / validate, the resolved slip
  (header, status, partial notice, rows, "show N more"), copy / share / load-in-Betway (or
  "Rebuild with N live legs" on dead legs), the invalid-code and transport error states, a
  skeleton while resolving, the paginated popular-codes list.
- **Create** (`/create`, `/create?sport=`) — sport selector, paginated fixture list, inline
  1X2 chips, the "more markets" sheet, the draft tray (legs, running total, remove, clear),
  one-pick-per-match enforcement, generate → the created-code recap, and the
  `outcomes_unavailable` / `conflicting_selections` / generic error states.
- **Convert** (`/convert`, `/convert?code=`) — load a code (the target of Decode's "Rebuild"
  link), the keep/drop checklist (dead legs auto-dropped), a live NOW→AFTER odds diff,
  convert → the reissued-code view with the before/after in its notice, and the `empty_slip`
  / `outcomes_unavailable` / `conflicting_selections` error states.

```
app/
  layout.tsx            fonts, wordmark, the Decode/Create/Convert mode tabs
  [[...code]]/page.tsx  Decode — `/` is empty, `/<code>` server-resolves the slip
  create/page.tsx       Create — `?sport=` picks the sport; sports + first events page here
  convert/page.tsx      Convert — `?code=` server-resolves the slip being converted
  actions.ts            client-triggered: loadPopular, loadEvents, loadEventMarkets,
                        generateCode, convert
  not-found.tsx / error.tsx
components/
  mode-tabs.tsx         the shell tab switch (usePathname)
  ui/                   restyled primitives — cva over the tokens (design-system §4):
                        button, input, badge, card, alert, icon-button, skeleton,
                        dashed-border, empty-state, modal (sheet < 640px, dialog above)
  decode-screen.tsx  code-input  slip-card/-header/-skeleton/-footer  selection-row
  share-dialog  popular-codes  popular-code-tile
  create/              create-screen + sport-selector, event-list, event-tile, outcome-chip,
                       draft-tray, market-picker-dialog, created-code
  convert/             convert-screen + convert-leg-row, diff-summary, convert-result-view
lib/
  api.ts               the fetch wrapper + ApiRequestError
  resolve.ts           server-side decode → { slip } | { invalid } | { transport }
  create.ts / convert.ts   server-side fetch + write → result unions
  draft.ts / convert-preview.ts   the two bits of pure client-side maths (draft toggle, diff)
  format.ts  popular.ts  betway.ts  cn.ts
app/globals.css        the design tokens + motion, surfaced through the Tailwind theme
```

**The URL is the state.** `/<code>` is a shareable decoded slip; `?sport=` / `?code=` select
the Create sport and the Convert code — all server-rendered. Load / Change / "another" are
navigations; Decode's optional-catch-all route keeps `DecodeScreen` mounted so its pagination
and input survive.

Reads a click triggers ("load more", "more markets") and the three writes (generate, convert)
go through Server Actions, each inside a `useTransition`. List paging is driven by `hasMore`,
never list length (pages come back short; docs/backend-api.md §1–2).

Motion is CSS only, keyed off React (`key` bumps replay an animation; no JS tween):
`animate-rise` on a screen's mount, each result phase, appended list rows, and a changed
odds figure; `animate-pop` on a check mark; `active:scale` press on buttons and chips; a
`grid-rows` 0fr→1fr expand on the popular tiles; `@starting-style` enter/exit on the modal.
All disabled under `prefers-reduced-motion`.

`apps/mobile` now matches this screen's flow — same pagination on the popular list, same
entrance/pop motion, popular codes kept on screen next to a resolved slip, and a popular
tile resolves the code rather than only filling the field.

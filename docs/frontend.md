# Frontend — Betway Nigeria Booking Code Product

`apps/web` — Next.js 16, App Router. A plain HTTP client of `apps/api` (the Express service);
no server-side business logic lives here, and no direct calls to Betway.

Researched against the current Next.js 16 docs (Next.js 16 shipped October 2025; this
document reflects the App Router as of Next.js 16.3, August 2026) — this is not a Next 13/14
cookbook copy-pasted from memory.

---

## 1. Stack

| | |
|---|---|
| Framework | Next.js 16, App Router, TypeScript |
| Bundler | Turbopack (default since 16 — no config needed) |
| Styling | Tailwind CSS + shadcn/ui, restyled to `docs/design-system.md` tokens |
| Forms / mutations | Server Actions + `useActionState` (React 19.2, bundled with Next 16) |
| Shared types | `packages/contracts` — imported, not redeclared (§4) |
| Testing | Vitest + React Testing Library |
| Deployment | Vercel |
| Node | 20.9+ (Next 16's hard minimum) |

`create-next-app@latest` now scaffolds App Router + TypeScript + Tailwind + ESLint by
default, so there's no bespoke setup step to document — the defaults are already this stack.

The visual language — colors, type, spacing, components, the slip anatomy — is
`docs/design-system.md`, shared with `apps/mobile` and already implemented there. shadcn/ui
supplies the primitives; every one is retinted to those tokens rather than shipped as its
default. Don't invent web-only colors or radii; a token missing here is missing in
`lib/design/` too, and gets added to both.

---

## 2. Rendering strategy

No blanket rule ("everything client" or "everything server") — each screen splits at the
point where interactivity actually starts.

| Screen | Server Component | Client Component |
|---|---|---|
| Decode (`/` and `/<code>`) | `popular codes` fetch; **the decode itself** — `/<code>` resolves the slip server-side so the URL is a shareable link | Code input, the paste/copy/share controls, the popular-list "load more" |
| Create (`/create`, `/create?sport=`) | `sports` + the first `events` page for the selected sport | Outcome picker, draft tray, live total-odds, "more markets" sheet; generate is a Server Action |
| Convert (`/convert`) | — (arrives with a code from Decode, or a fresh input) | Checkbox list, before/after diff, recompute on every toggle |

The rule of thumb: **fetch on the server, mutate on the client.** A page never ships a client
bundle just to make its first read — that read happens in a Server Component and is already
in the HTML. Anything the user clicks, types, or toggles is a Client Component, because that's
what the label is for.

**Decode resolves by navigation, not by Server Action.** §3 sketches `resolveCode` as a
`useActionState` action; the built version instead puts the code on the URL (`/<code>`, one
optional-catch-all route) and resolves it in that Server Component. The trade: a decoded slip
is now a link you can share, at the cost of the form's no-JS fallback. Submitting, picking a
popular code, and "decode another" are all `router.push`. `loadPopular` stays a Server Action
(a paged read the client triggers). Create and Convert keep the `useActionState` shape — they
are true mutations with nothing to put on a URL.

---

## 3. Data fetching

### Reads (Server Components → our Express API)

```tsx
// app/page.tsx
export default async function DecodePage() {
  const res = await fetch(`${process.env.API_URL}/api/booking-codes/popular`);
  const { codes } = await res.json();
  return <PopularCodes codes={codes} />; // hands off to a Client Component
}
```

**Deliberately no Next.js caching layer on top of this.** Next.js 16's Cache Components model
(`"use cache"`, opt-in via `cacheComponents: true` in `next.config.ts`) is not enabled here.
Two reasons, not one: first, our data is live odds — anything Next.js cached would just be a
second, harder-to-invalidate copy of what Redis already caches correctly on the API side (the
same duplicate-cache mistake ruled out for Postgres in `docs/backend.md`). Second, since
Next.js 15 a plain `fetch` is **already uncached by default** — this isn't fighting the
framework, it's the framework's own current default, left alone. Enabling Cache Components on
top would add `"use cache"` directives and Suspense-boundary requirements for a two-day build
with nothing that benefits from them. If a future version of this product wants static
marketing pages alongside the live tool, Cache Components is the first thing to reach for —
just not here.

Sibling reads within one page use `Promise.all`, not sequential `await`, so `sports` and
`events` fetch in parallel rather than one blocking the other. A read used by more than one
Server Component in the same request is wrapped in React's `cache()` so it fires once, not
once per caller.

### Mutations (Client Components → Server Actions → Express API)

Decode, Create, and Convert are all, at bottom, "submit something, get a slip back" — that's
a form, so it uses React 19's `useActionState`, not a hand-rolled `fetch` + `useState`:

```tsx
// app/actions.ts
'use server';

export async function resolveCode(_prev: unknown, formData: FormData) {
  const code = formData.get('code');
  const res = await fetch(`${process.env.API_URL}/api/booking-codes/resolve`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ code }),
  });
  if (!res.ok) return { error: (await res.json()).message };
  return { slip: await res.json() };
}
```

```tsx
// components/decode-form.tsx
'use client';
import { useActionState } from 'react';
import { resolveCode } from '@/app/actions';

export function DecodeForm() {
  const [state, formAction, isPending] = useActionState(resolveCode, {});
  return (
    <form action={formAction}>
      <input name="code" placeholder="BW + 8 characters" />
      <button disabled={isPending}>{isPending ? 'Resolving…' : 'Resolve'}</button>
      {state.error && <p role="alert">{state.error}</p>}
      {state.slip && <SlipCard slip={state.slip} />}
    </form>
  );
}
```

This gets pending state, error state, and progressive enhancement (the form still submits
without JS) for free, instead of reimplementing all three by hand. It's the idiomatic
Next.js/React 19 pattern for exactly this shape of interaction, not an incidental choice.

**What stays plain client state, not a Server Action:** Convert's checkbox toggling and
Create's running total recompute on every interaction and touch nothing on the server —
that's `useState`/`useReducer` in the client component, full stop. Only the final "Generate"
click is a Server Action call. Routing every checkbox click through the server would be a
bug, not a Next.js best practice.

---

## 4. Shared types

`packages/contracts` holds `Slip`, `Fixture`, `ApiError`, `ConvertResult` — the same types
defined once in `docs/backend-api.md` §0. The web app imports them:

```ts
import type { Slip } from '@booking-code/contracts';
```

No response shape is retyped by hand in `apps/web`. If the API's DTO changes, the type error
surfaces at the web app's build, not at runtime in front of a reviewer.

---

## 5. Project structure

```
app/
  layout.tsx            fonts, wordmark, the Decode/Create/Convert mode tabs (design-system §4)
  [[...code]]/page.tsx  Decode — serves `/` (empty) and `/<code>` (resolved slip)
  create/page.tsx       Create — `?sport=` selects the sport; sports + first events page here
  convert/page.tsx      placeholder
  actions.ts            Server Actions the client triggers: loadPopular, loadEvents,
                        loadEventMarkets, generateCode
  error.tsx / not-found.tsx
components/
  mode-tabs.tsx         the shell tab switch (usePathname)
  slip-card.tsx         shared (+ slip-header, selection-row, slip-skeleton, slip-footer)
  decode-screen.tsx
  create/               create-screen + sport-selector, event-list, event-tile, outcome-chip,
                        draft-tray, market-picker-dialog, created-code
  ui/                   restyled shadcn-style primitives (§1)
lib/
  api.ts                thin fetch wrapper: base URL, JSON headers, error unwrapping
  resolve.ts            server-side decode → a UI-ready result union
  create.ts             server-side sports/events/markets fetch + createCode → result unions
  draft.ts              the DraftPick shape + toggle/total helpers (the one UI-only type)
```

No `middleware.ts` / `proxy.ts` — nothing here needs request interception (no auth, no
redirects, no header rewriting), so skipping it is a fact about the app, not an omission.

---

## 6. Loading & error states

`loading.js` per route covers whole-page navigation loading (the Suspense boundary Next.js
wraps around `page.tsx` automatically). For the more interesting partial states — a
resolved-but-partially-stale slip, an in-flight Convert recompute — the loading UI sits
inside the component itself, driven by `isPending` from `useActionState`/`useFormStatus`,
not by `loading.js`, because that's route-level and these are not.

`error.tsx` per route catches render errors; API errors (`ApiError` from a non-2xx response)
are handled explicitly in the Server Action and rendered as UI state, not thrown — a
`404 invalid_code` is an expected outcome of this app, not an exceptional one, and shouldn't
hit an error boundary.

---

## 7. Environment variables

```
API_URL              server-side base URL for the Express API (Server Components, Server Actions)
NEXT_PUBLIC_API_URL   same value, exposed to the client — only needed if a Client Component
                       ever calls the API directly instead of through a Server Action
```

In this app every mutation goes through a Server Action, so `NEXT_PUBLIC_API_URL` may not
even be needed — worth confirming once Create/Convert are built rather than adding it
speculatively. `.env.example` committed with both keys empty; real values in Vercel's
project settings.

---

## 8. Testing

Vitest + React Testing Library for components with real logic: the Convert checkbox/odds
recompute, the Create tray add/remove/total. Server Actions are tested by calling the
exported function directly with a `FormData` against `apps/api`'s fixture provider — no
browser, no live Betway dependency, consistent with how `apps/api` is tested (see
`docs/backend.md` §7).

---

## 9. Deployment

Vercel, `apps/web` as the project root (monorepo — set Root Directory in project settings).
Turbopack is the default build in Next.js 16, nothing to configure. `API_URL` points at
whichever host runs `apps/api` (Railway/Fly — see `docs/backend.md` §8); if both services end
up on the same platform's private network, `API_URL` can become an internal address instead
of a public one — a later optimization, not a day-one requirement.

`apps/web/Dockerfile` (Next's `output: 'standalone'`) and a `web` service in the repo's
`docker-compose.yml` exist only so `npm run docker:up` can bring web + api + redis up
together for a local end-to-end demo. Vercel does not use them.

---

## 10. Explicitly not used, and why

- **Cache Components / `"use cache"`** — covered in §3. The right tool for static content
  this app doesn't have.
- **ISR / `revalidate`** — same reasoning: there's nothing here that's "static, but
  occasionally stale is fine." Odds are either fresh (Redis TTL) or explicitly marked
  inactive; a stale-tolerant static page would hide that distinction instead of showing it.
- **A client-side data library (SWR/TanStack Query)** — the Next.js docs list these as an
  option for Client Component fetching, but every read in this app already happens in a
  Server Component, and every write goes through a Server Action. There's no client-side
  fetch left for a query library to manage.
- **`next/image` remote patterns / team badge icons** — no image-heavy UI in scope; if added
  later, `images.remotePatterns` (not the deprecated `images.domains`) is the Next 16 way in.
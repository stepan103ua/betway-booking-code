# Backend — Betway Nigeria Booking Code Product

`apps/api` — a standalone Node.js service. It is the only thing that talks to Betway; the
Next.js web app and the Flutter app are both plain HTTP clients of it.

---

## 1. Stack

| | |
|---|---|
| Runtime | Node.js 20, TypeScript |
| Framework | Express |
| Cache | Redis (Upstash) |
| Validation | Zod |
| Testing | Vitest + Supertest |
| Deployment | Railway / Fly.io (persistent process — not a serverless target) |

No database. The three core operations (resolve, encode, convert) are stateless pass-throughs
to Betway — nothing about them needs to be persisted, and Redis alone covers caching. The
brief says "a database if required"; here it genuinely isn't, and adding one just to have one
would be the wrong call, not a safer one.

---

## 2. Why a separate service

Web can't call Betway directly from the browser — Betway's API has no CORS headers for
third-party origins, so every request has to originate server-side. That alone requires
*some* backend. Making it a standalone Express service rather than folding it into Next.js
route handlers has one further payoff: Flutter and the web app become two equal clients of
one API, instead of Flutter calling into what is nominally "Next.js internals." It's also the
natural seam for a second bookmaker later — the API is the provider boundary, not the UI.

---

## 3. Architecture

```
routes/          Express routers — HTTP concerns only: path, method, status codes
controllers/      request → service call → response shape
services/         business logic: normalizes Betway's shape into our own DTOs,
                   orchestrates cache-then-fetch, drives Convert as resolve+encode
providers/         BookingCodeProvider interface
   betway.ts        — talks to www.betway.com.ng / feeds-roa2 / apic / config
   fixtures.ts       — reads the same DTOs from committed JSON, used if Betway
                       is unreachable and for local dev without network
lib/
   redis.ts, errors.ts, rateLimit.ts
```

`services` depend on the `BookingCodeProvider` interface, not on `providers/betway.ts`
directly — swapping in `providers/fixtures.ts` is a one-line change at the composition root,
not a rewrite. This is the layer that answers "what if Betway is down during the demo."

---

## 4. API reference

All responses are our own DTOs — Betway's field names never reach the client. Full request/
response examples: see `docs/backend-api.md`. Summary:

| Method & path | Purpose | Upstream | Cache |
|---|---|---|---|
| `POST /api/booking-codes/resolve` | Decode a code | `Betting/FindBookABet` | Redis, 30–60s |
| `POST /api/booking-codes` | Encode a new code | `Betting/BookABet` | none (write) |
| `POST /api/booking-codes/convert` | Reissue a code, dropping dead legs | resolve + encode, composed server-side | none (write) |
| `GET /api/booking-codes/popular` | Live codes, enriched into full slips | `Widget/BookingCodes` + one `FindBookABet` per code | Redis, 60s |
| `GET /api/sports` | Sport list for Create | `cron/sports/NG/en-US` | Redis, 1h |
| `GET /api/events?sport=` | Upcoming fixtures + inline 1X2 | `BetBook/Upcoming` | Redis, 30s |
| `GET /api/events/:eventId/markets` | Full market list for one event | `MarketGroupings/MarketGroupNamesAndMarketsForEvent` | Redis, 30s |
| `GET /api/health` | Redis / upstream status | — | none |

`Slip` / `Fixture` / `ApiError` / `ConvertResult` — full type definitions in
`docs/backend-api.md` §0, mirrored in Dart on the Flutter side. Not repeated here to avoid the
two documents drifting out of sync.

---

## 5. Caching

Redis sits in front of every read that hits Betway. Two reasons, in order of importance:
Betway has no published rate limit, and a cache is the only defence against tripping one
during a demo or a burst of reviewer clicks; latency is the secondary benefit. Keys are
namespaced by endpoint and input (`resolve:{code}`, `events:{sport}`), TTLs match how fast
the underlying data actually moves — an hour for the sport list, 30–60s for anything with
live odds.

Writes (`POST /api/booking-codes`, `/convert`) are never cached — each call must reach Betway.

Redis is the only store in this service, and it's used exactly as what it is: an ephemeral,
rebuildable cache. Nothing here is meant to survive a flush — if it's gone, the next request
just fetches it from Betway again.

---

## 6. Cross-cutting concerns

- **Validation** — Zod schemas per route, rejecting malformed input before it reaches a
  service (400 with a field-level message, not a 500 from a downstream throw). Includes
  bounds Betway itself doesn't enforce, e.g. `outcomeIds` capped at 20 items on
  `POST /api/booking-codes` — our own endpoint shouldn't be a wider door than theirs.
- **Rate limiting** — `express-rate-limit` on the whole API. Protects Betway from being
  hammered through our own service, and is the concrete answer to "what happens under load"
  if that comes up in review.
- **Error handling** — one Express error-handling middleware, mapping upstream failures
  (`BookABetInvalidCode` → `404`, network/timeout → `502`) to the single `ApiError` shape
  (`{ error, message }`, `docs/backend-api.md` §0). No raw Betway error codes leak to the
  client, and no endpoint returns a differently-shaped error body.
- **CORS** — allowlist the web app's origin explicitly; Flutter doesn't send an `Origin`
  header from a native HTTP client, so it's unaffected either way.
- **Versioning** — no `/api/v1` prefix. Deliberate: a two-day, single-provider API has nothing
  to version against yet, and adding the prefix later is a one-line router change, not a
  breaking one.

---

## 7. Testing

Vitest + Supertest against the Express app directly (no network). `providers/fixtures.ts`
backs these tests so they run offline and deterministically — no live Betway dependency in
CI. Coverage target: the parser (outcome id → DTO field mapping), the Convert composition
logic (drop inactive/selected legs, recompute total odds), and one request/response contract
test per route.

---

## 8. Deployment

Railway or Fly.io — both keep a persistent Node process, unlike Vercel's serverless model,
which the API doesn't fit. Avoid Render's free tier for this specifically: it spins down
after inactivity and the resulting 30–50s cold start on the reviewer's first request reads as
a broken deployment, not a slow one.

Environment variables: `BETWAY_BASE_URL`, `BETWAY_CONFIG_URL`, `BETWAY_FEEDS_URL`,
`BETWAY_APIC_URL`, `REDIS_URL`, `PORT`, `ALLOWED_ORIGIN`. Every one has a working default except
`REDIS_URL`, which is optional by design — the service boots with no environment at all.
`.env.example` committed with empty values; real values live in the platform's env settings,
never in the repo (see the secret-scanning / push-protection setup in the main README).
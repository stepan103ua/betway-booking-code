# Backend API design — Betway Nigeria Booking Code Product

Internal API surface for the Express backend (`apps/api`). Every handler wraps one or more
Betway endpoints (see `api-research.md`), normalizes the response into a provider-agnostic
DTO, and caches in Redis where the upstream data is either slow-changing or
rate-limit-sensitive. Architecture rationale (why a separate service, why no database) lives
in `docs/backend.md` — this file is the request/response contract only.

Design principle: **the client (web or Flutter) never sees Betway's shape.** Every response
below is our own `Slip` / `Fixture` DTO, independent of which bookmaker sits behind it — this
is the seam a second bookmaker would plug into later.

No `/api/v1` prefix. Deliberate, not an oversight: a single-provider, single-consumer-set API
built in two days has nothing to version against yet. Adding a version prefix later is a
one-line change in the Express router, not a breaking one — so paying for it now would be
pure ceremony.

---

## 0. Shared types

Every endpoint below returns one of these four shapes. Defined once here; each section
references them instead of restating fields.

```ts
type Selection = {
  outcomeId: string;
  marketName: string;
  outcomeName: string;
  eventName: string;
  league: string;
  kickoffAt: string;
  odds: number;
  isActive: boolean;
};

type Slip = {
  bookingCode: string;
  totalOdds: number;
  expiresAt: string | null;
  usageCount: number | null;
  selections: Selection[];
};

type Fixture = {
  eventId: string;
  name: string;
  league: string;
  kickoffAt: string;
  market1x2: { outcomeId: string; label: 'Home' | 'Draw' | 'Away'; odds: number }[];
};

// Convert's response: a Slip, plus what changed relative to the code it started from.
type ConvertResult = Slip & {
  previousBookingCode: string;
  previousTotalOdds: number;
  droppedCount: number;
};

type ApiError = {
  error: string;      // stable machine-readable code, e.g. "invalid_code"
  message: string;    // human-readable, safe to show in the UI
};
```

`ApiError` is the one shape every non-2xx response uses, from every endpoint — Zod validation
failures, upstream Betway errors, and internal errors alike. No endpoint below returns a
differently-shaped error body; where a response section only shows a status code, assume this
shape.

---

## 1. Booking codes

The three core operations from the assessment.

### `POST /api/booking-codes/resolve`

Decode — reads a code, returns its contents.

**Request**

```json
{ "code": "BW6E19810C" }
```

**Response `200`** — `Slip`

```json
{
  "bookingCode": "BW6E19810C",
  "totalOdds": 2.76,
  "expiresAt": null,
  "usageCount": null,
  "selections": [
    {
      "outcomeId": "7325887411",
      "marketName": "1X2",
      "outcomeName": "Mamelodi Sundowns",
      "eventName": "Mamelodi Sundowns vs. Milford FC",
      "league": "Premier League",
      "kickoffAt": "2026-09-03T18:00:00Z",
      "odds": 1.26,
      "isActive": true
    }
  ]
}
```

**Response `404`** — `ApiError`

```json
{ "error": "invalid_code", "message": "No slip found for this code." }
```

Upstream: `POST .../Betting/FindBookABet`. On upstream `400 BookABetInvalidCode`, retry once
(observed transient false negatives during research), then map to `404`.

`expiresAt` and `usageCount` are **always `null` here**, which is why both are nullable in the
DTO. `FindBookABet` returns only `{ selections, isBuildABet, isSingleBet, accountId }` — it
reports what is in a slip, not how long the code lives or how many people have used it. Those
two facts exist only in `Widget/BookingCodes` (`betway-api.md` §5), and only for the ~120 codes
it lists; joining against it would add an upstream call to every decode to populate fields that
stay null for most codes. Decode reports what decode can know.

`totalOdds` is computed by us as the product of every leg — upstream sends no total — and
includes inactive legs, because they are part of what the code contains. Convert recomputes
over the legs it keeps, which is what `previousTotalOdds` is there to compare against.

Cache: Redis, key `resolve:{code}`, TTL 30s — the conservative end of the 30–60s this design
allows, since odds visibly move within seconds (`betway-api.md` §3). The code is uppercased
before it becomes a key, so the two spellings of a case-insensitive code share one entry.

---

### `POST /api/booking-codes`

Encode — creates a new code from a set of outcomes.

**Request**

```json
{ "outcomeIds": ["7423294011", "7423294012"] }
```

Zod-validated: 1–20 items, each a non-empty string. Betway itself imposed no observed cap
during testing, but an unbounded array on our own endpoint is an open door for someone to
build a slip with hundreds of legs and hammer `BookABet` through us — 20 comfortably covers
every real accumulator size and costs nothing to enforce.

**Response `200`**

```json
{ "bookingCode": "BW6E45553D" }
```

**Response `400`** — `ApiError`, e.g. `{ "error": "too_many_outcomes", "message": "A slip can hold at most 20 selections." }`

Upstream: `POST .../Betting/BookABet` with `{ cultureCode, countryCode, isSingleBet, outcomes:
[{outcomeId}] }`. Verified live — `outcomeId` alone per selection is sufficient, no other
field required, no auth.

No cache — this is a write.

---

### `POST /api/booking-codes/convert`

Convert — reissue a code for the same bet, optionally dropping dead legs.

**Request**

```json
{ "code": "BW6E19810C", "dropOutcomeIds": ["7325887411"] }
```

**Response `200`** — `ConvertResult` (a `Slip`, plus the previous code and what changed):

```json
{
  "bookingCode": "BW6E9A1123",
  "previousBookingCode": "BW6E19810C",
  "totalOdds": 2.19,
  "previousTotalOdds": 2.76,
  "selections": [ /* Slip.selections, only the ones kept */ ],
  "droppedCount": 1
}
```

Not a separate Betway call — implemented server-side as `resolve` → filter out
`dropOutcomeIds` (and, by default, any selection with `isActive: false`) → `encode`. Worth
stating plainly in the README: on a single bookmaker this is close to tautological; the real
complexity of Convert is cross-bookmaker market mapping, which is out of scope here but is
exactly the seam the DTO layer is built to support later.

---

### `GET /api/booking-codes/popular`

Feeds the Decode screen's empty state.

**Response `200`**

```json
{
  "codes": [
    { "bookingCode": "BW6DF45A44", "selectionCount": 5, "totalOdds": 74.12, "usageCount": 5262 }
  ]
}
```

Upstream: `GET .../Widget/BookingCodes?skip=0&limit=20&source=sportsradar`. Anonymous, always
fresh — also the fixture source for local dev and demos.

Cache: Redis, TTL 60s.

---

## 2. Browse — for building a slip from scratch (Create)

### `GET /api/sports`

**Response `200`**

```json
{ "sports": [{ "id": "soccer", "name": "Soccer" }] }
```

Upstream: `GET config.betwayafrica.com/cron/sports/NG/en-US`. Cache: Redis, TTL 1h — this is a
reference list, not live data.

### `GET /api/events?sport=soccer&take=20`

`take`: optional, default 20, max 50 — mirrors Betway's own paging so a client can't ask this
endpoint to fan out into an unbounded number of upstream calls.

**Response `200`** — `{ events: Fixture[] }`

```json
{
  "events": [
    {
      "eventId": "74232940",
      "name": "Liverpool FC (Alexander) vs. Real Madrid (Lucas)",
      "league": "eAdriatic League",
      "kickoffAt": "2026-09-02T20:00:00Z",
      "market1x2": [
        { "outcomeId": "7423294011", "label": "Home", "odds": 2.27 },
        { "outcomeId": "7423294012", "label": "Draw", "odds": 3.90 },
        { "outcomeId": "7423294013", "label": "Away", "odds": 2.43 }
      ]
    }
  ]
}
```

Upstream: `GET feeds-roa2.betwayafrica.com/.../BetBook/Upcoming/?...&marketTypes=[Win/Draw/Win]`.
The 1X2 market comes back inline, which is all the Create picker needs — no second call per
event. Cache: Redis, TTL 30–60s (odds move).

### `GET /api/events/:eventId/markets` — designed, not built for v1

Full market list beyond 1X2 (Totals, Handicap, Double Chance…), wrapping
`MarketGroupings/group-names` + `MarketGroupNamesAndMarketsForEvent`. Not needed while Create
is scoped to a single market; documented here so the seam is visible and the cut is explicit
rather than accidental.

---

## 3. Health

### `GET /api/health`

```json
{ "status": "ok", "redis": "ok", "betwayLastSuccessAt": "2026-09-02T20:19:25Z" }
```

Pings Redis, reports the timestamp of the last successful Betway call. Cheap to build, reads
as production instinct rather than assessment box-ticking.

---

## 4. Storage

**Redis only** — every read-through endpoint above (`resolve`, `popular`, `sports`, `events`).
Purpose is twofold: latency, and not hammering Betway on every request (rate-limit buffer).
No persistent store: the three core operations are stateless pass-throughs to Betway, so
nothing needs to survive a cache flush. See `docs/backend.md` §1 for why a database was
considered and deliberately left out rather than added to satisfy the checklist.

---

## 5. Client consumption

**Web** (Next.js) uses all of the above.

**Flutter** uses exactly one endpoint: `POST /api/booking-codes/resolve`. The task specifies a
single rough screen — code input plus slip view — so Create and Convert stay web-only. The
`Slip` DTO is the same JSON shape on both sides; the Dart model is a straight mirror of the TS
type, not a reinterpretation.
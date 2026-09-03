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
  markets: Market[];
};

type Market = {
  marketId: string;
  name: string;   // display-ready and fully qualified: "1X2", "Total (6.5)"
  type: string;   // stable machine key: "win-draw-win". Not unique within an event
  outcomes: { outcomeId: string; label: string; odds: number }[];
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

A market is a list entry rather than a `market1x2` key: the market's name is data, not
schema, and upstream can return the same market type twice for one event (two Totals on
different lines) which a keyed object could not represent. `outcomes` is ordered as upstream
ranks it — for `win-draw-win` that is home, draw, away, which is where a 1/X/2 picker gets its
column order, since no outcome carries the word "Home" itself.

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

Zod-validated: 1–20 items, each shaped like an outcome id. Betway imposed no observed cap
during testing, but an unbounded array on our own endpoint is an open door for someone to
build a slip with hundreds of legs and hammer `BookABet` through us — 20 comfortably covers
every real accumulator size and costs nothing to enforce.

**This endpoint makes two upstream calls, not one.** `BookABet` accepts outcome ids that are no
longer bettable, drops them silently, and still returns a well-formed code — so the code comes
back, is decoded, and its legs are compared against what was asked for
(`docs/betway-api.md` §3). Without that read-back this endpoint returns `200` with a code that
`/resolve` immediately answers `404` for.

It is not a rare case. The soccer feed is largely eSoccer with a kick-off every ~15 minutes, so
a selection can die while the user is still picking. The id stays well-formed, so no amount of
request validation sees it.

If the read-back itself fails — a timeout, a `502` — the code is returned anyway. An
inconclusive verification says nothing about whether the code exists, and reporting a create
that probably worked as a failure is the worse error.

**Response `200`**

```json
{ "bookingCode": "BW6E45553D" }
```

**Response `400`** — `ApiError`. Over the cap is the one validation failure with its own code,
because it is the one a client can act on ("remove a selection" is a different UI from "your
request was malformed"):

```json
{ "error": "too_many_outcomes", "message": "A slip can hold at most 20 selections." }
```

A selection that is no longer bettable is `outcomes_unavailable`, whether some or all of them
went:

```json
{ "error": "outcomes_unavailable", "message": "Those selections are no longer available. Refresh and pick again." }
```

Partial loss fails too rather than quietly returning a shorter slip — a user who picked five
and received a three-leg code did not get what they asked for. Dropping legs deliberately is
what `/api/booking-codes/convert` is for.

Everything else — a missing array, an empty one, a malformed id — is `invalid_request`.

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

**Response `400`** — `ApiError`, when nothing survives the filter:

```json
{ "error": "empty_slip", "message": "Dropping those leaves nothing to convert." }
```

`bookingCode` is not nullable, so there is no honest `200` for "nothing left"; the message
distinguishes dropping every leg from a code whose legs are all already dead.

**Response `404`** — `invalid_code`, the same as `/resolve`, since that is the first step.

Not a separate Betway call — implemented server-side as `resolve` → filter out
`dropOutcomeIds` (and, by default, any selection with `isActive: false`) → `encode`. Worth
stating plainly in the README: on a single bookmaker this is close to tautological; the real
complexity of Convert is cross-bookmaker market mapping, which is out of scope here but is
exactly the seam the DTO layer is built to support later.

`dropOutcomeIds` that are not in the slip are ignored rather than rejected — the client is
describing what it wants gone, and a leg already absent is not an error.

The response body is the **decoded new code**, not the old slip with legs removed. Prices move
between resolve and encode (`docs/betway-api.md` §3), so recomputing from the old slip would
report a total the new code does not actually have; `previousTotalOdds` carries the before side
of the diff. The read may be served from cache; the encode never is. Like `POST
/api/booking-codes`, the new code is read back and checked before it is returned, so a leg that
dies mid-flight surfaces as `outcomes_unavailable` rather than as a code quietly missing legs.

If that read-back is itself inconclusive — a timeout, a `502` — the conversion still returns
`200`, and the selections it reports are what was true at the resolve rather than something
confirmed against the new code. Failing a conversion that probably worked is the worse answer,
and the alternative is a response field that would be meaningless on all but a handful of
requests. The event is logged at `warn` with the code, so an operator can tell it apart.

---

### `GET /api/booking-codes/popular`

Feeds the Decode screen's empty state.

`limit`: optional, default 6, max 20. Capped harder than the other list endpoints because it
drives a fan-out — see the cost note below.
`skip`: optional, default 0, max 1000. Offset into the catalogue, which holds about 120 codes.

**Response `200`** — `{ codes: Slip[], skip, limit, total, hasMore }`. `codes` holds the same
`Slip` `/resolve` returns.

```json
{
  "codes": [
    {
      "bookingCode": "BW6E5B94E1",
      "totalOdds": 74.12,
      "expiresAt": "2026-09-04T09:26:42.970Z",
      "usageCount": 9227,
      "selections": [ /* Slip.selections */ ]
    }
  ],
  "skip": 0,
  "limit": 6,
  "total": 120,
  "hasMore": true
}
```

**This is the only endpoint that returns a non-null `expiresAt` and `usageCount`.**
`FindBookABet` reports neither; the catalogue reports both. Joining them is what this endpoint
is for, and it is why those two fields are nullable on `Slip` everywhere else.

Upstream: `GET .../Widget/BookingCodes?skip=0&limit=N&source=sportsradar`, **plus one
`FindBookABet` per code**. The catalogue carries `bookingCode`, `expiryDateTime`, a usage count
and a list of bare outcome ids — no names, no prices — so `totalOdds` and `selections` cannot
come from it. That is a property of the upstream, not a design choice: there is no cheaper way
to produce this response.

**Pages can come back short.** Roughly one code in eight is expired or withdrawn, and those are
dropped — so a request for 6 may return 5, or occasionally none. Topping the page back up is
not possible once `skip` is a client-visible offset: doing so would consume catalogue rows that
the next `skip` then re-reads or jumps past. `total` and `hasMore` are the honest signals, both
derived from catalogue offsets rather than from how many codes survived, so **page on `hasMore`,
never on `codes.length`**.

A short page is not an error, but an unreachable upstream is: only a code that decodes to
nothing is swallowed. A timeout or a `502` propagates, so an outage surfaces as `504`/`502`
rather than as an empty list.

Order is upstream's — the catalogue arrives sorted by usage, descending, and dropping preserves
it.

Cache: Redis, TTL 60s per page (`popular:{skip}:{limit}`). Each decode is separately cached under `resolve:{code}` for
30s and shared with `/resolve`, so a code shown here is already warm when a user clicks it. The
list TTL is the one that governs freshness, so odds inside can be up to a minute old.

---

## 2. Browse — for building a slip from scratch (Create)

### `GET /api/sports`

**Response `200`**

```json
{ "sports": [{ "id": "soccer", "name": "Soccer" }] }
```

Upstream: `GET config.betwayafrica.com/cron/sports/NG/en-US`. Cache: Redis, TTL 1h — this is a
reference list, not live data.

### `GET /api/events?sport=soccer&limit=20`

`limit`: optional, default 20, max 50. The cap mirrors Betway's own paging, so a client can't
ask this endpoint to fan out into an unbounded number of upstream calls. It is named `limit`
rather than `take` to match `/api/booking-codes/popular` — the upstream calls it `Take`, but
two words for one concept is a cost every consumer pays to save one word here.
`skip`: optional, default 0, max 1000. Offset into the fixture list.

**Response `200`** — `{ events: Fixture[], skip, limit, hasMore }`

```json
{
  "events": [
    {
      "eventId": "74232940",
      "name": "Liverpool FC (Alexander) vs. Real Madrid (Lucas)",
      "league": "eAdriatic League",
      "kickoffAt": "2026-09-02T20:00:00Z",
      "markets": [
        {
          "marketId": "742329401",
          "name": "1X2",
          "type": "win-draw-win",
          "outcomes": [
            { "outcomeId": "7423294011", "label": "Liverpool FC (Alexander)", "odds": 2.27 },
            { "outcomeId": "7423294012", "label": "Draw", "odds": 3.90 },
            { "outcomeId": "7423294013", "label": "Real Madrid (Lucas)", "odds": 2.43 }
          ]
        }
      ]
    }
  ],
  "skip": 0,
  "limit": 20,
  "hasMore": true
}
```

Both `skip` values are capped. `hasMore` and `total` tell a well-behaved client where to stop,
but `skip` lands in a Redis cache key, so an unbounded one is unbounded key cardinality — every
distinct value is a fresh entry and a fresh upstream call. The ceiling is far past any real
corpus; it exists to refuse nonsense, not to describe the data.

`hasMore` is upstream's own end-of-list flag, not a count comparison — **this feed reports no
total**, so there is no equivalent of the catalogue's `total` here and a page's size says
nothing about whether another exists. A page can legitimately come back with fewer events than
`take` (every market suspended, say) while more pages remain, so page on `hasMore`, never on
the length of `events`.

Upstream: `GET feeds-roa2.betwayafrica.com/.../BetBook/Upcoming/?...&marketTypes=[Win/Draw/Win]`.
The 1X2 market comes back inline, which is all the Create picker needs — no second call per
event, so `markets` here always holds exactly one entry. Cache: Redis, TTL 30s (odds move).

An unknown sport is **not** an error: upstream answers with an empty page, so this returns
`200 { "events": [] }`. That is deliberate — a real sport can genuinely have no upcoming
fixtures (`athletics`, `cycling` and `lacrosse` all did when this was verified), so an empty
list has to be a valid answer here. `GET /api/events/:eventId/markets` treats the same
emptiness as a `404`, because an event with nothing priced on it is not an event a client can
do anything with.

### `GET /api/events/:eventId/markets`

The full market list for one event — Totals, Handicap, Double Chance and the rest — for a
picker that has grown past 1X2.

**Response `200`** — `{ eventId: string, markets: Market[] }`, the same `Market` the endpoint
above returns.

```json
{
  "eventId": "74263200",
  "markets": [
    {
      "marketId": "7426320018total=6.5~",
      "name": "Total (6.5)",
      "type": "handicap-goals-over",
      "outcomes": [
        { "outcomeId": "7426320018total=6.5~12", "label": "Over", "odds": 1.93 },
        { "outcomeId": "7426320018total=6.5~13", "label": "Under", "odds": 1.69 }
      ]
    }
  ]
}
```

**Response `404`** — `ApiError`, when the event is unknown or has no priced markets.

```json
{ "error": "not_found", "message": "No markets found for this event." }
```

Upstream: `GET .../MarketGroupings/MarketGroupNamesAndMarketsForEvent?marketGroupId=Main`.
Only the `Main` group, which is one call and already carries 1X2, Double Chance, Draw No Bet,
Total and Handicap. The other groups (`Goals`, `Totals`, `Winner`, `Handicap`, `Build A Bet`,
from `MarketGroupings/group-names`) would cost one upstream call each and mostly duplicate
`Main`; fetching them is an additive change if a client ever needs them. Cache: Redis, TTL 30s.

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
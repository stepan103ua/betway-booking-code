# Betway Nigeria — API research

Reverse-engineered from the public web client (Nuxt 3 SPA) on 2026-09-02.
All calls below were verified live from the browser with `credentials: 'omit'` — **no login, no session, no API key**.

---

## 1. Domain map

Extracted from the client bundle config object. `{tld}` = `com.ng`.

| Key | Base URL |
|---|---|
| `configDomain` | `https://config.betwayafrica.com` |
| `apiDomain` | `https://api.betwayafrica.com/api` |
| `apicDomain` | `https://apic.betwayafrica.com/api` |
| `authDomain` | `https://www.betway.com.ng/appsynapse/auth` |
| `playerDomain` | `https://www.betway.com.ng/appsynapse/player` |
| `sportsDomain` | `https://synapse-sportsapi.betway.com.ng` |
| **feeds (observed)** | **`https://feeds-roa2.betwayafrica.com/br/_apis/sport/v1`** |
| **`bettingDomain`** | **`https://www.betway.com.ng/appsynapse/bet-api-sr`** |
| `kenticoDomain` | `https://cms1.betwayafrica.com` |

The client's HTTP wrapper takes `{ url, type, apiVersion }` and resolves `type` to one of these
bases: `betting` → `bettingDomain`, `sports` → feeds, `influencer` → separate host.

All feed/betting calls below worked from a plain `fetch`, no cookies, no headers beyond
`Content-Type: application/json` on POSTs. No signature, no captcha, no `cf_clearance` on the
API — Cloudflare guards only the HTML document.

---

## 2. DECODE — resolve a booking code

```
POST https://www.betway.com.ng/appsynapse/bet-api-sr/v2/Betting/FindBookABet
Content-Type: application/json

{ "countryCode": "NG", "bookingCode": "BW6E19810C", "cultureCode": "en-US" }
```

**200 response**

```jsonc
{
  "selections": [ /* one object per pick, see field table below */ ],
  "isBuildABet": false,
  "isSingleBet": false,
  "accountId": "00000000-0000-0000-0000-000000000000"  // all-zero = anonymous
}
```

**Selection object** — the fields that matter:

| Field | Example | Note |
|---|---|---|
| `outcomeId` | `"7325887411"` | composite, see §6 |
| `marketId` | `"732588741"` | |
| `marketName` | `"1X2"` | |
| `outcomeName` | `"Mamelodi Sundowns"` | |
| `eventId` | `73258874` | |
| `eventName` | `"Mamelodi Sundowns vs. Milford FC"` | |
| `eventEpoch` | unix seconds | kick-off |
| `priceDecimal` | `1.26` | decimal odds |
| `priceNumerator` / `priceDenominator` | `13` / `50` | fractional |
| `league`, `region`, `sportId` | | |
| `handicap`, `marketHandicap` | | for Total / Handicap markets |
| `isMarketActive`, `isEventActive`, `isOutcomeActive` | | **staleness flags**, but see below |
| `nestedBets` | | Build-a-Bet |

Each selection also carries four **nested objects** — `price`, `outcome`, `market`,
`sportEvent` — repeating much of the above with more detail. Three fields in them matter,
because each is a further reason a leg cannot be bet:

| Field | Meaning |
|---|---|
| `market.isSuspended` | market is live but trading is halted |
| `sportEvent.isFinished` | the event has already finished |
| `outcome.isTradingActive` | this specific outcome is not currently priced |

So staleness has **six** signals, not the three top-level flags. A leg is bettable only when
all six agree, and the nested three are the ones easy to miss — a suspended market still
reports `isMarketActive: true`. Convert exists to drop unbettable legs, so missing these puts
the bug straight into the feature built to prevent it.

Two more things observed on real responses (2026-09-03):

- **`outcomeName` is not always self-describing.** On a 1X2 market it is the team
  (`"Arsenal"`); on a Total it is `"Over "` — with a trailing space, and meaningless alone. The
  line lives in `marketName`, which is already fully qualified (`"Total (1.5)"`,
  `"Liverpool FC Total (1.5)"`). Trim it and show the pair. `outcome.sbv` (`" (1.5)"`) holds the
  line separately if a client ever needs the outcome to stand on its own.
- **A code can decode to fewer legs than it was created with.** `BW6E42397E` was listed in the
  public catalogue with 8 bets and decoded to 7 selections. Treat the decoded slip as the truth
  and do not reconcile against a leg count from elsewhere.

**400 response**

```json
{ "errorCode": 6000331, "errorMessage": "BookABetInvalidCode", "responseMetadata": null }
```

### Code format

- `BW` + 8 hex chars, e.g. `BW6E19810C`. **Case-insensitive.** `BW` prefix required.
- Codes expire (`Widget/BookingCodes`, §5, gives `expiryDateTime`, ~24h out).
- Client-side, a code starting with a digit routes to `bettingHorses` + `apiVersion: v1`
  instead — horse racing codes use a different backend. Football codes: `betting` + `v2`.

---

## 3. ENCODE — create a booking code

```
POST https://www.betway.com.ng/appsynapse/bet-api-sr/v1/Betting/BookABet
Content-Type: application/json

{
  "cultureCode": "en-US",
  "countryCode": "NG",
  "isSingleBet": false,
  "outcomes": [ { "outcomeId": "7423294011" }, { "outcomeId": "7423294012" } ]
}
```

**Verified live, minimal payload — `{ "outcomeId": "..." }` per selection is sufficient,
nothing else required.**

**200 response**

```json
{ "bookingCode": "BW6E45553D" }
```

**Round-trip verified end to end:** decoding `BW6E45553D` immediately after creating it
returned the same two selections (Liverpool FC (Alexander) vs. Real Madrid (Lucas), 1X2 —
home & draw), confirming decode ⇄ encode share one consistent model. Odds had moved slightly
between create and decode (2.27 → 2.17) — expected, since prices are live; not a bug, but
worth surfacing in the UI ("odds shown may differ from the moment the code was created").

Anonymous, `apiVersion: v1` (not v2 like FindBookABet). No cap found on `outcomes.length`
during testing.

---

## 4. CREATE flow — sport → event → market → outcome

This is the real substance of the Create screen. Four steps, four endpoints, all anonymous
GET.

### 4.1 Sport list

```
GET https://config.betwayafrica.com/cron/sports/NG/en-US
```

```jsonc
{
  "sports": [
    {
      "sportId": "soccer",
      "name": "Soccer",
      "defaultMarkets": ["[Both Teams To Score]", "[Double Chance]", "[Win/Draw/Win]"],
      "filterMarkets": [
        { "name": "[Win/Draw/Win]", "displayName": "1X2", "filterIndex": 1 },
        { "name": "[Double Chance]", "displayName": "Double Chance", "filterIndex": 3 }
        /* … full market catalogue for the sport … */
      ]
    }
    /* tennis, basketball, cricket, rugby-union, baseball, esports … */
  ]
}
```

This is also where the human-readable market name catalogue lives — useful for the parser's
market-name lookup table.

### 4.2 Regions & leagues for a sport (for filtering, optional for MVP)

```
GET https://feeds-roa2.betwayafrica.com/br/_apis/sport/v1/Feeds/RegionsAndLeagues/soccer?countryCode=NG
```

Returns `{ regions: [{ regionId, name, leagues: [{ leagueId, name }] }] }` — nested list, e.g.
England → Premier League, FA Cup, League One… Skip this for the picker MVP (§ Create screen
already scopes to "upcoming fixtures", no league filter needed) but it's there if wanted.

### 4.3 Event list for a sport

```
GET https://feeds-roa2.betwayafrica.com/br/_apis/sport/v1/BetBook/Upcoming/?countryCode=NG&sportId=soccer&Skip=0&Take=20&cultureCode=en-US&isEsport=false&boostedOnly=false&marketTypes=%5BWin%2FDraw%2FWin%5D
```

Path segment is the fixture type, case-sensitive: `Highlights`, `Upcoming`, `LiveInPlay`,
`Filtered`, `Outrights`. `marketTypes` is a repeatable query param, URL-encoded market name
from §4.1's `filterMarkets[].name` (e.g. `[Win/Draw/Win]` → `%5BWin%2FDraw%2FWin%5D`) — it
scopes which markets come back inline with the event list, it does **not** filter which
events appear.

`Filtered` additionally accepts `FromStartEpoch`, `ToStartEpoch`, `SortOrder`, `Odds.Minimum`,
`Odds.Maximum`, and repeated `RegionAndLeagueIds[i].regionId` / `.leagueId` pairs — not needed
for the MVP picker.

**Response shape — flat, normalized, joined by id:**

```jsonc
{
  "events":  [{ eventId, name, homeTeam, awayTeam, league, region, expectedStartEpoch, isActive, isLive, … }],
  "markets": [{ marketId, eventId, name, displayName, marketTypeCName, isActive, … }],
  "outcomes":[{ outcomeId, marketId, eventId, name, displayName, isTradingActive, … }],
  "prices":  [{ outcomeId, priceDecimal, numerator, denominator, … }],
  "scores":  [ /* live score per event, if any */ ],
  "isFinalPage": false
}
```

Join key path: `event.eventId` ← `market.eventId`, `market.marketId` ← `outcome.marketId`,
`outcome.outcomeId` ← `price.outcomeId`. This is exactly the normalized-store shape worth
mirroring in the frontend cache (a map per entity, not nested objects) — same pattern
Betway's own client uses internally (`n.events = new Map`, etc., seen in the bundle).

### 4.4 Full market list for one event (when the user taps into a match)

Two calls, confirmed live:

```
GET .../v1/MarketGroupings/group-names?eventId=74232940&countryCode=NG
```

```json
[
  { "id": "Main", "name": "Main", "marketCount": 7, "sortOrder": 10 },
  { "id": "Goals", "name": "Goals", "marketCount": 2, "sortOrder": 20 },
  { "id": "Totals", "name": "Totals", "marketCount": 2, "sortOrder": 25 },
  { "id": "Winner", "name": "Winner", "marketCount": 3, "sortOrder": 30 },
  { "id": "Handicap", "name": "Handicap", "marketCount": 2, "sortOrder": 340 },
  { "id": "Build A Bet", "name": "Build A Bet", "marketCount": 4, "sortOrder": 999 }
]
```

```
GET .../v1/MarketGroupings/MarketGroupNamesAndMarketsForEvent?eventId=74232940&marketGroupId=Main&countryCode=NG&cultureCode=en-US&skip=0&take=20&isBuildABetOnly=false&searchQuery=
```

(This is the endpoint you found.) Returns `{ marketGroupNames, marketsInGroup, outcomes,
prices, boostedPrices }` — same flat/joined shape as §4.3, scoped to one event and one market
group. `marketGroupId` cycles through the ids from `group-names` (`Main`, `Goals`, `Totals`,
`Winner`, `Handicap`). `searchQuery` filters markets by name server-side.

**For the MVP picker this whole step (4.4) is skippable** — `BetBook/Upcoming` already returns
the 1X2 market and its 3 outcomes inline per event, which is all the Create screen needs. Use
4.4 only if the picker grows beyond a single market.

---

## 5. Public catalogue of booking codes (fixtures / demo data source)

```
GET https://apic.betwayafrica.com/api/v1/Widget/BookingCodes?skip=0&limit=6&source=sportsradar
```

```jsonc
{
  "total": 120,
  "data": [
    {
      "bookingCode": "BW6DF45A44",
      "expiryDateTime": "2026-09-03T15:28:31.467+02:00",
      "count": 5262,
      "bets": [ { "eventID": 73655052, "marketID": "736550521", "outcomeID": "7365505211" } ]
    }
  ]
}
```

120 live codes, refreshed continuously, anonymous, always-valid. Use for the Decode empty
state's "popular codes" list and for offline fixtures/mocks.

---

## 6. ID scheme — composite, not opaque

```
eventId    73258874
marketId   732588741            = eventId + marketType index
outcomeId  7325887411           = marketId + outcome index
```

With a market parameter (Totals/Handicap), the value is embedded as text:

```
marketId   "7378605620total=0.5~"
outcomeId  "7378605620total=0.5~12"
```

Observed market type indices: `1` = 1X2, `10` = Double Chance, `11` = Draw No Bet,
`18`/`20` = Total, `29` = Anytime Goalscorer. Non-soccer sports use a different, larger
index space (tennis Match Winner market seen as `74150364186`, i.e. a 3-digit type code) —
**don't hardcode the soccer index table for other sports**, read `marketTypeCName` instead
of parsing the numeric suffix.

Practical consequence: outcome IDs are constructed from event+market+outcome index, not
random. That's the seam for a future cross-bookmaker mapping layer — same shape, just a
different id-construction function per provider.

---

## 7. Platform notes

- **Nuxt 3 SPA.** Direct GET on a deep route (`/book-a-bet-results`, `/book-a-bet`) fails
  with `ERR_ABORTED` — those routes exist only in the client router. Navigate from `/`.
- **Cloudflare** guards the HTML document, not the API — confirmed across every endpoint in
  this document, GET and POST, decode and encode. Blocking cookies makes CF return a *block*
  page ("Sorry, you have been blocked") on the HTML shell; the JSON endpoints don't care.
- **Do not follow `betway.com`** — some flows redirect the global domain, which is
  geo-restricted and blocked. Pin every request to `www.betway.com.ng` /
  `feeds-roa2.betwayafrica.com` / `config.betwayafrica.com` / `apic.betwayafrica.com` exactly
  as listed above.
- **Live odds arrive over SignalR** (`unsubscriptionBetbookEndpoint`, `signalRGroupId:
  "event::74232940"`). REST gives the snapshot; the socket gives updates. Out of scope for a
  2-day build — snapshot + short TTL cache is the right call, and the odds-drift observed in
  §3 (2.27 → 2.17 seconds apart) is the concrete justification to name in the README.
- One transient oddity: a valid code returned 400 once, then 200 on the next call in the same
  minute. Add a single retry before reporting a code as invalid.

---

## 8. Verdict

All three operations — decode, encode, and the full sport→event→market→outcome browse needed
to build a slip from scratch — are reachable anonymously over plain JSON, GET and POST, with
no auth, no signature, no captcha, no `cf_clearance` on the API. A server-side `fetch` from
Node is sufficient for the whole backend; no headless browser, no proxy, no test account
needed for any of it.
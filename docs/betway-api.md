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
| `sportsDomainRadar` | `https://www.betway.com.ng/sportsapi/br` |
| **`bettingDomain`** | **`https://www.betway.com.ng/appsynapse/bet-api-sr`** |
| `kenticoDomain` | `https://cms1.betwayafrica.com` |
| feeds (observed) | `https://feeds-roa2.betwayafrica.com/br/_apis/sport/v1` |

The client's HTTP wrapper takes `{ url, type, apiVersion }` and resolves `type` to one of these
bases: `betting` → `bettingDomain`, `sports` → feeds, `influencer` → separate host.

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
  "selections": [ /* one object per pick */ ],
  "isBuildABet": false,
  "isSingleBet": false,
  "accountId": "00000000-0000-0000-0000-000000000000"  // all-zero = anonymous
}
```

**Selection object** — 37 fields; the ones that matter:

| Field | Example | Note |
|---|---|---|
| `outcomeId` | `"7325887411"` | composite, see §5 |
| `marketId` | `"732588741"` | |
| `marketName` | `"1X2"` | |
| `outcomeName` | `"Mamelodi Sundowns"` | |
| `eventId` | `73258874` | |
| `eventName` | `"Mamelodi Sundowns vs. Milford FC"` | |
| `eventEpoch` | unix seconds | kick-off |
| `priceDecimal` | `1.26` | decimal odds |
| `priceNumerator` / `priceDenominator` | `13` / `50` | fractional: 13/50 + 1 = 1.26 |
| `league`, `region`, `sportId` | | |
| `handicap`, `marketHandicap` | | for Total / Handicap markets |
| `isMarketActive`, `isEventActive`, `isOutcomeActive` | | **staleness flags** |
| `nestedBets` | | Build-a-Bet |

Full field list: `isEachWayActive, isStartingPrice, isNested, specialBetType, multiplier,
outcomeId, marketName, marketId, marketGroupName, marketIsSportBonusAllowed, price, outcome,
market, originalMarket, sportEvent, isCashOutAllowed, eventId, eventName, eventEpoch,
eventExpectedEndEpoch, eventIsSportBonusAllowed, venueEpoch, outcomeName, priceDenominator,
priceNumerator, priceDecimal, isMarketActive, isEventActive, isOutcomeActive,
eachWayFractionDenominator, eachWayPosition, sportId, handicap, marketHandicap, league,
region, nestedBets`

**400 response**

```json
{ "errorCode": 6000331, "errorMessage": "BookABetInvalidCode", "responseMetadata": null }
```

### Code format

- `BW` + 8 hex chars, e.g. `BW6E19810C`. Total length 10.
- **Case-insensitive** — `bw6df45a44` returned 200.
- The `BW` prefix is **required**; `6E19810C` returns `BookABetInvalidCode`.
- The client validates client-side first (`validatedCode` helper) and routes to
  `bettingHorses` + `apiVersion: v1` when the first character is a digit — horse racing
  codes use a different backend. Football codes go to `betting` + `v2`.
- Codes expire: the catalogue (§4) returns `expiryDateTime`, ~24h out.

---

## 3. ENCODE — create a booking code

Contract read from the bundle (not executed — creates a record on their system):

```
POST https://www.betway.com.ng/appsynapse/bet-api-sr/{v}/Betting/BookABet
Content-Type: application/json

{
  "cultureCode": "en-US",
  "countryCode": "NG",
  "isSingleBet": false,
  "outcomes": [ /* the betslip selection array */ ]
}
```

Response is read by the client as `response.bookingCode`.

Open questions to verify first:
- API version — the call site sets no `apiVersion`, so it falls through to the wrapper default (likely `v1`). Try `v1` then `v2`.
- Minimum shape of each entry in `outcomes` — the client posts its full internal selection
  objects, but the server probably only needs `outcomeId` (+ maybe `marketId`, `eventId`).
  Start from a `FindBookABet` response and strip fields down until it breaks.
- Whether an anonymous call is accepted. `FindBookABet` is anonymous; `BookABet` may be too,
  since booking is a pre-login action by design.

---

## 4. Public catalogue of booking codes

```
GET https://apic.betwayafrica.com/api/v1/Widget/BookingCodes?skip=0&limit=6&source=sportsradar
```

```jsonc
{
  "total": 120,
  "nextSubset": 2,
  "data": [
    {
      "bookingCode": "BW6DF45A44",
      "expiryDateTime": "2026-09-03T15:28:31.467+02:00",
      "count": 5262,                       // times the code was used
      "bets": [
        { "eventID": 73655052, "marketID": "736550521", "outcomeID": "7365505211" }
      ]
    }
  ]
}
```

120 live codes, refreshed continuously. **This is the fixture source** — free, anonymous,
always-valid test data. Pull 20 codes into `fixtures/` and the mock provider is done.

Rendered equivalent for humans: `https://www.betway.com.ng/book-a-bet-results` (client-side
navigation only — see §6).

---

## 5. ID scheme — composite, not opaque

```
eventId    73258874
marketId   732588741            = eventId + marketType
outcomeId  7325887411           = marketId + outcomeIndex
```

With a market parameter the value is embedded as text:

```
marketId   "7378605620total=0.5~"
outcomeId  "7378605620total=0.5~12"
             ^^^^^^^^ ^^ ^^^^^^^^^ ^^
             eventId  20  param     outcome
```

Observed market type codes: `1` = 1X2, `10` = Double Chance, `18`/`20` = Total,
`29` = Anytime Goalscorer (`~74` suffix seen), `54617` = combo markets.

Practical consequence: outcome IDs can be **constructed**, not only echoed back. Good for
Convert; also the seam where a cross-bookmaker mapping layer would attach.

---

## 6. Platform notes

- **Nuxt 3 SPA.** Direct GET on a deep route (`/book-a-bet-results`, `/book-a-bet`) fails
  with `ERR_ABORTED` / 403 — those routes exist only in the client router. Navigate from `/`.
- **Cloudflare** guards the HTML document, not the API. Blocking cookies makes CF return a
  *block* page ("Sorry, you have been blocked") rather than a challenge. The JSON endpoints
  above answered fine with no cookies at all.
- **Do not follow `betway.com`** — some flows redirect the global domain, which is
  geo-restricted and blocked. Pin every request to `www.betway.com.ng`.
- **Live odds arrive over SignalR** (`unsubscriptionBetbookEndpoint`, `signalRGroupId:
  "event::74100004"`). REST gives the snapshot; the socket gives updates. Out of scope for a
  2-day build — snapshot + TTL cache is the right call, and worth naming as a deliberate
  limitation.
- One transient oddity: `BW6DF45A44` returned 400 once, then 200 on the next call in the same
  minute. Add a single retry before reporting an invalid code.

---

## 7. Verdict

Both halves of the task are reachable anonymously over plain JSON POST. No auth, no signature,
no captcha, no `cf_clearance` on the API. Server-side `fetch` from Node is enough — no
headless browser, no proxy.

The remaining unknown is `BookABet` (§3), which is 20 minutes of probing.
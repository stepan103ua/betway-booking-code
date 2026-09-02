# Fixtures

Real `FindBookABet` responses, captured live on 2026-09-03. Not hand-written — a hand-written
fixture drifts from the real shape and quietly stops testing the parser.

| File | What it is |
|---|---|
| `find-book-a-bet.json` | Four selections from booking code `BW6E487423`, each object byte-identical to the live response |
| `find-book-a-bet-inactive.json` | The same capture with two legs made unbettable |

`find-book-a-bet.json` is a subset of a 19-selection slip, chosen to cover every shape the
mapper handles: a 1X2 leg whose `outcomeName` is a team name, a team-scoped Total
(`"Liverpool FC Total (1.5)"`), a plain Total whose `outcomeName` is `"Over "` with a trailing
space, and a second 1X2 from a different league. Selections were dropped whole; no field
inside one was edited.

`find-book-a-bet-inactive.json` is derived, because neither live slip contained a dead leg —
one selection has `isOutcomeActive: false`, another `market.isSuspended: true`, so two
different staleness signals are exercised. Everything else is untouched.

## Refreshing

Codes expire in about 24 hours. These stay valid as parser fixtures forever, but to capture a
new one, take a live code from the public catalogue and decode it:

```bash
curl -s 'https://apic.betwayafrica.com/api/v1/Widget/BookingCodes?skip=0&limit=3&source=sportsradar'

curl -s -X POST 'https://www.betway.com.ng/appsynapse/bet-api-sr/v2/Betting/FindBookABet' \
  -H 'Content-Type: application/json' \
  -d '{"countryCode":"NG","bookingCode":"<code>","cultureCode":"en-US"}'
```

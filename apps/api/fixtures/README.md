# Fixtures

Real Betway responses, captured live on 2026-09-03. Not hand-written — a hand-written fixture
drifts from the real shape and quietly stops testing the parser.

| File | What it is |
|---|---|
| `find-book-a-bet.json` | Four selections from booking code `BW6E487423`, each object byte-identical to the live response |
| `find-book-a-bet-inactive.json` | The same capture with two legs made unbettable |
| `config-sports.json` | The full sport list, all 27 entries — including the three `sportType: "Promo"` ones the mapper filters out |
| `betbook-upcoming.json` | Five upcoming soccer events with their 1X2 markets inline (`Take=5`) |
| `market-group-main.json` | The `Main` market group for event `74263200`, one of the five above |
| `widget-booking-codes.json` | Ten live catalogue entries, sorted by usage — the input to the popular-codes fan-out |

The last three are unedited captures. `config-sports.json` keeps the promo entries on purpose —
they are what the `sportType` filter exists for, so removing them would delete the test. And
`market-group-main.json` is the only fixture containing a squashed market (`Total (6.5)`,
`Handicap (0 : 1.5)`), which is the one shape that breaks the join rule the docs give.

`betbook-upcoming.json` and `market-group-main.json` describe the same event, so the market a
client sees in the event list is the same one it sees on the event page.

`widget-booking-codes.json` is kept whole because the ordering is part of what it tests — the
catalogue arrives sorted by usage and the mapper must not disturb it. Offline, every code in it
resolves to the sample slip, since `FixturesProvider.resolve` answers an unrecognised code with
that capture; that is what makes the service's fan-out testable without a network. A test that
needs a decode to fail spies on `resolve` rather than editing this file.

`find-book-a-bet.json` is a subset of a 19-selection slip, chosen to cover every shape the
mapper handles: a 1X2 leg whose `outcomeName` is a team name, a team-scoped Total
(`"Liverpool FC Total (1.5)"`), a plain Total whose `outcomeName` is `"Over "` with a trailing
space, and a second 1X2 from a different league. Selections were dropped whole; no field
inside one was edited.

`find-book-a-bet-inactive.json` is derived, because neither live slip contained a dead leg —
one selection has `isOutcomeActive: false`, another `market.isSuspended: true`, so two
different staleness signals are exercised. Everything else is untouched.

## Refreshing

Codes expire in about 24 hours, and the events in the browse captures kick off and disappear.
All of them stay valid as parser fixtures forever — only their usefulness as a live demo
decays. To capture a new set:

```bash
curl -s 'https://config.betwayafrica.com/cron/sports/NG/en-US'

curl -s 'https://feeds-roa2.betwayafrica.com/br/_apis/sport/v1/BetBook/Upcoming/?countryCode=NG&sportId=soccer&Skip=0&Take=5&cultureCode=en-US&isEsport=false&boostedOnly=false&marketTypes=%5BWin%2FDraw%2FWin%5D'

curl -s 'https://feeds-roa2.betwayafrica.com/br/_apis/sport/v1/MarketGroupings/MarketGroupNamesAndMarketsForEvent?eventId=<eventId>&marketGroupId=Main&countryCode=NG&cultureCode=en-US&skip=0&take=50&isBuildABetOnly=false&searchQuery='
```

Take the `eventId` for the third call from the second, or the fixtures stop describing one
coherent event. Then update `CAPTURED_EVENT_ID` in `src/providers/fixtures.provider.ts` — the
provider gates on it, and the tests read it from there rather than repeating the literal.

To capture a new booking code, take a live one from the public catalogue and decode it:

```bash
curl -s 'https://apic.betwayafrica.com/api/v1/Widget/BookingCodes?skip=0&limit=3&source=sportsradar'

curl -s -X POST 'https://www.betway.com.ng/appsynapse/bet-api-sr/v2/Betting/FindBookABet' \
  -H 'Content-Type: application/json' \
  -d '{"countryCode":"NG","bookingCode":"<code>","cultureCode":"en-US"}'
```

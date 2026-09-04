# Verification — generated codes redeem on Betway's own site

The brief's requirement: load each generated or converted code on `betway.com.ng` and confirm
the resulting slip matches. This is that check, run against the live deployment
(`docs/deployment.md`), with the exact codes and steps so it can be repeated rather than taken
on faith.

---

## 1. Method

Betway's own booking-code redemption lives in its bet slip, not on a dedicated page:
`betway.com.ng` → **Sport** → the **Betslip** icon (bottom nav under ~1024px width; a sidebar
panel above it) → a **Booking Code** field with a **Load** button. Paste the code, Load, and
the slip that comes back is compared against what `apps/api`'s `/resolve` returned for the
same code: same matches, same market, same selections. Odds are **not** part of this check —
`docs/betway-api.md` §7 documents that prices move between encode and decode, and the example
below hits that drift about as hard as it gets.

## 2. Round-trip example (production, 2026-09-04)

All three calls against <https://betway-booking-code-production.up.railway.app>, no fixtures
involved.

**Create.** `POST /api/booking-codes` with two live outcome ids —
`7429103011` (AC Milan (Kai), 1X2, AC Milan (Kai) vs. FC Inter Milano (Andrew)) and
`7429104611` (SS Lazio (Logan), 1X2, SS Lazio (Logan) vs. Atalanta BC (Gael)) — returned
`BW6EB6E849`.

**Resolve.** `POST /api/booking-codes/resolve` for `BW6EB6E849` returned both selections back,
`totalOdds: 4.54` (2.43 × 1.87 — already a little off the 2.50 / 1.92 quoted at create time,
seconds earlier).

**Loaded on betway.com.ng.** Both legs present, same two matches, same market. Both had gone
**live** between create and this check — the eAdriatic League esports fixtures kicked off
mid-test — so Betway's in-play repricing shows 4.45 / 1.95 (total 8.67), a much bigger swing
than the pre-match drift the docs describe. That's the odds-drift behaviour at its most
visible, not a discrepancy: the selections are exactly the ones `/resolve` returned, which is
what this check verifies.

**Convert.** `POST /api/booking-codes/convert` on `BW6EB6E849`, dropping `7429104611` (SS
Lazio), returned `BW6EB6F68B` — one selection (AC Milan (Kai)), `previousBookingCode:
"BW6EB6E849"`, `previousTotalOdds: 4.54`, `droppedCount: 1`.

**Loaded on betway.com.ng.** Exactly one selection — AC Milan (Kai), 1X2 — at whatever Betway's
live price was at that moment. SS Lazio is gone. This confirms the drop reached Betway's own
`BookABet` call, not just this service's response — the thing Convert exists to do.

## 3. What this confirms, and what it can't

Confirms: decode ⇄ encode share Betway's own model (verified once already,
`docs/betway-api.md` §3, with a different code); Convert's `resolve → filter → encode`
composition (`docs/architecture.md` §3) produces a code Betway itself will redeem with exactly
the kept legs; both hold against production, not just the fixture-backed test suite.

Doesn't confirm price parity — deliberately not the point (§1) — or anything about a code past
its ~24h validity window (`docs/betway-api.md` §2).

## 4. Reproducing this

```bash
API=https://betway-booking-code-production.up.railway.app

# Create — swap in any two live outcomeIds from GET /api/events?sport=soccer
curl -s -X POST "$API/api/booking-codes" -H 'Content-Type: application/json' \
  -d '{"outcomeIds":["<id1>","<id2>"]}'

curl -s -X POST "$API/api/booking-codes/resolve" -H 'Content-Type: application/json' \
  -d '{"code":"<code from above>"}'

curl -s -X POST "$API/api/booking-codes/convert" -H 'Content-Type: application/json' \
  -d '{"code":"<code>","dropOutcomeIds":["<id1>"]}'
```

Then betway.com.ng → Sport → Betslip → Booking Code → paste → Load, per §1.

## 5. Screenshots

Not included as static images here — the redemption is short enough to show live in the Loom
walkthrough, which is where a reviewer would expect to see it happen rather than trust a PNG.
If a written record is wanted alongside this doc, the two loads in §2 take under a minute to
repeat and screenshot.

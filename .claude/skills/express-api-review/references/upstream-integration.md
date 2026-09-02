# Upstream integration — talking to Betway

Everything here is verified and recorded in `docs/betway-api.md`. Check code against that
document rather than against intuition; several of these are counter-intuitive.

## Hosts and versions

- **Pinned hosts only**: `www.betway.com.ng`, `feeds-roa2.betwayafrica.com`,
  `config.betwayafrica.com`, `apic.betwayafrica.com`. A request to `betway.com` is a
  **Blocker** — the global domain is geo-restricted and redirects.
- **`FindBookABet` is v2; `BookABet` is v1.** Not a typo, and easy to "correct" into a break.
  A hardcoded version in a shared base URL that both calls reuse is a **Blocker**.
- A base URL should come from `config.ts`, not a string literal in a provider — that is what
  makes swapping to a staging host or a recorded proxy possible.

## Resilience

- **Every fetch needs a timeout.** `AbortSignal.timeout()`; without one, a hung upstream
  connection holds a request open until the platform kills it. Absent timeout is a **Blocker**
  — it is the classic way a proxy service falls over under a partial outage.
- **Distinguish a timeout from an error.** An abort maps to `upstream_timeout` (504), not
  `internal_error` (500). The distinction is what tells you afterwards whether Betway was slow
  or you were broken.
- **Retry `resolve` exactly once.** A valid code returned 400 once and 200 seconds later
  (`docs/betway-api.md` §7). No retry means users are told a good code is invalid; a retry loop
  on a genuinely invalid code multiplies load for nothing. Once.
- Never retry `BookABet`. It creates a code; a retry after an ambiguous failure risks a second
  one. Non-idempotent writes are not retried blind.
- A non-2xx from upstream is never forwarded verbatim. Map it, then log the original.

## Parsing

- **Do not parse the numeric market suffix from an ID.** IDs are composite
  (`outcomeId = marketId + index`), the soccer market-type table does not hold for other
  sports, and a tennis market appeared with a 3-digit type code. Read `marketTypeCName`.
  Hardcoding the soccer indices is a **Should fix** that becomes a Blocker the moment a second
  sport appears.
- **Three staleness flags, one DTO field.** Missing any of `isMarketActive`, `isEventActive`,
  `isOutcomeActive` when computing `isActive` means a dead leg is presented as live — and
  Convert exists specifically to drop those, so the bug lands in the feature built to prevent it.
- **`eventEpoch` is unix seconds, not milliseconds.** A `new Date(epoch)` without `* 1000`
  produces 1970 and usually still renders.
- Treat every optional field as optional. `usageCount` and `expiresAt` are `null`-able in the
  DTO for a reason; a parser that assumes presence throws on the one response that omits it.
- Total odds are the product of the legs, not a sum, and not a field to trust from upstream
  when legs have been filtered.

## What upstream does not require

No auth, no signature, no captcha, no cookies — a plain server-side `fetch` is sufficient.
Code that adds an API key header, a session, or a headless browser is solving a problem this
integration does not have. Flag it as **Consider** and point at `docs/betway-api.md` §8.

Odds drift between encode and decode (2.27 → 2.17 seconds apart) is expected: prices are live.
Code that treats a mismatch as an error, or "corrects" it, has misread the domain.

## Questions worth asking

- What happens if Betway takes 60 seconds to answer? If it returns HTML? A 500? An empty body?
- Is any upstream field name visible above `providers/`?
- Does `isActive` account for all three flags?
- Is anything retried that creates state?
- Would this parser survive a sport other than soccer?

# Testing

Vitest plus Supertest against the Express app object — no port, no network, no live Betway.
`FixturesProvider` backs anything needing upstream data, so tests are deterministic and CI has
no external dependency (`docs/backend.md` §7).

## Shape

- Drive `createApp({ provider, cache, allowedOrigins })` directly. A test that starts a
  listening server is a **Should fix**: it is slower, and it makes parallel runs fight over a
  port for no gain.
- Inject `FixturesProvider` and the no-op cache. A test that reaches the real network is a
  **Blocker** — it fails when Betway is slow, when a code expires, or when CI has no egress,
  and the failure looks like a bug in the code under test.
- Mock at the provider boundary, not by stubbing `fetch`. Stubbing `fetch` couples the test to
  how the provider makes requests; injecting a provider tests the layers that actually matter.

## What deserves a test

In priority order — this is a small service, and coverage percentage is not the goal:

1. **The parser.** Upstream JSON → DTO. Every mapping trap lives here: `eventEpoch` in seconds,
   the three staleness flags collapsing into `isActive`, composite IDs, null-able
   `usageCount`/`expiresAt`. Untested parser is the single highest-value gap in the codebase.
2. **Convert composition.** Drop the requested legs, drop inactive ones, recompute total odds,
   report `droppedCount`. Then the edge case: dropping every leg. If that path is untested, it
   is almost certainly wrong.
3. **One contract test per route** — status and response shape against `docs/backend-api.md`.
4. **The documented error cases**, especially `invalid_code`, a timeout, and the retry-once
   behaviour on `resolve`.

## What does not

Controllers that only forward, the Zod schemas themselves (testing that a library validates is
testing the library), and getters. Tests over trivial code inflate the count and make the suite
slower to run and duller to read — flag as **Nit**, at most once.

## Smells

- Assertions on a whole response object with `toEqual` where only two fields matter: the test
  fails on every unrelated addition and teaches nothing when it does.
- No test for the failure path. A handler with only a happy-path test is a **Should fix**; the
  error paths are where a proxy service actually spends its incidents.
- Shared mutable state between tests — a module-level cache, a provider retaining
  `lastSuccessAt` — producing order-dependent passes.
- Hand-written fixture JSON. Capture real responses into `apps/api/fixtures/` instead
  (`Widget/BookingCodes` returns 120 always-valid live codes). Hand-written fixtures drift from
  the real shape and quietly stop exercising the parser.
- A test asserting current behaviour rather than intended behaviour — it will pin the bug in
  place.

## Questions worth asking

- Does this suite pass with the network unplugged?
- Which upstream field would I have to break to make a test fail?
- Is the empty-slip Convert case covered?
- Does any test depend on the order the others ran in?
- Is this fixture real, or imagined?

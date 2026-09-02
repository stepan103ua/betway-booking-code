---
description: Implement one API endpoint end to end, in the order this codebase requires
argument-hint: [method and path, e.g. POST /api/booking-codes/resolve]
---

Implement `$1`, following the order below. Do not skip step 1 — the contract already exists,
and inventing a second version of it is the most expensive mistake available here.

## 1. Read the contract

Find the endpoint in `docs/backend-api.md`. Note its exact request shape, response DTO, error
cases, upstream endpoint, and cache decision. If it is not in the doc, stop and ask: either it
is out of scope, or the doc needs updating first.

Then read the upstream section it points at in `docs/betway-api.md` — the payload, the API
version (`FindBookABet` is v2, `BookABet` is v1), and the response fields to map.

## 2. Schema — `src/schemas/`

A Zod schema for the body or query. Include bounds Betway does not enforce; our endpoint must
not be a wider door than theirs. Error messages here are shown to users verbatim, so write
them as sentences, not as type assertions.

## 3. Route — `src/routes/`

Path, method, validation middleware, controller handler. Nothing else — no logic, no upstream
call, no try/catch.

## 4. Controller — `src/controllers/`

Read the validated body, call one service method, send the result. Throw on failure; never
build an error response.

## 5. Service — `src/services/`

The logic. Owns the cache decision: reads go through `cache.cached(key, ttl, fn)` with a key
namespaced by endpoint and input; writes never cache. Pick the TTL from how fast the data
actually moves, and say why in a comment if it is not obvious.

## 6. Provider — `src/providers/`

Add the method to `BookingCodeProvider` first, then implement it in **both** `betway.provider.ts`
and `fixtures.provider.ts`. Normalisation lives here: Betway's field names must not escape this
file. Set a timeout on every fetch and map an abort to `upstream_timeout`.

If the fixtures implementation needs data, capture it from a real upstream response into
`apps/api/fixtures/` rather than hand-writing JSON — hand-written fixtures drift from the real
shape and quietly stop testing the parser.

## 7. Test — `tests/`

Supertest against the app object with `FixturesProvider`, no network. One contract test for
the response shape, plus a test for each error case the doc lists. If the endpoint has a
parser or a composition step, unit-test that separately — it is where the bugs live.

## 8. Verify

```bash
npm run typecheck && npm run lint && npm test
```

Then re-read the endpoint's section in `docs/backend-api.md` and check the implementation
against it field by field. If you learned something new about upstream behaviour along the
way, write it into `docs/betway-api.md`.

Finally, report what you built: the cache key and TTL you chose, any error case the doc did
not anticipate, and anything you had to decide that the doc left open.

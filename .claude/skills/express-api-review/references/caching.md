# Caching — Redis as a cache and nothing else

Policy is in `docs/backend.md` §5. The primary reason for the cache is **not** latency: Betway
publishes no rate limit, and this is the only defence against tripping one during a demo or a
burst of clicks. Latency is the secondary benefit. That ordering decides several trade-offs
below.

## Keys

- Namespaced by endpoint and input: `resolve:{code}`, `events:{sport}`, `sports`. A bare input
  as a key (`BW6E19810C`) is a **Should fix** — collisions across endpoints are silent and
  produce a wrong response, not an error.
- Normalize before keying. Booking codes are case-insensitive upstream, so `bw6e...` and
  `BW6E...` must hit the same entry or the cache silently halves its own hit rate. The Zod
  schema already uppercases; check that nothing keys off the raw body.
- Anything user-supplied in a key needs bounds, which validation should already have enforced.

## TTLs

Match the TTL to how fast the underlying data actually moves:

| Data | TTL | Why |
|---|---|---|
| sport list | ~1h | a reference list, changes about never |
| resolve, events | 30–60s | live odds |
| popular codes | ~60s | refreshed continuously upstream |

A single shared TTL constant across all of these is a **Should fix**: it either hammers
upstream for static data or serves stale prices. A TTL long enough that a user sees odds that
have visibly moved is worse than a cache miss.

## What must never be cached

`POST /api/booking-codes` and `POST /api/booking-codes/convert` are writes. Each must reach
Betway. Caching an encode would hand two different users the same code for different slips —
a **Blocker**, and a subtle one, since it looks like it works.

Convert's internal `resolve` step may use the cached read. Its `encode` step may not.

## Failure behaviour

The cache is fail-open by design: a Redis error is logged and the request continues to
upstream. A broken cache costs latency and rate-limit headroom, never correctness.

- A cache read wrapped in a try/catch that returns an error to the client is a **Blocker** —
  it converts a degraded dependency into an outage.
- Equally, silence is not free: a cache that has been down for an hour with nothing in the logs
  means the rate-limit defence is gone and nobody knows.
- `await`ing a cache write before responding adds Redis latency to the happy path for no
  benefit. Minor, but worth a **Consider**.

## Shape

- Read-through in one helper (`cached(key, ttl, fn)`), not hand-rolled get/set pairs at each
  call site. Scattered pairs drift: one forgets the TTL, another forgets to handle a miss.
- Cache the **normalized DTO**, not the raw upstream payload. Caching raw shape means every
  read re-parses, and a parser change silently applies to some entries and not others.
- Do not add a second cache layer above Redis — an in-process map, or Next.js `"use cache"` on
  the client. Two caches with different TTLs produce staleness nobody can reason about, and
  `docs/frontend.md` §3 rules this out explicitly.
- Concurrent misses on the same cold key all reach upstream. Acceptable at this scale; worth a
  **Consider** only if a hot key is plausible, never a rewrite in a two-day service.

## Questions worth asking

- What is this key, and can two different inputs produce it?
- Is this TTL derived from how fast the data moves, or copied from the line above?
- Is a write being cached anywhere, directly or through a shared helper?
- What does this endpoint do when Redis is unreachable — degrade, or fail?
- Is the cached value the DTO or the upstream payload?

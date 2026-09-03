import { z } from 'zod';

/**
 * The offset shared by both list endpoints.
 *
 * Defined once because the *reason* for the bound is the same in both places and easy to get
 * wrong: `skip` lands in a Redis key (`events:{sport}:{skip}:{limit}`, `popular:{skip}:{limit}`),
 * so an unbounded value is unbounded key cardinality — every distinct one is a fresh cache
 * entry and a fresh upstream call, and nothing converges. The rate limiter caps how *fast* a
 * caller can mint them, not how many.
 *
 * `hasMore` and `total` tell a well-behaved client where to stop. They do nothing about a
 * careless or hostile one, which is what this is for.
 *
 * The ceiling is deliberately far past any real corpus — 50 pages of events, eight times the
 * code catalogue — rather than an attempt to track either. It exists to refuse nonsense, not
 * to describe the data.
 */
export const MAX_SKIP = 1_000;

export const skipField = z.coerce
  .number({ error: 'skip must be a number.' })
  .int('skip must be a whole number.')
  .min(0, 'skip cannot be negative.')
  .max(MAX_SKIP, `skip cannot be more than ${MAX_SKIP}.`)
  .default(0);

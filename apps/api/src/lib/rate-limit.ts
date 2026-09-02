import rateLimit from 'express-rate-limit';

import type { ApiError } from '@booking-code/contracts';

/**
 * Rate limiting protects Betway from being hammered *through* us, which matters more here
 * than protecting ourselves: Betway publishes no rate limit, and this service is an
 * unauthenticated proxy in front of it (docs/backend.md §6).
 *
 * The limiter answers in the same `ApiError` shape as everything else — a 429 is not a
 * special case with its own body.
 *
 * In-memory store, so the counter is per-process. Fine for a single instance; a multi-instance
 * deploy would move the store to the Redis connection we already have.
 */
export function createRateLimiter() {
  const body: ApiError = {
    error: 'rate_limited',
    message: 'Too many requests. Please slow down and try again shortly.',
  };

  return rateLimit({
    windowMs: 60_000,
    limit: 60,
    standardHeaders: 'draft-7',
    legacyHeaders: false,
    message: body,
  });
}

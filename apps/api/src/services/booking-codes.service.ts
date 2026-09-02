import type { ConvertResult, PopularBookingCode, Slip } from '@booking-code/contracts';

import { AppError, isAppError } from '../lib/errors.js';
import type { Cache } from '../lib/redis.js';
import type { BookingCodeProvider } from '../providers/booking-code-provider.js';

/**
 * Business logic: the provider fetches and normalises, the controller only maps HTTP in and
 * out, and cache policy lives here.
 *
 * Still TODO — create, convert and popular:
 *
 *   - **Convert.** Not an upstream call. `resolve` → drop `dropOutcomeIds` and anything with
 *     `isActive: false` → `encode` the rest → return both codes and both totals
 *     (docs/backend-api.md §1). Recompute `totalOdds` from the kept legs; do not carry the
 *     original total forward.
 *   - **The empty-slip case.** Dropping every leg leaves nothing to encode. Decide what that
 *     returns before writing the happy path — it is the edge case a reviewer will reach for.
 */

/**
 * The conservative end of the 30–60s the docs allow (docs/backend.md §5).
 *
 * Odds move continuously — a code created at 2.27 decoded at 2.17 seconds later during
 * research — so this is the window in which a cached slip can misreport a price. The cache's
 * primary job is rate-limit headroom rather than latency, and 30s already absorbs almost all
 * of a burst: a code decoded once is free for everyone else for the next half minute.
 */
const RESOLVE_TTL_SECONDS = 30;

/**
 * What goes in the cache for a resolve: the slip, or the fact that there is no slip.
 *
 * Caching the miss matters because a booking code is the one input a caller fully controls,
 * and a miss is the *more* expensive answer to produce — the retry means an unknown code costs
 * two upstream calls, not one. Leaving misses uncached would let a stream of junk codes
 * amplify straight through to Betway, which is exactly what the cache is there to prevent
 * (docs/backend.md §5).
 *
 * The cost of caching a miss is that a transient false negative gets pinned for the TTL. The
 * retry in `betway.provider.ts` already makes that unlikely — upstream would have to fail
 * twice in a row — and 30s bounds it. If it ever proves annoying in practice, a shorter TTL
 * for misses is the fix, not dropping the negative cache.
 */
type CachedResolve = { found: true; slip: Slip } | { found: false };

export class BookingCodesService {
  constructor(
    private readonly provider: BookingCodeProvider,
    private readonly cache: Cache,
  ) {}

  /**
   * Decode a booking code.
   *
   * The code arrives already uppercased by the Zod schema, so `bw6e...` and `BW6E...` share a
   * cache entry instead of silently halving the hit rate — Betway treats codes as
   * case-insensitive (docs/betway-api.md §2).
   */
  async resolve(code: string): Promise<Slip> {
    const result = await this.cache.cached<CachedResolve>(
      `resolve:${code}`,
      RESOLVE_TTL_SECONDS,
      async () => {
        try {
          return { found: true, slip: await this.provider.resolve(code) };
        } catch (error) {
          if (isAppError(error) && error.code === 'invalid_code') return { found: false };
          // Everything else — a timeout, a 502, an unreadable body — is a fact about Betway
          // right now, not about this code. Caching it would keep answering with a failure
          // that may already have cleared.
          throw error;
        }
      },
    );

    if (!result.found) throw AppError.invalidCode();
    return result.slip;
  }

  async create(_outcomeIds: string[]): Promise<string> {
    throw AppError.notImplemented('Create');
  }

  async convert(_code: string, _dropOutcomeIds: string[]): Promise<ConvertResult> {
    throw AppError.notImplemented('Convert');
  }

  async popular(_limit: number): Promise<PopularBookingCode[]> {
    throw AppError.notImplemented('Popular codes');
  }
}

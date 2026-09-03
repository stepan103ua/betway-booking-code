import type { ConvertResult, PopularBookingCode, Slip } from '@booking-code/contracts';

import { AppError, isAppError } from '../lib/errors.js';
import { logger } from '../lib/logger.js';
import type { Cache } from '../lib/redis.js';
import type { BookingCodeProvider } from '../providers/booking-code-provider.js';

/**
 * Business logic: the provider fetches and normalises, the controller only maps HTTP in and
 * out, and cache policy lives here.
 *
 * Still TODO — convert and popular:
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

  /**
   * Encode a set of selections into a new code, then check the code actually contains them.
   *
   * **The second call is not belt-and-braces, it is the feature.** `BookABet` accepts outcome
   * ids that are no longer bettable, silently drops them, and still returns a well-formed code
   * (docs/betway-api.md §3). Ask it for one dead selection and you get a code containing
   * nothing — which `/resolve` then answers 404 for, because a slip with no legs is not a slip.
   *
   * That is not a hand-crafted-request edge case. The soccer feed is largely eSoccer, kicking
   * off every ~15 minutes, so an outcome can die between a user opening the picker and pressing
   * create. Shape validation cannot see it: the id is perfectly well-formed, it is just dead.
   *
   * The cost is one extra upstream call on the rarest operation, and it is paid back in part —
   * the verification populates the resolve cache, so the client's next call is a hit.
   *
   * **Never cached.** Caching the result would hand two callers the same code for different
   * slips; caching by input would hand back a code created minutes ago with moved odds. It is
   * a write, and writes reach Betway (docs/backend.md §5).
   */
  async create(outcomeIds: string[]): Promise<string> {
    const bookingCode = await this.provider.encode(outcomeIds);

    const slip = await this.verify(bookingCode);
    // Verification itself failed — a timeout, a 502. The code probably exists, so returning it
    // beats telling the caller their create failed when it may well have worked.
    if (slip === null) return bookingCode;

    const created = new Set(slip.selections.map((selection) => selection.outcomeId));
    const dropped = outcomeIds.filter((outcomeId) => !created.has(outcomeId));

    if (dropped.length > 0) {
      // Failing beats returning a code quietly missing legs: the user believes they booked a
      // slip they did not. Dropping legs on purpose is what `/convert` is for.
      throw new AppError(
        'outcomes_unavailable',
        dropped.length === outcomeIds.length
          ? 'Those selections are no longer available. Refresh and pick again.'
          : `${dropped.length} of your ${outcomeIds.length} selections are no longer available.`,
      );
    }

    return bookingCode;
  }

  /** Reads back a code just created. `null` means we could not tell, not that it is empty. */
  private async verify(bookingCode: string): Promise<Slip | null> {
    try {
      return await this.resolve(bookingCode);
    } catch (error) {
      // A code containing nothing decodes to nothing, which `toSlip` reports as invalid_code.
      if (isAppError(error) && error.code === 'invalid_code') {
        return { bookingCode, totalOdds: 1, expiresAt: null, usageCount: null, selections: [] };
      }

      logger.warn('could not verify a newly created code', { code: bookingCode });
      return null;
    }
  }

  async convert(_code: string, _dropOutcomeIds: string[]): Promise<ConvertResult> {
    throw AppError.notImplemented('Convert');
  }

  async popular(_limit: number): Promise<PopularBookingCode[]> {
    throw AppError.notImplemented('Popular codes');
  }
}

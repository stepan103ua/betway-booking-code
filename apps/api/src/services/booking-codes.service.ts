import type { ConvertResult, PopularPage, Slip } from '@booking-code/contracts';

import { mapLimited } from '../lib/concurrency.js';
import { AppError, isAppError } from '../lib/errors.js';
import { logger } from '../lib/logger.js';
import { totalOdds } from '../lib/odds.js';
import type { Cache } from '../lib/redis.js';
import type { BookingCodeProvider } from '../providers/booking-code-provider.js';

/**
 * Business logic: the provider fetches and normalises, the controller only maps HTTP in and
 * out, and cache policy lives here.
 *
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

/**
 * The doc's number (docs/backend.md §5). Twice `RESOLVE_TTL_SECONDS`, so odds inside a cached
 * list can be up to a minute old — acceptable on a browse surface, and the alternative is
 * re-running a fan-out that costs one upstream call per code.
 */
const POPULAR_TTL_SECONDS = 60;

/** Decodes in flight while enriching the catalogue. Enough to be quick, few enough to be polite. */
const POPULAR_CONCURRENCY = 4;

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
    const { bookingCode } = await this.encodeVerified(outcomeIds, (dropped) =>
      dropped === outcomeIds.length
        ? 'Those selections are no longer available. Refresh and pick again.'
        : `${dropped} of your ${outcomeIds.length} selections are no longer available.`,
    );

    return bookingCode;
  }

  /**
   * Reissue a code for the same bet, minus the legs asked for and minus anything already dead.
   *
   * Betway has no convert endpoint — this is `resolve` → filter → `encode`, composed here
   * (docs/architecture.md §3). The read is allowed to come from cache; the encode is a write
   * and never does.
   *
   * The result is the **decoded new code**, not the old slip with legs removed. That matters
   * because prices move between the two calls — a leg resolved at 2.27 can encode and decode
   * at 2.17 (docs/betway-api.md §3) — so recomputing from the old slip would report a total
   * the new code does not have. `previousTotalOdds` carries the before side of the diff.
   */
  async convert(code: string, dropOutcomeIds: string[]): Promise<ConvertResult> {
    const original = await this.resolve(code);

    const drop = new Set(dropOutcomeIds);
    // Ids that are not in the slip are ignored rather than rejected: the client is describing
    // what it wants gone, and a leg that is already absent is not an error.
    const kept = original.selections.filter(
      (selection) => !drop.has(selection.outcomeId) && selection.isActive,
    );

    if (kept.length === 0) {
      // `ConvertResult.bookingCode` is not nullable, so there is no 200 that honestly says
      // "nothing left". A 400 the client can render beats inventing a shape.
      throw new AppError(
        'empty_slip',
        drop.size > 0
          ? 'Dropping those leaves nothing to convert.'
          : 'None of the selections in that code can still be bet.',
      );
    }

    const { bookingCode, slip } = await this.encodeVerified(
      kept.map((selection) => selection.outcomeId),
      // Different advice from `create`'s: this caller supplied a code, not a set of picks, so
      // there is nothing for them to go and re-pick. Converting again is the fix — the leg that
      // just died will be filtered by `isActive` on the next pass.
      (dropped) =>
        dropped === kept.length
          ? 'Those selections went off while the code was being converted. Try again.'
          : `${dropped} of the ${kept.length} remaining selections went off while the code was being converted. Try again.`,
    );

    return {
      // Falls back to the kept legs when the read-back was inconclusive — same reasoning as
      // `create`: an unverifiable code is probably still a good one. Note the after-side of the
      // diff is then our best knowledge as of the resolve, not something we confirmed.
      ...(slip ?? {
        bookingCode,
        totalOdds: totalOdds(kept),
        expiresAt: null,
        usageCount: null,
        selections: kept,
      }),
      previousBookingCode: original.bookingCode,
      previousTotalOdds: original.totalOdds,
      // Every leg that is not in the new code, whether the client asked or it was already dead.
      droppedCount: original.selections.length - kept.length,
    };
  }

  /**
   * Encode, then read the code back and check it contains what was asked for.
   *
   * `BookABet` accepts outcome ids that are no longer bettable, drops them silently, and still
   * returns a well-formed code (docs/betway-api.md §3). Both callers need that caught, and
   * Convert needs the decoded slip as well — returning it here saves a second read, since the
   * verification has already populated the resolve cache.
   *
   * A `null` slip means verification was inconclusive, not that the code is empty.
   */
  private async encodeVerified(
    outcomeIds: string[],
    describeDropped: (dropped: number) => string,
  ): Promise<{ bookingCode: string; slip: Slip | null }> {
    const bookingCode = await this.provider.encode(outcomeIds);
    const verified = await this.verify(bookingCode);

    if (verified === null) return { bookingCode, slip: null };

    // Failing beats returning a code quietly missing legs: the user believes they booked a slip
    // they did not. Dropping legs on purpose is what `/convert` is for. The message comes from
    // the caller because only it knows what the user was doing, and these render verbatim.
    if (verified === 'empty') {
      throw new AppError('outcomes_unavailable', describeDropped(outcomeIds.length));
    }

    const created = new Set(verified.selections.map((selection) => selection.outcomeId));
    const dropped = outcomeIds.filter((outcomeId) => !created.has(outcomeId));

    if (dropped.length > 0) {
      throw new AppError('outcomes_unavailable', describeDropped(dropped.length));
    }

    return { bookingCode, slip: verified };
  }

  /**
   * Reads back a code just created. Three outcomes, deliberately distinct types:
   *
   *   - a `Slip` — the code exists and this is what is in it
   *   - `'empty'` — the code exists and contains nothing, so upstream dropped every leg
   *   - `null` — we could not tell, which is not the same as either of the above
   *
   * `'empty'` used to be a fabricated zero-leg `Slip`. That was safe only because both callers
   * happened to reject it first; as a sentinel it was one refactor away from being serialised
   * into a response as a real slip with `totalOdds: 1`.
   */
  private async verify(bookingCode: string): Promise<Slip | 'empty' | null> {
    try {
      return await this.resolve(bookingCode);
    } catch (error) {
      // A code containing nothing decodes to nothing, which `toSlip` reports as invalid_code.
      if (isAppError(error) && error.code === 'invalid_code') return 'empty';

      // Worth an operator's attention: we created something upstream and cannot say what is in
      // it, so any leg count we go on to report is unconfirmed.
      logger.warn('created a booking code but could not read it back', {
        code: bookingCode,
        reason: isAppError(error) ? error.code : 'unknown',
      });
      return null;
    }
  }

  /**
   * The public catalogue, enriched into full slips.
   *
   * Two upstream shapes joined, because neither is enough alone. The catalogue carries
   * `expiryDateTime` and a usage count but **no odds at all** — so `totalOdds` and the
   * selections need one decode per code. Going the other way, decoding never reports an expiry
   * or a use count. This is the only endpoint where a `Slip` comes back with `expiresAt` and
   * `usageCount` populated, and joining the two is the whole reason it costs what it costs.
   *
   * The enrichment goes through `this.resolve`, not the provider directly, so every decode
   * lands under `resolve:{code}` and is shared with `/resolve` — a code shown in this list is
   * already cached by the time a user clicks it.
   *
   * Order is upstream's: the catalogue arrives sorted by usage, descending, so dropping the
   * codes that fail preserves it and nothing here sorts.
   *
   * **Pages can come back short.** Roughly one catalogue code in eight is expired, and once
   * `skip` is a client-visible offset there is no way to quietly over-fetch and top a page up —
   * doing so consumes rows that the next `skip` would then re-read or jump past. `total` and
   * `hasMore` are the honest signals instead, both derived from catalogue offsets rather than
   * from how many codes survived.
   */
  async popular(limit: number, skip: number): Promise<PopularPage> {
    return this.cache.cached(`popular:${skip}:${limit}`, POPULAR_TTL_SECONDS, async () => {
      const { codes: rows, total } = await this.provider.popularCodes(limit, skip);

      const enriched = await mapLimited(
        rows,
        POPULAR_CONCURRENCY,
        async (row): Promise<Slip | null> => {
          try {
            return {
              ...(await this.resolve(row.bookingCode)),
              // The catalogue's two fields win: the decode always reports them as null.
              expiresAt: row.expiresAt,
              usageCount: row.usageCount,
            };
          } catch (error) {
            // An expired or withdrawn code is an ordinary state of this list, so it is dropped
            // and the page comes back short. Anything else — a timeout, a 502 — is a fact about
            // Betway rather than about this code, and swallowing it would dress an outage up as
            // a thin page. The same distinction `resolve` draws for its negative cache.
            if (isAppError(error) && error.code === 'invalid_code') return null;
            throw error;
          }
        },
      );

      return {
        codes: enriched.filter((slip): slip is Slip => slip !== null),
        skip,
        limit,
        total,
        // Driven by catalogue offsets, not by how many survived: a page that lost two codes to
        // expiry is still followed by another, and deriving this from `codes.length` would stop
        // paging early.
        hasMore: skip + limit < total,
      };
    });
  }
}

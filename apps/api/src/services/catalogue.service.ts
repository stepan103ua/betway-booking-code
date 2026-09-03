import type { EventsPage, Market, Sport } from '@booking-code/contracts';

import { AppError } from '../lib/errors.js';
import type { Cache } from '../lib/redis.js';
import type { BookingCodeProvider } from '../providers/booking-code-provider.js';

/**
 * Browse — the sport, fixture and market lists the Create screen picks from.
 *
 * All three are cached reads, and the TTLs differ by an order of magnitude because the data
 * does: the sport list is reference data that changes about never, while anything carrying a
 * price is stale within a minute. One TTL for both would either hammer upstream for static
 * data or serve stale odds (docs/backend.md §5).
 */

/** Reference data. An hour is the doc's number and still far more often than it changes. */
const SPORTS_TTL_SECONDS = 3_600;

/**
 * Matches `RESOLVE_TTL_SECONDS` in `booking-codes.service.ts`, for the same reason: odds move
 * continuously, so this is the window in which a cached price can be wrong. The cache is here
 * for rate-limit headroom more than latency, and 30s already absorbs most of a burst.
 */
const ODDS_TTL_SECONDS = 30;

export class CatalogueService {
  constructor(
    private readonly provider: BookingCodeProvider,
    private readonly cache: Cache,
  ) {}

  async sports(): Promise<Sport[]> {
    return this.cache.cached('sports', SPORTS_TTL_SECONDS, () => this.provider.sports());
  }

  /**
   * `skip` and `limit` are both in the cache key rather than sliced after the fact. Caching one
   * large page and slicing would raise the hit rate, but it makes every miss the most expensive
   * call available — and it cannot work at all now that the client chooses its own offset.
   *
   * `hasMore` comes from the provider, which reads upstream's `isFinalPage`. This feed reports
   * no total, so unlike the code catalogue there is nothing to count against.
   */
  async events(sportId: string, limit: number, skip: number): Promise<EventsPage> {
    const page = await this.cache.cached(
      `events:${sportId}:${skip}:${limit}`,
      ODDS_TTL_SECONDS,
      () => this.provider.upcomingEvents(sportId, limit, skip),
    );

    return { ...page, skip, limit };
  }

  /**
   * Upstream answers an unknown event with `200` and empty arrays rather than a 404, so an
   * empty list is the only signal we get and it has to become one here. Returning `200 []`
   * would render an event page with no way to bet on it and no explanation.
   */
  async eventMarkets(eventId: string): Promise<Market[]> {
    const markets = await this.cache.cached(`markets:${eventId}`, ODDS_TTL_SECONDS, () =>
      this.provider.eventMarkets(eventId),
    );

    if (markets.length === 0) {
      throw new AppError('not_found', 'No markets found for this event.');
    }

    return markets;
  }
}

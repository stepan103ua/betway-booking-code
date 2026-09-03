import type { Fixture, Market, Slip, Sport } from '@booking-code/contracts';

/**
 * The one seam in the system.
 *
 * Services depend on this interface, never on `betway.provider.ts` directly. Swapping the
 * live provider for the fixtures one is a single line at the composition root (`index.ts`),
 * not a rewrite — which is what makes "what if Betway is down during the demo" a
 * configuration question rather than an outage (docs/backend.md §3).
 *
 * Everything crossing this boundary is already one of our own DTOs. Normalisation —
 * `priceDecimal` → `odds`, `eventEpoch` → ISO `kickoffAt`, the three staleness flags → one
 * `isActive` — happens *inside* an implementation. A provider that returned Betway's shape
 * and left the mapping to a service would put upstream detail into shared code, and that is
 * the exact coupling this interface exists to prevent.
 *
 * Note there is no `convert`: Betway has no such endpoint. Convert is resolve → filter →
 * encode, composed in the service layer (docs/backend-api.md §1).
 */
export interface BookingCodeProvider {
  /** Decode a booking code. Throws `AppError('invalid_code')` when upstream has no slip. */
  resolve(code: string): Promise<Slip>;

  /** Encode a set of outcomes into a new booking code. */
  encode(outcomeIds: string[]): Promise<string>;

  /**
   * The public catalogue of live codes, for the Decode empty state.
   *
   * Returns catalogue rows only. Turning one into a full `Slip` needs a decode per code, and
   * that composition belongs in the service (`docs/backend-api.md` §1) — the same place
   * Convert lives, and for the same reason.
   */
  popularCodes(limit: number): Promise<CatalogueCode[]>;

  /** Reference list of sports. Slow-moving. */
  sports(): Promise<Sport[]>;

  /** Upcoming fixtures for a sport, with the 1X2 market inline. */
  upcomingEvents(sportId: string, take: number): Promise<Fixture[]>;

  /**
   * Every market for one event, not just 1X2. Empty when the event is unknown — upstream
   * answers 200 with empty arrays rather than 404ing, so "no such event" and "no markets"
   * are the same answer here and the service decides what that means.
   */
  eventMarkets(eventId: string): Promise<Market[]>;

  /**
   * ISO timestamp of the last successful upstream call, or null if none yet.
   * Reported by `GET /api/health` (docs/backend-api.md §3).
   */
  lastSuccessAt(): string | null;
}

/**
 * One row of the public catalogue.
 *
 * Deliberately **not** in `packages/contracts`: no client ever sees this shape. It is an
 * intermediate the service enriches into a `Slip`, and the contracts package is the
 * client-facing surface only.
 *
 * These two fields are the whole reason the catalogue is worth calling at all — `FindBookABet`
 * reports neither, so this is the only route to a non-null `Slip.expiresAt` / `usageCount`.
 */
export type CatalogueCode = {
  bookingCode: string;
  /** ISO 8601. Upstream sends an offset datetime with sub-second precision. */
  expiresAt: string | null;
  usageCount: number;
};

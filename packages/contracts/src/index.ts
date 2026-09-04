/**
 * The API contract, defined once.
 *
 * These are the shapes in `docs/backend-api.md` §0. Every response the API sends is one of
 * them, and no consumer redeclares them by hand — `apps/web` imports this file, and the Dart
 * models in `apps/mobile` mirror it.
 *
 * The point of the package is the boundary it draws: **Betway's field names never appear
 * here.** `priceDecimal` becomes `odds`, `eventEpoch` becomes an ISO `kickoffAt`, and the
 * three separate staleness flags collapse into one `isActive`. Everything upstream-specific
 * stays behind `BookingCodeProvider` in `apps/api`. That is what makes a second bookmaker a
 * new provider rather than a new API.
 *
 * Type declarations only — no runtime code. Consumers use `import type`, which TypeScript
 * erases at compile time, so this package never ships anything to production.
 */

/** One pick on a slip. */
export type Selection = {
  outcomeId: string;
  /**
   * The event this pick is on. A booking code is a plain accumulator, so two selections that
   * share an `eventId` conflict — Betway mints a code from them anyway, but it fails betslip
   * validation ("conflicting selections, please revise"). `POST /api/booking-codes` and
   * `/convert` reject such a slip; see `docs/betway-api.md` §3.
   */
  eventId: string;
  marketName: string;
  outcomeName: string;
  eventName: string;
  league: string;
  /** ISO 8601. Upstream sends unix seconds; the provider converts. */
  kickoffAt: string;
  /** Decimal odds. */
  odds: number;
  /**
   * False when the market, event or outcome has gone inactive upstream — a leg that can no
   * longer be bet. Convert drops these by default.
   */
  isActive: boolean;
};

/** A decoded booking code: what the code contains. */
export type Slip = {
  bookingCode: string;
  totalOdds: number;
  /**
   * ISO 8601, or null. Non-null only from `GET /api/booking-codes/popular` — decoding a code
   * does not report an expiry, the public catalogue does, and that endpoint is the one place
   * the two are joined.
   */
  expiresAt: string | null;
  /** How many times the code has been used. Non-null on the same terms as `expiresAt`. */
  usageCount: number | null;
  selections: Selection[];
};

/** An upcoming event with its markets inline — everything the Create picker needs. */
export type Fixture = {
  eventId: string;
  name: string;
  league: string;
  /** ISO 8601. */
  kickoffAt: string;
  /**
   * `GET /api/events` fills this with the 1X2 market only; `GET /api/events/:eventId/markets`
   * returns the full set. A list rather than a `market1x2` key because a market's name is
   * data, not schema — and because upstream can return the same market type twice for one
   * event (two Totals on different lines), which a keyed object could not represent.
   */
  markets: Market[];
};

export type Market = {
  marketId: string;
  /** Fully qualified and ready to display: `"1X2"`, `"Total (6.5)"`. */
  name: string;
  /**
   * Stable machine key — branch on this, never on `name` or on the numeric part of an id.
   * `"win-draw-win"`, `"double-chance"`, `"handicap-goals-over"`. Not unique within an event:
   * two Totals on different lines share a type and differ by `name` and `marketId`.
   */
  type: string;
  /**
   * Ordered as upstream ranks them. For `win-draw-win` that is home, draw, away — which is
   * where a 1/X/2 picker gets its column order, since no outcome says "Home" itself.
   */
  outcomes: MarketOutcome[];
};

export type MarketOutcome = {
  outcomeId: string;
  /** What upstream calls this outcome: a team name, `"Draw"`, `"Over"`. */
  label: string;
  /** Decimal odds. */
  odds: number;
};

/**
 * A page of a list endpoint.
 *
 * `hasMore` rather than a total, because the two upstreams report their extent differently:
 * the code catalogue sends a count, the event feed sends only an `isFinalPage` flag. Both can
 * answer "is there another page", which is the question a "load more" button actually asks —
 * so that is what crosses the boundary, and neither upstream's shape leaks through.
 */
export type PageInfo = {
  /** Offset of the first item, echoed from the request. */
  skip: number;
  /** Whether asking again at `skip + <page size>` would return anything. */
  hasMore: boolean;
};

/** `GET /api/events` — one page of fixtures. */
export type EventsPage = PageInfo & {
  events: Fixture[];
  limit: number;
};

/** `GET /api/booking-codes/popular` — one page of enriched slips. */
export type PopularPage = PageInfo & {
  codes: Slip[];
  limit: number;
  /** How many codes the catalogue holds in total. Available here; the event feed has no equivalent. */
  total: number;
};

/** The full market list for one event. */
export type EventMarkets = {
  eventId: string;
  markets: Market[];
};

/**
 * Convert's response: a Slip, plus what changed relative to the code it started from.
 *
 * Convert is not an upstream endpoint. It is resolve → filter → encode, composed server-side
 * (`docs/backend-api.md` §1), which is why the result carries both codes.
 */
export type ConvertResult = Slip & {
  previousBookingCode: string;
  previousTotalOdds: number;
  droppedCount: number;
};

/** A newly created booking code. */
export type CreatedBookingCode = {
  bookingCode: string;
};

export type Sport = {
  id: string;
  name: string;
};

export type HealthStatus = {
  status: 'ok' | 'degraded';
  redis: 'ok' | 'down' | 'disabled';
  /** ISO 8601 timestamp of the last successful upstream call, or null if none yet. */
  betwayLastSuccessAt: string | null;
};

/**
 * The one shape every non-2xx response uses, from every endpoint — validation failures,
 * upstream errors and internal errors alike. No endpoint returns a differently-shaped error
 * body, and no raw upstream error code ever reaches a client.
 */
export type ApiError = {
  /** Stable, machine-readable, safe to branch on. e.g. "invalid_code". */
  error: string;
  /** Human-readable and safe to render in a UI. */
  message: string;
};

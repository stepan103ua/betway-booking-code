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
  /** ISO 8601, or null when upstream does not report an expiry for this code. */
  expiresAt: string | null;
  /** How many times the code has been used, when upstream reports it. */
  usageCount: number | null;
  selections: Selection[];
};

/** An upcoming event with its 1X2 market inline — everything the Create picker needs. */
export type Fixture = {
  eventId: string;
  name: string;
  league: string;
  /** ISO 8601. */
  kickoffAt: string;
  market1x2: Market1x2Outcome[];
};

export type Market1x2Outcome = {
  outcomeId: string;
  label: 'Home' | 'Draw' | 'Away';
  odds: number;
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

/** One entry in the public catalogue that feeds the Decode empty state. */
export type PopularBookingCode = {
  bookingCode: string;
  selectionCount: number;
  totalOdds: number;
  usageCount: number;
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

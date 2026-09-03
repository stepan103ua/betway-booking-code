/**
 * The error vocabulary of this API.
 *
 * Every failure anywhere in the stack becomes an `AppError` with one of these codes, and the
 * error middleware turns it into the single `ApiError` body from docs/backend-api.md §0. Two
 * consequences worth stating plainly:
 *
 *   - No raw Betway error code (`BookABetInvalidCode`, `6000331`) ever reaches a client.
 *   - No endpoint returns a differently-shaped error body.
 *
 * `message` is written to be shown to a user as-is. Anything a user should not see —
 * upstream response bodies, stack traces, connection strings — belongs in `cause`, which is
 * logged and never serialised.
 */

/** Machine-readable codes. Clients may branch on these; they are part of the contract. */
export const ERROR_CODES = {
  /** Request body or query failed validation. */
  invalid_request: 400,
  /** Booking code is well-formed but upstream has no slip for it. */
  invalid_code: 404,
  /** More selections than this API accepts. See docs/backend-api.md §1. */
  too_many_outcomes: 400,
  /**
   * One or more selections were no longer bettable by the time the code was created. Upstream
   * accepts them silently and drops them, so this is detected after the fact — see
   * `BookingCodesService.create`.
   */
  outcomes_unavailable: 400,
  not_found: 404,
  rate_limited: 429,
  /** Route exists in the contract but is not built yet. */
  not_implemented: 501,
  /** Betway returned something unusable, or did not answer in time. */
  upstream_error: 502,
  upstream_timeout: 504,
  internal_error: 500,
} as const;

export type ErrorCode = keyof typeof ERROR_CODES;

export class AppError extends Error {
  readonly code: ErrorCode;
  readonly status: number;

  constructor(code: ErrorCode, message: string, options?: { cause?: unknown }) {
    super(message, options);
    this.name = 'AppError';
    this.code = code;
    this.status = ERROR_CODES[code];
  }

  static invalidCode(): AppError {
    return new AppError('invalid_code', 'No slip found for this code.');
  }

  static notImplemented(what: string): AppError {
    return new AppError('not_implemented', `${what} is not implemented yet.`);
  }

  static upstream(message: string, cause?: unknown): AppError {
    return new AppError('upstream_error', message, { cause });
  }
}

export function isAppError(error: unknown): error is AppError {
  return error instanceof AppError;
}

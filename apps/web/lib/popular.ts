import type { Slip } from '@booking-code/contracts';

/** Page size for the popular list — the API's own default, and what the empty state shows. */
export const POPULAR_PAGE = 6;

/**
 * Append a fetched page, dropping any code already in the list. The catalogue is sorted by
 * usage and pages don't overlap in normal operation, but a code can be re-listed across a
 * TTL boundary — de-duping by `bookingCode` keeps the `key` stable and the list honest.
 */
export function mergeCodes(prev: Slip[], next: Slip[]): Slip[] {
  const seen = new Set(prev.map((c) => c.bookingCode));
  return [...prev, ...next.filter((c) => !seen.has(c.bookingCode))];
}

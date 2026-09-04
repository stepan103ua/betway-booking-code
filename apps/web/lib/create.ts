import type { EventMarkets, EventsPage, Sport } from '@booking-code/contracts';
import { ApiRequestError, apiFetch } from '@/lib/api';

// Server-only (reads `API_URL`). Client code imports the *types* from here — those erase —
// and calls the wrappers in `app/actions.ts`, never these functions directly.

/** Page size for the fixture list — the endpoint's own default (docs/backend-api.md §2). */
export const EVENTS_PAGE = 20;

/** `GET /api/sports`. `null` on failure — the Create screen shows a retry, not a crash. */
export async function getSports(): Promise<Sport[] | null> {
  try {
    const { sports } = await apiFetch<{ sports: Sport[] }>('/api/sports');
    return sports;
  } catch {
    return null;
  }
}

/** `GET /api/events?sport=&limit=&skip=`. `null` on failure. */
export async function getEventsPage(sport: string, skip = 0): Promise<EventsPage | null> {
  try {
    return await apiFetch<EventsPage>(
      `/api/events?sport=${encodeURIComponent(sport)}&limit=${EVENTS_PAGE}&skip=${skip}`,
    );
  } catch {
    return null;
  }
}

/**
 * `GET /api/events/:id/markets`, ready for the "more markets" sheet. The backend turns
 * "unknown event / nothing priced" into a `404`, which reads as "nothing here", not "the
 * list is empty" — hence a distinct `empty` result.
 */
export type MarketsResult =
  | { kind: 'markets'; markets: EventMarkets['markets'] }
  | { kind: 'empty' }
  | { kind: 'error'; message: string };

export async function getEventMarkets(eventId: string): Promise<MarketsResult> {
  try {
    const { markets } = await apiFetch<EventMarkets>(
      `/api/events/${encodeURIComponent(eventId)}/markets`,
    );
    return { kind: 'markets', markets };
  } catch (err) {
    if (err instanceof ApiRequestError && err.status === 404) return { kind: 'empty' };
    const message =
      err instanceof ApiRequestError ? err.message : 'Could not load markets. Try again.';
    return { kind: 'error', message };
  }
}

/**
 * `POST /api/booking-codes`. The two 400s a user can act on get their own kind — "remove a
 * selection" and "refresh and re-pick" are different UI from "something went wrong". Branch
 * on `error`, not status (packages/contracts).
 */
export type CreateResult =
  | { kind: 'created'; bookingCode: string }
  | { kind: 'too_many'; message: string }
  | { kind: 'unavailable'; message: string }
  | { kind: 'conflicting'; message: string }
  | { kind: 'error'; message: string };

export async function createCode(outcomeIds: string[]): Promise<CreateResult> {
  try {
    const { bookingCode } = await apiFetch<{ bookingCode: string }>('/api/booking-codes', {
      method: 'POST',
      body: JSON.stringify({ outcomeIds }),
    });
    return { kind: 'created', bookingCode };
  } catch (err) {
    if (err instanceof ApiRequestError) {
      switch (err.code) {
        case 'too_many_outcomes':
          return { kind: 'too_many', message: err.message };
        case 'outcomes_unavailable':
          return { kind: 'unavailable', message: err.message };
        case 'conflicting_selections':
          return { kind: 'conflicting', message: err.message };
        default:
          return { kind: 'error', message: err.message };
      }
    }
    return { kind: 'error', message: 'Could not reach the service. Try again in a moment.' };
  }
}

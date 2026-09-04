import type { ConvertResult } from '@booking-code/contracts';
import { ApiRequestError, apiFetch } from '@/lib/api';

// Server-only (reads `API_URL`). Client code imports the *type* from here and calls the
// wrapper in `app/actions.ts`, never this function directly.

/**
 * `POST /api/booking-codes/convert` — resolve → drop legs → reissue. The errors a user can
 * act on get their own kind: `empty`/`unavailable`/`conflicting` say what to do, everything
 * else is generic. Branch on `error`, not status (packages/contracts). A `404 invalid_code`
 * cannot happen here — the code was already resolved by the route to reach the picker.
 */
export type ConvertActionResult =
  | { kind: 'converted'; result: ConvertResult }
  | { kind: 'empty'; message: string }
  | { kind: 'unavailable'; message: string }
  | { kind: 'conflicting'; message: string }
  | { kind: 'error'; message: string };

export async function convertCode(
  code: string,
  dropOutcomeIds: string[],
): Promise<ConvertActionResult> {
  try {
    const result = await apiFetch<ConvertResult>('/api/booking-codes/convert', {
      method: 'POST',
      body: JSON.stringify({ code, dropOutcomeIds }),
    });
    return { kind: 'converted', result };
  } catch (err) {
    if (err instanceof ApiRequestError) {
      switch (err.code) {
        case 'empty_slip':
          return { kind: 'empty', message: err.message };
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

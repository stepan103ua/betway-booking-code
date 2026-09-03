import type { Slip } from '@booking-code/contracts';
import { ApiRequestError, apiFetch } from '@/lib/api';

/**
 * A resolve outcome, ready for the UI. `invalid` is "that's not a code we can read" (the
 * API's `404 invalid_code`); `transport` is everything else (network, 5xx) — the code isn't
 * the problem, so the UI keeps it out of the input's error slot.
 */
export type ResolveResult =
  { kind: 'slip'; slip: Slip } | { kind: 'invalid' } | { kind: 'transport'; message: string };

/**
 * Decode a booking code against the API. Runs server-side (the `/[code]` route is a Server
 * Component) — a decode is a read, and putting it on the URL is what makes a decoded slip a
 * shareable link.
 */
export async function resolveSlip(code: string): Promise<ResolveResult> {
  try {
    const slip = await apiFetch<Slip>('/api/booking-codes/resolve', {
      method: 'POST',
      body: JSON.stringify({ code }),
    });
    return { kind: 'slip', slip };
  } catch (err) {
    if (err instanceof ApiRequestError) {
      if (err.status === 404 || err.code === 'invalid_code') return { kind: 'invalid' };
      return { kind: 'transport', message: err.message };
    }
    return { kind: 'transport', message: 'Could not reach the service. Try again in a moment.' };
  }
}

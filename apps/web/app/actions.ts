'use server';

import type { Slip } from '@booking-code/contracts';
import { ApiRequestError, apiFetch } from '@/lib/api';

/**
 * Server Actions — the only place `fetch` calls the API for a write (docs/frontend.md §5).
 * Decode, Create and Convert are all "submit something, get a slip back", so each is a form
 * driven by `useActionState`; this is Decode's action.
 */

export type ResolveState = { slip?: Slip; error?: string };

/** Matches the API's `CodeInput` gate (design-system.md §4) — check it before the round trip. */
const CODE_PATTERN = /^BW[0-9A-F]{8}$/;

export async function resolveCode(_prev: ResolveState, formData: FormData): Promise<ResolveState> {
  const code = String(formData.get('code') ?? '')
    .trim()
    .toUpperCase();

  if (!CODE_PATTERN.test(code)) {
    return {
      error: 'Codes are BW followed by 8 characters (0-9, A-F). Check for an O typed as a 0.',
    };
  }

  try {
    const slip = await apiFetch<Slip>('/api/booking-codes/resolve', {
      method: 'POST',
      body: JSON.stringify({ code }),
    });
    return { slip };
  } catch (err) {
    // An invalid or unknown code is an expected outcome of this app, not an exception — it
    // is rendered as UI state, never thrown to the error boundary (docs/frontend.md §6).
    if (err instanceof ApiRequestError) return { error: err.message };
    return { error: 'Could not reach the service. Try again in a moment.' };
  }
}

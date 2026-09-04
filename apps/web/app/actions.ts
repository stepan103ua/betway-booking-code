'use server';

import type { EventsPage, PopularPage } from '@booking-code/contracts';
import { apiFetch } from '@/lib/api';
import { type ConvertActionResult, convertCode } from '@/lib/convert';
import {
  type CreateResult,
  type MarketsResult,
  createCode,
  getEventMarkets,
  getEventsPage,
} from '@/lib/create';
import { POPULAR_PAGE } from '@/lib/popular';

/**
 * Client-triggered reads and the one write. Each keeps `API_URL` server-side and the fan-out
 * cost (docs/backend-api.md) off the browser. The Server-Component reads — first popular
 * page, first fixture page, sports — happen in the route files, not here.
 *
 * Decode is not here: a decode is a navigation to `/<code>` (`lib/resolve.ts`), which is what
 * makes a decoded slip a shareable link.
 */

/** One more page of popular codes ("Load more" on Decode). `null` on failure. */
export async function loadPopular(skip: number): Promise<PopularPage | null> {
  try {
    return await apiFetch<PopularPage>(
      `/api/booking-codes/popular?limit=${POPULAR_PAGE}&skip=${skip}`,
    );
  } catch {
    return null;
  }
}

/** A page of fixtures for Create — the first is server-rendered, the rest come through here. */
export async function loadEvents(sport: string, skip: number): Promise<EventsPage | null> {
  return getEventsPage(sport, skip);
}

/** The full market list for one event — the "more markets" sheet fetches it on open. */
export async function loadEventMarkets(eventId: string): Promise<MarketsResult> {
  return getEventMarkets(eventId);
}

/** Generate a booking code from a draft — `POST /api/booking-codes` (a write). */
export async function generateCode(outcomeIds: string[]): Promise<CreateResult> {
  return createCode(outcomeIds);
}

/** Reissue a code without the dropped legs — `POST /api/booking-codes/convert` (a write). */
export async function convert(
  code: string,
  dropOutcomeIds: string[],
): Promise<ConvertActionResult> {
  return convertCode(code, dropOutcomeIds);
}

'use server';

import type { PopularPage } from '@booking-code/contracts';
import { apiFetch } from '@/lib/api';
import { POPULAR_PAGE } from '@/lib/popular';

/**
 * One more page of popular codes. A read triggered by a client interaction ("Load more") —
 * neither a plain Server Component read nor a mutation, so it goes through a Server Action:
 * it keeps `API_URL` server-side and the fan-out cost (docs/backend-api.md §1) off the
 * browser. `null` on failure — the list degrades to a quiet line, same as the first page.
 *
 * The decode itself is not an action — it's a navigation to `/<code>`, resolved server-side
 * by that route (`lib/resolve.ts`), which is what makes a decoded slip a shareable link.
 */
export async function loadPopular(skip: number): Promise<PopularPage | null> {
  try {
    return await apiFetch<PopularPage>(
      `/api/booking-codes/popular?limit=${POPULAR_PAGE}&skip=${skip}`,
    );
  } catch {
    return null;
  }
}

import type { Fixture, Sport } from '@booking-code/contracts';

import { AppError } from '../lib/errors.js';
import type { Cache } from '../lib/redis.js';
import type { BookingCodeProvider } from '../providers/booking-code-provider.js';

/**
 * TODO: browse — the sport and fixture lists the Create screen picks from.
 *
 * Both are cached reads, with very different TTLs: the sport list is a reference list that
 * changes about never (1h), while fixtures carry live odds (30–60s). Using one TTL for both
 * would either hammer upstream for static data or serve stale prices — see docs/backend.md §5.
 */
export class CatalogueService {
  constructor(
    private readonly provider: BookingCodeProvider,
    private readonly cache: Cache,
  ) {}

  async sports(): Promise<Sport[]> {
    throw AppError.notImplemented('Sports');
  }

  async events(_sportId: string, _take: number): Promise<Fixture[]> {
    throw AppError.notImplemented('Events');
  }
}

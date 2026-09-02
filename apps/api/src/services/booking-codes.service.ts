import type { ConvertResult, PopularBookingCode, Slip } from '@booking-code/contracts';

import { AppError } from '../lib/errors.js';
import type { Cache } from '../lib/redis.js';
import type { BookingCodeProvider } from '../providers/booking-code-provider.js';

/**
 * TODO: the three core operations.
 *
 * Business logic lives here — the provider fetches and normalises, the controller only maps
 * HTTP in and out. What this layer owns:
 *
 *   - **Cache policy.** Reads go through `cache.cached(key, ttl, fn)`; writes never do.
 *     Namespace keys by endpoint and input (`resolve:{code}`), and match the TTL to how fast
 *     the data actually moves (docs/backend.md §5).
 *   - **Convert.** Not an upstream call. `resolve` → drop `dropOutcomeIds` and anything with
 *     `isActive: false` → `encode` the rest → return both codes and both totals
 *     (docs/backend-api.md §1). Recompute `totalOdds` from the kept legs; do not carry the
 *     original total forward.
 *   - **The empty-slip case.** Dropping every leg leaves nothing to encode. Decide what that
 *     returns before writing the happy path — it is the edge case a reviewer will reach for.
 */
export class BookingCodesService {
  constructor(
    private readonly provider: BookingCodeProvider,
    private readonly cache: Cache,
  ) {}

  async resolve(_code: string): Promise<Slip> {
    throw AppError.notImplemented('Resolve');
  }

  async create(_outcomeIds: string[]): Promise<string> {
    throw AppError.notImplemented('Create');
  }

  async convert(_code: string, _dropOutcomeIds: string[]): Promise<ConvertResult> {
    throw AppError.notImplemented('Convert');
  }

  async popular(_limit: number): Promise<PopularBookingCode[]> {
    throw AppError.notImplemented('Popular codes');
  }
}

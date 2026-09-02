import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

import type { Fixture, PopularBookingCode, Slip, Sport } from '@booking-code/contracts';

import { AppError } from '../lib/errors.js';

import type { BookingCodeProvider } from './booking-code-provider.js';
import { parseFindBookABet, toSlip } from './betway.mapper.js';

/**
 * The offline implementation: the same DTOs, read from committed JSON.
 *
 * Two jobs, both worth more than they look. Tests run deterministically with no network, so CI
 * has no live Betway dependency (docs/backend.md §7); and the demo survives Betway being down,
 * since swapping providers is one line in `index.ts`.
 *
 * It runs the **same mapper** as `BetwayProvider` over **real captured responses** (see
 * `fixtures/README.md`). That is the point: a fixtures provider that returned hand-built DTOs
 * would exercise none of the parsing, and the tests would pass while the real path was broken.
 *
 * Still stubs: encode, popular codes, sports, events.
 */

const FIXTURES_DIR = join(dirname(fileURLToPath(import.meta.url)), '../../fixtures');

/** Reserved so the 404 path is reachable offline and during a demo. */
export const UNKNOWN_CODE = 'BW00000000';

/** Resolves to a slip with two dead legs — the Convert demo, and the inactive-leg test. */
export const STALE_CODE = 'BW00000001';

export class FixturesProvider implements BookingCodeProvider {
  private readonly slips = new Map<string, unknown>();

  async resolve(code: string): Promise<Slip> {
    if (code === UNKNOWN_CODE) throw AppError.invalidCode();

    // Any other code resolves to the sample slip with its own code echoed back. A map keyed by
    // real code would be worse here: captured codes expire in about a day, so the fixtures
    // would stop working as a demo while remaining fine as parser input.
    const raw = this.load(code === STALE_CODE ? 'find-book-a-bet-inactive' : 'find-book-a-bet');
    return toSlip(parseFindBookABet(raw), code);
  }

  async encode(_outcomeIds: string[]): Promise<string> {
    throw AppError.notImplemented('Fixtures encode');
  }

  async popularCodes(_limit: number): Promise<PopularBookingCode[]> {
    throw AppError.notImplemented('Fixtures popular codes');
  }

  async sports(): Promise<Sport[]> {
    throw AppError.notImplemented('Fixtures sports');
  }

  async upcomingEvents(_sportId: string, _take: number): Promise<Fixture[]> {
    throw AppError.notImplemented('Fixtures upcoming events');
  }

  lastSuccessAt(): string | null {
    return null;
  }

  private load(name: string): unknown {
    const cached = this.slips.get(name);
    if (cached !== undefined) return cached;

    const parsed: unknown = JSON.parse(readFileSync(join(FIXTURES_DIR, `${name}.json`), 'utf8'));
    this.slips.set(name, parsed);
    return parsed;
  }
}

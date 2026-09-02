import type { Fixture, PopularBookingCode, Slip, Sport } from '@booking-code/contracts';

import { AppError } from '../lib/errors.js';

import type { BookingCodeProvider } from './booking-code-provider.js';

/**
 * TODO: the offline implementation.
 *
 * Same DTOs as `BetwayProvider`, read from committed JSON in `apps/api/fixtures/`. Two jobs,
 * both of which matter more than they look:
 *
 *   1. **Tests run offline and deterministically.** Vitest/Supertest never touch the network,
 *      so CI has no live Betway dependency (docs/backend.md §7).
 *   2. **The demo survives Betway being down.** Swapping providers is one line in `index.ts`.
 *
 * Capture the fixture JSON from real responses rather than hand-writing it — `GET
 * apic.betwayafrica.com/api/v1/Widget/BookingCodes` returns 120 always-valid live codes and
 * is the intended source (docs/betway-api.md §5). Hand-written fixtures drift from the real
 * shape and quietly stop testing the parser.
 */
export class FixturesProvider implements BookingCodeProvider {
  async resolve(_code: string): Promise<Slip> {
    throw AppError.notImplemented('Fixtures resolve');
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
}

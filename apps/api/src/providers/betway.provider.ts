import type { Fixture, PopularBookingCode, Slip, Sport } from '@booking-code/contracts';

import { AppError } from '../lib/errors.js';

import type { BookingCodeProvider } from './booking-code-provider.js';

/**
 * TODO: the live Betway implementation.
 *
 * Every endpoint, payload and response shape is already documented and verified in
 * docs/betway-api.md — read it before writing anything here. The things that will cost time
 * if forgotten:
 *
 *   - **Pin the hosts.** `www.betway.com.ng`, `feeds-roa2.betwayafrica.com`,
 *     `config.betwayafrica.com`, `apic.betwayafrica.com`. Never `betway.com` — it is
 *     geo-restricted and redirects (§7).
 *   - **The versions differ.** `FindBookABet` is v2, `BookABet` is v1. Not a typo (§2, §3).
 *   - **Retry once.** A valid code returned 400 once and 200 on the next call in the same
 *     minute. Retry before mapping to `invalid_code` (§7).
 *   - **Three staleness flags, one DTO field.** `isMarketActive`, `isEventActive` and
 *     `isOutcomeActive` collapse into `Selection.isActive` (§2).
 *   - **Do not parse the numeric market suffix.** IDs are composite, and non-soccer sports
 *     use a different index space. Read `marketTypeCName` (§6).
 *   - **Set a timeout.** `AbortSignal.timeout()` on every fetch; map an abort to
 *     `upstream_timeout`, not `internal_error`.
 *
 * No auth, no signature, no captcha — a plain server-side `fetch` is sufficient (§8).
 */
export class BetwayProvider implements BookingCodeProvider {
  private lastSuccess: string | null = null;

  constructor(private readonly baseUrl: string) {}

  async resolve(_code: string): Promise<Slip> {
    throw AppError.notImplemented('Betway resolve');
  }

  async encode(_outcomeIds: string[]): Promise<string> {
    throw AppError.notImplemented('Betway encode');
  }

  async popularCodes(_limit: number): Promise<PopularBookingCode[]> {
    throw AppError.notImplemented('Betway popular codes');
  }

  async sports(): Promise<Sport[]> {
    throw AppError.notImplemented('Betway sports');
  }

  async upcomingEvents(_sportId: string, _take: number): Promise<Fixture[]> {
    throw AppError.notImplemented('Betway upcoming events');
  }

  lastSuccessAt(): string | null {
    return this.lastSuccess;
  }
}

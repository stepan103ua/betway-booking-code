import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

import type { Fixture, Market, PopularBookingCode, Slip, Sport } from '@booking-code/contracts';

import { AppError } from '../lib/errors.js';

import type { BookingCodeProvider } from './booking-code-provider.js';
import {
  parseBetBookUpcoming,
  parseConfigSports,
  parseMarketGroup,
  toFixtures,
  toMarkets,
  toSports,
} from './betway.catalogue.mapper.js';
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
 * The browse captures cover soccer and one event (`CAPTURED_EVENT_ID`), so that is the path
 * an offline demo should follow. Other sports and events answer empty rather than pretending,
 * which is also what Betway does for a sport with no fixtures.
 *
 * Still stubs: encode and popular codes.
 */

const FIXTURES_DIR = join(dirname(fileURLToPath(import.meta.url)), '../../fixtures');

/** Reserved so the 404 path is reachable offline and during a demo. */
export const UNKNOWN_CODE = 'BW00000000';

/** Resolves to a slip with two dead legs — the Convert demo, and the inactive-leg test. */
export const STALE_CODE = 'BW00000001';

/** The only sport the browse captures cover. Anything else answers empty, as upstream would. */
export const CAPTURED_SPORT_ID = 'soccer';

/** The event `market-group-main.json` was captured from, and the only one with markets. */
export const CAPTURED_EVENT_ID = '74263200';

export class FixturesProvider implements BookingCodeProvider {
  private readonly captures = new Map<string, unknown>();

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
    return toSports(parseConfigSports(this.load('config-sports')));
  }

  /**
   * Answers for the captured inputs and returns empty for everything else — which is what
   * upstream does too, since a sport with no fixtures is an ordinary answer there.
   *
   * The looser alternative (any sport returns the soccer capture) makes the offline demo
   * cover more ground, at the cost of a test double that cannot fail when the wrong sport is
   * passed through. A double that answers questions the real thing would not is how an
   * offline suite goes green over behaviour that does not exist.
   */
  async upcomingEvents(sportId: string, take: number): Promise<Fixture[]> {
    if (sportId !== CAPTURED_SPORT_ID) return [];
    return toFixtures(parseBetBookUpcoming(this.load('betbook-upcoming'))).slice(0, take);
  }

  async eventMarkets(eventId: string): Promise<Market[]> {
    if (eventId !== CAPTURED_EVENT_ID) return [];
    return toMarkets(parseMarketGroup(this.load('market-group-main')));
  }

  lastSuccessAt(): string | null {
    return null;
  }

  private load(name: string): unknown {
    const cached = this.captures.get(name);
    if (cached !== undefined) return cached;

    const parsed: unknown = JSON.parse(readFileSync(join(FIXTURES_DIR, `${name}.json`), 'utf8'));
    this.captures.set(name, parsed);
    return parsed;
  }
}

import type { Fixture, Market, Slip, Sport } from '@booking-code/contracts';

import { AppError } from '../lib/errors.js';
import { logger } from '../lib/logger.js';

import type { BookingCodeProvider, CatalogueCode } from './booking-code-provider.js';
import {
  parseBetBookUpcoming,
  parseConfigSports,
  parseMarketGroup,
  toFixtures,
  toMarkets,
  toSports,
} from './betway.catalogue.mapper.js';
import {
  parseBookABet,
  parseFindBookABet,
  parseWidgetBookingCodes,
  toCatalogueCodes,
  toSlip,
} from './betway.mapper.js';

/**
 * The live Betway implementation. Endpoints, payloads and quirks are all documented and
 * verified in docs/betway-api.md — read it before changing anything here.
 *
 * Anonymous throughout: no auth, no signature, no captcha, no cookies. Cloudflare guards
 * Betway's HTML, not its API, so a plain server-side `fetch` is sufficient (§8).
 *
 */

/**
 * Betway answers in well under a second in practice; 5s is a generous ceiling.
 *
 * Note this is per attempt, so a decode that retries can take up to 10s. That is deliberate —
 * the retry only fires on a 400, which upstream returns immediately, so in practice a retry
 * costs milliseconds rather than a second timeout.
 */
const REQUEST_TIMEOUT_MS = 5_000;

const FIND_BOOK_A_BET_PATH = '/v2/Betting/FindBookABet';

/** **v1**, unlike `FindBookABet` which is v2 (docs/betway-api.md §3). Not a typo. */
const BOOK_A_BET_PATH = '/v1/Betting/BookABet';

/**
 * Betway serves this product from three hosts (docs/betway-api.md §7). Grouping them keeps
 * the composition root honest about that rather than hiding two of them in constants here.
 */
export type BetwayHosts = {
  /** Betting API — decode and encode. */
  base: string;
  /** Reference data — the sport list. */
  config: string;
  /** Odds feed — event lists and market groups. */
  feeds: string;
  /** Public widget API — the catalogue of live booking codes. */
  apic: string;
};

/**
 * Only the `Main` group. It already carries 1X2, Double Chance, Draw No Bet, Total and
 * Handicap — the list `docs/backend-api.md` §2 asks this endpoint for — in a single call.
 * The other five groups from `MarketGroupings/group-names` would cost one call each.
 */
const MARKET_GROUP_ID = 'Main';

/** Generous headroom: `Main` held 7 markets on the event this was verified against. */
const MARKET_GROUP_TAKE = 50;

export class BetwayProvider implements BookingCodeProvider {
  private lastSuccess: string | null = null;

  constructor(private readonly hosts: BetwayHosts) {}

  /**
   * Decode a booking code (docs/betway-api.md §2).
   *
   * **v2**, unlike `BookABet` which is v1. Not a typo, and an easy thing to "correct" into a
   * break.
   */
  async resolve(code: string): Promise<Slip> {
    const body = await this.findBookABet(code);
    return toSlip(parseFindBookABet(body), code);
  }

  /**
   * Create a booking code (docs/betway-api.md §3).
   *
   * **Never retried.** `resolve` retries once because a 400 there is a documented flake and
   * reading twice is free; this call creates state upstream. A retry after an ambiguous
   * failure — a timeout where the request actually landed — mints a second code that nobody
   * holds, and the caller still only learns about one.
   */
  async encode(outcomeIds: string[]): Promise<string> {
    const response = await this.postJson(`${this.hosts.base}${BOOK_A_BET_PATH}`, {
      cultureCode: 'en-US',
      countryCode: 'NG',
      isSingleBet: false,
      // `outcomeId` alone per selection is sufficient — verified live, nothing else required.
      outcomes: outcomeIds.map((outcomeId) => ({ outcomeId })),
    });

    return parseBookABet(await this.readBody(response));
  }

  /**
   * The public catalogue (docs/betway-api.md §5). Rows only — enriching each into a full slip
   * is a decode per code, composed in the service.
   */
  async popularCodes(limit: number): Promise<CatalogueCode[]> {
    const query = new URLSearchParams({ skip: '0', limit: String(limit), source: 'sportsradar' });

    const body = await this.getJson(`${this.hosts.apic}/api/v1/Widget/BookingCodes?${query}`);
    return toCatalogueCodes(parseWidgetBookingCodes(body));
  }

  /** Reference list of sports (docs/betway-api.md §4.1). */
  async sports(): Promise<Sport[]> {
    const body = await this.getJson(`${this.hosts.config}/cron/sports/NG/en-US`);
    return toSports(parseConfigSports(body));
  }

  /**
   * Upcoming fixtures with the 1X2 market inline (docs/betway-api.md §4.3).
   *
   * `marketTypes` scopes which markets come back *with* each event; it does not filter which
   * events appear. Asking for one market is what keeps this to a single upstream call.
   */
  async upcomingEvents(sportId: string, take: number): Promise<Fixture[]> {
    const query = new URLSearchParams({
      countryCode: 'NG',
      sportId,
      Skip: '0',
      Take: String(take),
      cultureCode: 'en-US',
      isEsport: 'false',
      boostedOnly: 'false',
      marketTypes: '[Win/Draw/Win]',
    });

    const body = await this.getJson(`${this.hosts.feeds}/BetBook/Upcoming/?${query}`);
    return toFixtures(parseBetBookUpcoming(body));
  }

  /** Every market for one event (docs/betway-api.md §4.4). */
  async eventMarkets(eventId: string): Promise<Market[]> {
    const query = new URLSearchParams({
      eventId,
      marketGroupId: MARKET_GROUP_ID,
      countryCode: 'NG',
      cultureCode: 'en-US',
      skip: '0',
      take: String(MARKET_GROUP_TAKE),
      isBuildABetOnly: 'false',
      searchQuery: '',
    });

    const url = `${this.hosts.feeds}/MarketGroupings/MarketGroupNamesAndMarketsForEvent?${query}`;
    return toMarkets(parseMarketGroup(await this.getJson(url)));
  }

  lastSuccessAt(): string | null {
    return this.lastSuccess;
  }

  /**
   * A 400 from `FindBookABet` usually means the code does not exist — but not always. During
   * research a valid code returned 400 once and 200 on the next call in the same minute
   * (docs/betway-api.md §7), so one retry sits between a transient false negative and telling
   * a user their good code is invalid.
   *
   * Exactly one. A retry loop on a genuinely invalid code multiplies upstream load for an
   * answer that will not change.
   */
  private async findBookABet(code: string): Promise<unknown> {
    const payload = { countryCode: 'NG', bookingCode: code, cultureCode: 'en-US' };

    const first = await this.postJson(`${this.hosts.base}${FIND_BOOK_A_BET_PATH}`, payload);
    if (first.status !== 400) return this.readBody(first);

    await discard(first);
    logger.warn('FindBookABet returned 400, retrying once', { code });

    const retry = await this.postJson(`${this.hosts.base}${FIND_BOOK_A_BET_PATH}`, payload);

    // Still 400 after a retry: the code really is unknown. Upstream's own error body
    // (`BookABetInvalidCode`, errorCode 6000331) is deliberately not forwarded.
    if (retry.status === 400) {
      await discard(retry);
      throw AppError.invalidCode();
    }

    return this.readBody(retry);
  }

  /** GET + read, for the browse endpoints. They have no retry: none of them 400 spuriously. */
  private async getJson(url: string): Promise<unknown> {
    return this.readBody(await this.send(url, { method: 'GET' }));
  }

  private async postJson(url: string, body: unknown): Promise<Response> {
    return this.send(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    });
  }

  private async send(url: string, init: RequestInit): Promise<Response> {
    try {
      return await fetch(url, {
        ...init,
        // Without this a hung connection holds the request open until the platform kills it,
        // which is how a slow upstream becomes an outage here.
        signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
      });
    } catch (error) {
      if (
        error instanceof Error &&
        (error.name === 'TimeoutError' || error.name === 'AbortError')
      ) {
        throw new AppError('upstream_timeout', 'Betway did not respond in time.', {
          cause: error,
        });
      }
      throw AppError.upstream('Could not reach Betway.', error);
    }
  }

  /** Reads a successful response, or turns anything else into a 502. */
  private async readBody(response: Response): Promise<unknown> {
    if (!response.ok) {
      await discard(response);
      throw AppError.upstream(
        'Betway rejected the request.',
        `HTTP ${response.status} from ${response.url}`,
      );
    }

    let body: unknown;
    try {
      body = await response.json();
    } catch (error) {
      // A Cloudflare block page or an HTML error would land here rather than as a 200 of
      // nonsense passed downstream.
      throw AppError.upstream('Betway returned a response we could not read.', error);
    }

    this.lastSuccess = new Date().toISOString();
    return body;
  }
}

/**
 * Releases a response we are not going to read.
 *
 * Node's fetch (undici) keeps the socket checked out of the connection pool until the body is
 * consumed or cancelled, so dropping a `Response` on the floor costs a connection. It is a
 * small effect — measured at two extra sockets per twenty discarded 400s, because undici
 * auto-drains bodies this size — but the 400 path is the most-travelled error path here, and
 * the habit matters more once a discarded body is large.
 */
async function discard(response: Response): Promise<void> {
  try {
    await response.body?.cancel();
  } catch {
    // Nothing useful to do: we were throwing this response away regardless.
  }
}

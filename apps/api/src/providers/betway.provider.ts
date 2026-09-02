import type { Fixture, PopularBookingCode, Slip, Sport } from '@booking-code/contracts';

import { AppError } from '../lib/errors.js';
import { logger } from '../lib/logger.js';

import type { BookingCodeProvider } from './booking-code-provider.js';
import { parseFindBookABet, toSlip } from './betway.mapper.js';

/**
 * The live Betway implementation. Endpoints, payloads and quirks are all documented and
 * verified in docs/betway-api.md — read it before changing anything here.
 *
 * Anonymous throughout: no auth, no signature, no captcha, no cookies. Cloudflare guards
 * Betway's HTML, not its API, so a plain server-side `fetch` is sufficient (§8).
 *
 * Still stubs: encode, popular codes, sports, events.
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

export class BetwayProvider implements BookingCodeProvider {
  private lastSuccess: string | null = null;

  constructor(private readonly baseUrl: string) {}

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

    const first = await this.postJson(FIND_BOOK_A_BET_PATH, payload);
    if (first.status !== 400) return this.readBody(first);

    await discard(first);
    logger.warn('FindBookABet returned 400, retrying once', { code });

    const retry = await this.postJson(FIND_BOOK_A_BET_PATH, payload);

    // Still 400 after a retry: the code really is unknown. Upstream's own error body
    // (`BookABetInvalidCode`, errorCode 6000331) is deliberately not forwarded.
    if (retry.status === 400) {
      await discard(retry);
      throw AppError.invalidCode();
    }

    return this.readBody(retry);
  }

  private async postJson(path: string, body: unknown): Promise<Response> {
    try {
      return await fetch(`${this.baseUrl}${path}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
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

import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import type { AppError } from '../src/lib/errors.js';
import { BetwayProvider } from '../src/providers/betway.provider.js';

/**
 * The live provider's own logic: the retry, the timeout mapping and what happens to every
 * shape of upstream failure. None of it is reachable through the fixtures provider, and all of
 * it is the sort of thing that gets "simplified" away by someone who does not know why it is
 * there — the retry especially (docs/betway-api.md §7).
 *
 * `fetch` is stubbed globally rather than injected into the constructor. The provider calls
 * the bare global, so there is no production code here that exists only to be tested.
 */

const BASE_URL = 'https://www.betway.com.ng/appsynapse/bet-api-sr';
const CONFIG_URL = 'https://config.betwayafrica.com';
const FEEDS_URL = 'https://feeds-roa2.betwayafrica.com/br/_apis/sport/v1';
const CODE = 'BW6E487423';

const validBody: unknown = JSON.parse(
  readFileSync(
    join(dirname(fileURLToPath(import.meta.url)), '../fixtures/find-book-a-bet.json'),
    'utf8',
  ),
);

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

/** Upstream's real 400 body (docs/betway-api.md §2). */
function invalidCodeResponse(): Response {
  return jsonResponse(
    { errorCode: 6000331, errorMessage: 'BookABetInvalidCode', responseMetadata: null },
    400,
  );
}

let fetchMock: ReturnType<typeof vi.fn>;
let provider: BetwayProvider;

beforeEach(() => {
  fetchMock = vi.fn();
  vi.stubGlobal('fetch', fetchMock);
  provider = new BetwayProvider({
    base: BASE_URL,
    config: CONFIG_URL,
    feeds: FEEDS_URL,
  });
});

afterEach(() => {
  vi.unstubAllGlobals();
});

async function captureError(promise: Promise<unknown>): Promise<AppError> {
  try {
    await promise;
    expect.unreachable('expected the call to throw');
  } catch (error) {
    return error as AppError;
  }
}

describe('request shape', () => {
  it('posts to v2 FindBookABet with the documented payload', async () => {
    fetchMock.mockResolvedValueOnce(jsonResponse(validBody));

    await provider.resolve(CODE);

    expect(fetchMock).toHaveBeenCalledTimes(1);
    const [url, init] = fetchMock.mock.calls[0]!;
    // v2 here; BookABet is v1. Pinning it in a test so the difference survives a refactor.
    expect(url).toBe(`${BASE_URL}/v2/Betting/FindBookABet`);
    expect(init.method).toBe('POST');
    expect(JSON.parse(init.body as string)).toEqual({
      countryCode: 'NG',
      bookingCode: CODE,
      cultureCode: 'en-US',
    });
  });

  it('sends an abort signal so a hung upstream cannot hold the request open', async () => {
    fetchMock.mockResolvedValueOnce(jsonResponse(validBody));

    await provider.resolve(CODE);

    expect(fetchMock.mock.calls[0]![1].signal).toBeInstanceOf(AbortSignal);
  });

  it('never reaches betway.com — the geo-restricted domain', async () => {
    fetchMock.mockResolvedValueOnce(jsonResponse(validBody));

    await provider.resolve(CODE);

    expect(fetchMock.mock.calls[0]![0]).toContain('betway.com.ng');
  });
});

describe('browse request shapes', () => {
  it('reads the sport list from the config host, not the betting API', async () => {
    fetchMock.mockResolvedValueOnce(jsonResponse({ sports: [] }));

    await provider.sports();

    const [url, init] = fetchMock.mock.calls[0]!;
    expect(url).toBe(`${CONFIG_URL}/cron/sports/NG/en-US`);
    expect(init.method).toBe('GET');
  });

  it('asks the feed for one market type, which is what keeps it to a single call', async () => {
    fetchMock.mockResolvedValueOnce(
      jsonResponse({ events: [], markets: [], outcomes: [], prices: [] }),
    );

    await provider.upcomingEvents('soccer', 20);

    const url = new URL(fetchMock.mock.calls[0]![0] as string);
    expect(url.origin + url.pathname).toBe(`${FEEDS_URL}/BetBook/Upcoming/`);
    expect(url.searchParams.get('sportId')).toBe('soccer');
    expect(url.searchParams.get('Take')).toBe('20');
    // Scopes which markets come back with each event; it does not filter which events appear.
    expect(url.searchParams.get('marketTypes')).toBe('[Win/Draw/Win]');
  });

  it('requests only the Main market group', async () => {
    fetchMock.mockResolvedValueOnce(
      jsonResponse({ marketsInGroup: [], outcomes: [], prices: [] }),
    );

    await provider.eventMarkets('74263200');

    const url = new URL(fetchMock.mock.calls[0]![0] as string);
    expect(url.pathname).toContain('MarketGroupNamesAndMarketsForEvent');
    expect(url.searchParams.get('eventId')).toBe('74263200');
    expect(url.searchParams.get('marketGroupId')).toBe('Main');
    expect(fetchMock).toHaveBeenCalledTimes(1);
  });

  it('times out a hung browse call like any other', async () => {
    fetchMock.mockRejectedValueOnce(new DOMException('timed out', 'TimeoutError'));

    expect((await captureError(provider.sports())).code).toBe('upstream_timeout');
  });

  it('does not retry a browse call — only decode has the documented flake', async () => {
    fetchMock.mockResolvedValueOnce(jsonResponse({ oops: true }, 400));

    await captureError(provider.sports());

    expect(fetchMock).toHaveBeenCalledTimes(1);
  });
});

describe('retry on 400', () => {
  it('retries once and succeeds — the transient false negative the retry exists for', async () => {
    fetchMock
      .mockResolvedValueOnce(invalidCodeResponse())
      .mockResolvedValueOnce(jsonResponse(validBody));

    const slip = await provider.resolve(CODE);

    expect(fetchMock).toHaveBeenCalledTimes(2);
    expect(slip.bookingCode).toBe(CODE);
    expect(slip.selections.length).toBeGreaterThan(0);
  });

  it('gives up after exactly one retry when the code really is unknown', async () => {
    fetchMock
      .mockResolvedValueOnce(invalidCodeResponse())
      .mockResolvedValueOnce(invalidCodeResponse());

    const error = await captureError(provider.resolve(CODE));

    expect(error.code).toBe('invalid_code');
    expect(error.status).toBe(404);
    // Exactly two: a retry loop would multiply upstream load for an answer that will not change.
    expect(fetchMock).toHaveBeenCalledTimes(2);
  });

  it('does not leak upstream error vocabulary to the client', async () => {
    fetchMock
      .mockResolvedValueOnce(invalidCodeResponse())
      .mockResolvedValueOnce(invalidCodeResponse());

    const error = await captureError(provider.resolve(CODE));

    expect(error.message).not.toContain('BookABetInvalidCode');
    expect(error.message).not.toContain('6000331');
  });

  it('does not retry a request that already succeeded', async () => {
    fetchMock.mockResolvedValueOnce(jsonResponse(validBody));

    await provider.resolve(CODE);

    expect(fetchMock).toHaveBeenCalledTimes(1);
  });

  it('does not retry a 500 — only a 400 is the documented flake', async () => {
    fetchMock.mockResolvedValueOnce(jsonResponse({ oops: true }, 500));

    await captureError(provider.resolve(CODE));

    expect(fetchMock).toHaveBeenCalledTimes(1);
  });
});

describe('failure mapping', () => {
  it('maps a timeout to upstream_timeout, not internal_error', async () => {
    // What AbortSignal.timeout actually rejects with on Node: a DOMException named
    // TimeoutError. The mapping depends on that detail, so the test states it.
    fetchMock.mockRejectedValueOnce(new DOMException('timed out', 'TimeoutError'));

    const error = await captureError(provider.resolve(CODE));

    expect(error.code).toBe('upstream_timeout');
    expect(error.status).toBe(504);
  });

  it('maps an abort to upstream_timeout', async () => {
    fetchMock.mockRejectedValueOnce(new DOMException('aborted', 'AbortError'));

    expect((await captureError(provider.resolve(CODE))).code).toBe('upstream_timeout');
  });

  it('maps a network failure to upstream_error', async () => {
    fetchMock.mockRejectedValueOnce(new TypeError('fetch failed'));

    const error = await captureError(provider.resolve(CODE));

    expect(error.code).toBe('upstream_error');
    expect(error.status).toBe(502);
  });

  it('maps a 500 to upstream_error', async () => {
    fetchMock.mockResolvedValueOnce(jsonResponse({ oops: true }, 500));

    expect((await captureError(provider.resolve(CODE))).code).toBe('upstream_error');
  });

  it('maps a non-JSON body — a Cloudflare block page — to upstream_error', async () => {
    fetchMock.mockResolvedValueOnce(
      new Response('<html>Sorry, you have been blocked</html>', {
        status: 200,
        headers: { 'Content-Type': 'text/html' },
      }),
    );

    const error = await captureError(provider.resolve(CODE));

    expect(error.code).toBe('upstream_error');
    expect(error.message).not.toContain('blocked');
  });

  it('maps a 200 of the wrong shape to upstream_error rather than a half-built slip', async () => {
    fetchMock.mockResolvedValueOnce(jsonResponse({ notASlip: true }));

    expect((await captureError(provider.resolve(CODE))).code).toBe('upstream_error');
  });
});

describe('lastSuccessAt', () => {
  it('starts null', () => {
    expect(provider.lastSuccessAt()).toBeNull();
  });

  it('records an ISO timestamp after a successful call', async () => {
    fetchMock.mockResolvedValueOnce(jsonResponse(validBody));

    await provider.resolve(CODE);

    const at = provider.lastSuccessAt();
    expect(at).not.toBeNull();
    expect(Number.isNaN(Date.parse(at!))).toBe(false);
  });

  it('stays null when upstream never answered successfully', async () => {
    fetchMock.mockRejectedValueOnce(new TypeError('fetch failed'));

    await captureError(provider.resolve(CODE));

    expect(provider.lastSuccessAt()).toBeNull();
  });

  it('is not advanced by an unknown code', async () => {
    fetchMock
      .mockResolvedValueOnce(invalidCodeResponse())
      .mockResolvedValueOnce(invalidCodeResponse());

    await captureError(provider.resolve(CODE));

    expect(provider.lastSuccessAt()).toBeNull();
  });
});

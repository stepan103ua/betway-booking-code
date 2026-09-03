import type express from 'express';
import request from 'supertest';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import type { Slip } from '@booking-code/contracts';

import { createApp } from '../src/app.js';
import { AppError } from '../src/lib/errors.js';
import { createNoopCache, type Cache } from '../src/lib/redis.js';
import type { BookingCodeProvider } from '../src/providers/booking-code-provider.js';
import { FixturesProvider, STALE_CODE, UNKNOWN_CODE } from '../src/providers/fixtures.provider.js';

/**
 * Contract tests for `POST /api/booking-codes/resolve`, checked against
 * docs/backend-api.md §1. Driven through the app object with the fixtures provider — no port,
 * no network (docs/backend.md §7).
 */

function buildApp(
  overrides: { provider?: BookingCodeProvider; cache?: Cache } = {},
): express.Express {
  return createApp({
    provider: overrides.provider ?? new FixturesProvider(),
    cache: overrides.cache ?? createNoopCache(),
    allowedOrigins: ['http://localhost:3001'],
  });
}

const VALID_CODE = 'BW6E487423';

/** Records what the service asked the cache for, and serves a real read-through. */
function recordingCache() {
  const calls: { key: string; ttl: number }[] = [];
  const store = new Map<string, unknown>();

  const cache: Cache = {
    async cached(key, ttl, compute) {
      calls.push({ key, ttl });
      if (store.has(key)) return store.get(key) as never;
      const value = await compute();
      store.set(key, value);
      return value;
    },
    async status() {
      return 'ok';
    },
    async close() {},
  };

  return { cache, calls };
}

describe('POST /api/booking-codes/resolve', () => {
  it('returns a Slip matching the documented contract', async () => {
    const response = await request(buildApp())
      .post('/api/booking-codes/resolve')
      .send({ code: VALID_CODE });

    expect(response.status).toBe(200);

    const slip = response.body as Slip;
    expect(slip.bookingCode).toBe(VALID_CODE);
    expect(slip.totalOdds).toBeGreaterThan(1);
    expect(slip.expiresAt).toBeNull();
    expect(slip.usageCount).toBeNull();
    expect(slip.selections.length).toBeGreaterThan(0);

    expect(Object.keys(slip).sort()).toEqual([
      'bookingCode',
      'expiresAt',
      'selections',
      'totalOdds',
      'usageCount',
    ]);
    expect(Object.keys(slip.selections[0]!).sort()).toEqual([
      'eventName',
      'isActive',
      'kickoffAt',
      'league',
      'marketName',
      'odds',
      'outcomeId',
      'outcomeName',
    ]);
  });

  it('returns kickoffAt as a parseable ISO instant', async () => {
    const response = await request(buildApp())
      .post('/api/booking-codes/resolve')
      .send({ code: VALID_CODE });

    const kickoff = (response.body as Slip).selections[0]!.kickoffAt;
    expect(kickoff).toMatch(/^\d{4}-\d{2}-\d{2}T/);
    expect(Number.isNaN(Date.parse(kickoff))).toBe(false);
  });

  it('accepts a lowercase code and echoes the canonical uppercase form', async () => {
    const response = await request(buildApp())
      .post('/api/booking-codes/resolve')
      .send({ code: VALID_CODE.toLowerCase() });

    expect(response.status).toBe(200);
    expect((response.body as Slip).bookingCode).toBe(VALID_CODE);
  });

  it('reports a slip with dead legs without dropping them', async () => {
    const response = await request(buildApp())
      .post('/api/booking-codes/resolve')
      .send({ code: STALE_CODE });

    const slip = response.body as Slip;
    expect(slip.selections.some((s) => !s.isActive)).toBe(true);
    // Decode reports; Convert is what removes them.
    expect(slip.selections).toHaveLength(4);
  });

  it('404s an unknown code in the ApiError shape', async () => {
    const response = await request(buildApp())
      .post('/api/booking-codes/resolve')
      .send({ code: UNKNOWN_CODE });

    expect(response.status).toBe(404);
    expect(response.body).toEqual({ error: 'invalid_code', message: expect.any(String) });
  });

  it('400s a malformed code before it reaches the provider', async () => {
    const provider = new FixturesProvider();
    const resolve = vi.spyOn(provider, 'resolve');

    const response = await request(buildApp({ provider }))
      .post('/api/booking-codes/resolve')
      .send({ code: 'NOPE' });

    expect(response.status).toBe(400);
    expect(response.body.error).toBe('invalid_request');
    expect(resolve).not.toHaveBeenCalled();
  });

  it('400s a missing body', async () => {
    const response = await request(buildApp()).post('/api/booking-codes/resolve').send({});

    expect(response.status).toBe(400);
    expect(response.body.error).toBe('invalid_request');
  });
});

describe('caching', () => {
  let provider: FixturesProvider;

  beforeEach(() => {
    provider = new FixturesProvider();
  });

  it('reads through a key namespaced by endpoint and code', async () => {
    const { cache, calls } = recordingCache();

    await request(buildApp({ provider, cache }))
      .post('/api/booking-codes/resolve')
      .send({ code: VALID_CODE });

    expect(calls).toEqual([{ key: `resolve:${VALID_CODE}`, ttl: 30 }]);
  });

  it('does not hit the provider twice for the same code', async () => {
    const { cache } = recordingCache();
    const resolve = vi.spyOn(provider, 'resolve');
    const app = buildApp({ provider, cache });

    await request(app).post('/api/booking-codes/resolve').send({ code: VALID_CODE });
    await request(app).post('/api/booking-codes/resolve').send({ code: VALID_CODE });

    expect(resolve).toHaveBeenCalledTimes(1);
  });

  it('caches the miss, so a junk code cannot be replayed at Betway', async () => {
    // A miss is the more expensive answer to produce — the provider retries, so an unknown
    // code costs two upstream calls. Leaving it uncached would let a stream of junk codes
    // amplify straight through.
    const { cache } = recordingCache();
    const resolve = vi.spyOn(provider, 'resolve');
    const app = buildApp({ provider, cache });

    const first = await request(app)
      .post('/api/booking-codes/resolve')
      .send({ code: UNKNOWN_CODE });
    const second = await request(app)
      .post('/api/booking-codes/resolve')
      .send({ code: UNKNOWN_CODE });

    expect(first.status).toBe(404);
    expect(second.status).toBe(404);
    expect(second.body).toEqual({ error: 'invalid_code', message: expect.any(String) });
    expect(resolve).toHaveBeenCalledTimes(1);
  });

  it('does not cache an upstream failure — that is a fact about Betway, not the code', async () => {
    const { cache } = recordingCache();
    const resolve = vi
      .spyOn(provider, 'resolve')
      .mockRejectedValue(new AppError('upstream_timeout', 'Betway did not respond in time.'));
    const app = buildApp({ provider, cache });

    const first = await request(app).post('/api/booking-codes/resolve').send({ code: VALID_CODE });
    await request(app).post('/api/booking-codes/resolve').send({ code: VALID_CODE });

    expect(first.status).toBe(504);
    // Both requests reached the provider: a timeout may already have cleared.
    expect(resolve).toHaveBeenCalledTimes(2);
  });

  it('shares one entry between differently-cased spellings of a code', async () => {
    const { cache } = recordingCache();
    const resolve = vi.spyOn(provider, 'resolve');
    const app = buildApp({ provider, cache });

    await request(app).post('/api/booking-codes/resolve').send({ code: VALID_CODE });
    await request(app).post('/api/booking-codes/resolve').send({ code: VALID_CODE.toLowerCase() });

    expect(resolve).toHaveBeenCalledTimes(1);
  });
});

describe('POST /api/booking-codes', () => {
  /** Outcome ids present in `find-book-a-bet.json` — the ones the double can honour. */
  const OUTCOME_IDS = ['7222123211', '7253089213'];

  /** Well-formed, but not in the capture: what a selection that has gone dead looks like. */
  const DEAD_OUTCOME_ID = '9999999911';

  it('returns a booking code in the documented shape', async () => {
    const response = await request(buildApp()).post('/api/booking-codes').send({
      outcomeIds: OUTCOME_IDS,
    });

    expect(response.status).toBe(200);
    expect(Object.keys(response.body)).toEqual(['bookingCode']);
    // Round-trippable: what we hand back must satisfy the schema `/resolve` validates with.
    expect(response.body.bookingCode).toMatch(/^BW[0-9A-F]{8}$/);
  });

  it('gives an oversized slip its own error code, not a generic invalid_request', async () => {
    // "Remove a selection" is a different UI from "your request was malformed", which is why
    // docs/backend-api.md §1 gives this its own code.
    const outcomeIds = Array.from({ length: 21 }, (_, i) => `74263200${i}`);

    const response = await request(buildApp()).post('/api/booking-codes').send({ outcomeIds });

    expect(response.status).toBe(400);
    expect(response.body.error).toBe('too_many_outcomes');
    // Exactly the sentence docs/backend-api.md §1 promises — no `outcomeIds:` path prefix,
    // because a declared code means the schema wrote a line meant for a user.
    expect(response.body.message).toBe('A slip can hold at most 20 selections.');
  });

  it.each([
    ['an empty array', []],
    ['a non-id string', ['not-an-outcome']],
    ['an empty id', ['']],
  ])('rejects %s before it reaches upstream', async (_name, outcomeIds) => {
    const response = await request(buildApp()).post('/api/booking-codes').send({ outcomeIds });

    expect(response.status).toBe(400);
    expect(response.body.error).toBe('invalid_request');
  });

  it.each([
    ['every selection is dead', [DEAD_OUTCOME_ID], 'Refresh and pick again'],
    ['only some are', [OUTCOME_IDS[0]!, DEAD_OUTCOME_ID], '1 of your 2 selections'],
  ])('refuses to hand back a code missing legs when %s', async (_name, outcomeIds, message) => {
    // Upstream accepts a dead outcome id, drops it, and still returns a well-formed code. That
    // code decodes to fewer legs than asked for — or to nothing, which /resolve then 404s.
    const response = await request(buildApp()).post('/api/booking-codes').send({ outcomeIds });

    expect(response.status).toBe(400);
    expect(response.body.error).toBe('outcomes_unavailable');
    expect(response.body.message).toContain(message);
  });

  it('returns a code that this API can actually resolve', async () => {
    const app = buildApp();

    const created = await request(app).post('/api/booking-codes').send({
      outcomeIds: OUTCOME_IDS,
    });
    const resolved = await request(app)
      .post('/api/booking-codes/resolve')
      .send({ code: created.body.bookingCode });

    // The bug this guards: create used to return 200 for a code /resolve answered 404 for.
    expect(resolved.status).toBe(200);
    expect(resolved.body.selections.map((s: { outcomeId: string }) => s.outcomeId).sort()).toEqual(
      [...OUTCOME_IDS].sort(),
    );
  });

  it('still returns the code when verification itself fails', async () => {
    // A timeout on the read-back says nothing about whether the code exists — and it probably
    // does. Failing here would report a create that actually worked as broken.
    const provider = new FixturesProvider();
    vi.spyOn(provider, 'resolve').mockRejectedValue(
      new AppError('upstream_timeout', 'Betway did not respond in time.'),
    );

    const response = await request(buildApp({ provider })).post('/api/booking-codes').send({
      outcomeIds: OUTCOME_IDS,
    });

    expect(response.status).toBe(200);
    expect(response.body.bookingCode).toMatch(/^BW[0-9A-F]{8}$/);
  });

  it('never caches — two identical creates must both reach upstream', async () => {
    // Caching this would hand two callers the same code for slips built minutes apart, with
    // the odds moved in between. It is a write (docs/backend.md §5).
    const provider = new FixturesProvider();
    const upstream = vi.spyOn(provider, 'encode');
    const { cache, calls } = recordingCache();
    const app = buildApp({ provider, cache });

    await request(app).post('/api/booking-codes').send({ outcomeIds: OUTCOME_IDS });
    await request(app).post('/api/booking-codes').send({ outcomeIds: OUTCOME_IDS });

    expect(upstream).toHaveBeenCalledTimes(2);
    // The only cache traffic is the verification read-back, never the write itself.
    expect(calls.every((call) => call.key.startsWith('resolve:'))).toBe(true);
  });
});

describe('POST /api/booking-codes/convert', () => {
  /** `STALE_CODE` resolves to a four-leg slip with two legs unbettable. */
  const LIVE_LEGS = ['7222123211', '7253089213'];

  async function convert(body: Record<string, unknown>, app = buildApp()) {
    return request(app).post('/api/booking-codes/convert').send(body);
  }

  it('drops dead legs without being asked, and returns the documented shape', async () => {
    const response = await convert({ code: STALE_CODE });

    expect(response.status).toBe(200);
    expect(Object.keys(response.body).sort()).toEqual([
      'bookingCode',
      'droppedCount',
      'expiresAt',
      'previousBookingCode',
      'previousTotalOdds',
      'selections',
      'totalOdds',
      'usageCount',
    ]);
    expect(response.body.previousBookingCode).toBe(STALE_CODE);
    expect(response.body.bookingCode).not.toBe(STALE_CODE);
    expect(response.body.droppedCount).toBe(2);
    expect(response.body.selections.map((s: { outcomeId: string }) => s.outcomeId).sort()).toEqual(
      [...LIVE_LEGS].sort(),
    );
  });

  it('recomputes the total over the kept legs instead of carrying the old one forward', async () => {
    const response = await convert({ code: STALE_CODE });

    // The whole point of the before/after diff: two different numbers, and the new one is the
    // product of what survived.
    expect(response.body.totalOdds).not.toBe(response.body.previousTotalOdds);
    const product = response.body.selections.reduce(
      (total: number, s: { odds: number }) => total * s.odds,
      1,
    );
    expect(response.body.totalOdds).toBeCloseTo(Math.round(product * 100) / 100, 2);
  });

  it('drops the legs the client asks for on top of the dead ones', async () => {
    const response = await convert({ code: STALE_CODE, dropOutcomeIds: [LIVE_LEGS[0]!] });

    expect(response.status).toBe(200);
    expect(response.body.droppedCount).toBe(3);
    expect(response.body.selections).toHaveLength(1);
    expect(response.body.selections[0].outcomeId).toBe(LIVE_LEGS[1]);
  });

  it('ignores a dropOutcomeId that is not in the slip', async () => {
    // The client is describing what it wants gone; a leg already absent is not an error.
    const response = await convert({ code: STALE_CODE, dropOutcomeIds: ['7426320011'] });

    expect(response.status).toBe(200);
    expect(response.body.droppedCount).toBe(2);
  });

  it('400s when the client drops every remaining leg', async () => {
    const response = await convert({ code: STALE_CODE, dropOutcomeIds: LIVE_LEGS });

    expect(response.status).toBe(400);
    expect(response.body.error).toBe('empty_slip');
    expect(response.body.message).toContain('nothing to convert');
  });

  it('400s when nothing in the code can still be bet', async () => {
    const provider = new FixturesProvider();
    const slip = await provider.resolve('BW6E487423');
    vi.spyOn(provider, 'resolve').mockResolvedValue({
      ...slip,
      selections: slip.selections.map((selection) => ({ ...selection, isActive: false })),
    });

    const response = await convert({ code: 'BW6E487423' }, buildApp({ provider }));

    expect(response.status).toBe(400);
    expect(response.body.error).toBe('empty_slip');
    expect(response.body.message).toContain('can still be bet');
  });

  it('reads through the cache but never caches the new code', async () => {
    const { cache, calls } = recordingCache();

    await convert({ code: STALE_CODE }, buildApp({ cache }));

    // The read may be cached (docs/backend.md §5); the encode is a write and must not be.
    expect(calls.every((call) => call.key.startsWith('resolve:'))).toBe(true);
    expect(calls.some((call) => call.key === `resolve:${STALE_CODE}`)).toBe(true);
  });

  it('404s an unknown code, like resolve does', async () => {
    const response = await convert({ code: UNKNOWN_CODE });

    expect(response.status).toBe(404);
    expect(response.body.error).toBe('invalid_code');
  });

  /**
   * A leg can die between Convert's resolve and its encode — the read may be up to 30s stale,
   * and upstream drops the dead leg silently. These drive the shared `encodeVerified` path
   * through Convert rather than Create, because the two need different advice: Convert's caller
   * supplied a code, so "pick again" is impossible for them.
   */
  describe('a leg dying between the resolve and the encode', () => {
    /** Makes the read-back of the *new* code omit `missing`, as upstream would. */
    function providerDropping(missing: string[]): FixturesProvider {
      const provider = new FixturesProvider();
      const real = provider.resolve.bind(provider);

      vi.spyOn(provider, 'resolve').mockImplementation(async (code: string) => {
        const slip = await real(code);
        if (code === STALE_CODE) return slip;
        return {
          ...slip,
          selections: slip.selections.filter((s) => !missing.includes(s.outcomeId)),
        };
      });

      return provider;
    }

    it('refuses the code and tells the user to convert again, not to pick again', async () => {
      const app = buildApp({ provider: providerDropping([LIVE_LEGS[0]!]) });

      const response = await convert({ code: STALE_CODE }, app);

      expect(response.status).toBe(400);
      expect(response.body.error).toBe('outcomes_unavailable');
      expect(response.body.message).toContain('Try again');
      // Create's wording. There is nothing for a Convert caller to re-pick.
      expect(response.body.message).not.toContain('pick again');
    });

    it('says how many went when only some did', async () => {
      const app = buildApp({ provider: providerDropping([LIVE_LEGS[0]!]) });

      const response = await convert({ code: STALE_CODE }, app);

      expect(response.body.message).toContain('1 of the 2 remaining selections');
    });

    it('still refuses when every remaining leg goes', async () => {
      const app = buildApp({ provider: providerDropping(LIVE_LEGS) });

      const response = await convert({ code: STALE_CODE }, app);

      expect(response.status).toBe(400);
      expect(response.body.error).toBe('outcomes_unavailable');
      expect(response.body.message).toContain('Try again');
    });
  });

  it('returns the kept legs when the read-back is inconclusive', async () => {
    // A timeout on the read says nothing about whether the code is good, so Convert answers
    // with what it knew at resolve time rather than failing a conversion that probably worked.
    const provider = new FixturesProvider();
    const real = provider.resolve.bind(provider);
    vi.spyOn(provider, 'resolve').mockImplementation(async (code: string) => {
      if (code === STALE_CODE) return real(code);
      throw new AppError('upstream_timeout', 'Betway did not respond in time.');
    });

    const response = await convert({ code: STALE_CODE }, buildApp({ provider }));

    expect(response.status).toBe(200);
    expect(response.body.droppedCount).toBe(2);
    expect(response.body.selections.map((s: { outcomeId: string }) => s.outcomeId).sort()).toEqual(
      [...LIVE_LEGS].sort(),
    );
  });
});

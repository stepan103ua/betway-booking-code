import type express from 'express';
import request from 'supertest';
import { describe, expect, it, vi } from 'vitest';

import type { Fixture, Sport } from '@booking-code/contracts';

import { createApp } from '../src/app.js';
import { createNoopCache, type Cache } from '../src/lib/redis.js';
import type { BookingCodeProvider } from '../src/providers/booking-code-provider.js';
import { CAPTURED_EVENT_ID, FixturesProvider } from '../src/providers/fixtures.provider.js';

/**
 * Contract tests for the browse endpoints, checked against docs/backend-api.md §2. Driven
 * through the app object with the fixtures provider — no port, no network (docs/backend.md §7).
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

const EVENT_ID = CAPTURED_EVENT_ID;

describe('GET /api/sports', () => {
  it('returns the documented shape', async () => {
    const response = await request(buildApp()).get('/api/sports');

    expect(response.status).toBe(200);

    const sports = response.body.sports as Sport[];
    expect(sports.length).toBeGreaterThan(0);
    expect(Object.keys(sports[0]!).sort()).toEqual(['id', 'name']);
    expect(sports).toContainEqual({ id: 'soccer', name: 'Soccer' });
  });

  it('offers no sport that /api/events cannot answer for', async () => {
    const response = await request(buildApp()).get('/api/sports');

    expect((response.body.sports as Sport[]).map((sport) => sport.id)).not.toContain('Codes');
  });
});

describe('GET /api/events', () => {
  it('returns Fixtures matching the documented contract', async () => {
    const response = await request(buildApp()).get('/api/events?sport=soccer&limit=20');

    expect(response.status).toBe(200);

    const events = response.body.events as Fixture[];
    expect(events.length).toBeGreaterThan(0);
    expect(Object.keys(events[0]!).sort()).toEqual([
      'eventId',
      'kickoffAt',
      'league',
      'markets',
      'name',
    ]);
    expect(Object.keys(events[0]!.markets[0]!).sort()).toEqual([
      'marketId',
      'name',
      'outcomes',
      'type',
    ]);
    expect(Object.keys(events[0]!.markets[0]!.outcomes[0]!).sort()).toEqual([
      'label',
      'odds',
      'outcomeId',
    ]);
  });

  it('carries exactly the 1X2 market inline — one upstream call, not one per event', async () => {
    const response = await request(buildApp()).get('/api/events');

    for (const event of response.body.events as Fixture[]) {
      expect(event.markets).toHaveLength(1);
      expect(event.markets[0]!.type).toBe('win-draw-win');
    }
  });

  it('defaults sport and limit when the query is omitted', async () => {
    const response = await request(buildApp()).get('/api/events');

    expect(response.status).toBe(200);
    expect((response.body.events as Fixture[]).length).toBeGreaterThan(0);
  });

  it('honours limit', async () => {
    const response = await request(buildApp()).get('/api/events?limit=2');

    expect(response.body.events).toHaveLength(2);
  });

  it('returns an empty list, not an error, for a sport with no fixtures', async () => {
    // Upstream answers an unknown sport with an empty page rather than a 404, and a real sport
    // can genuinely have nothing upcoming — so this has to be a valid 200.
    const response = await request(buildApp()).get('/api/events?sport=lacrosse');

    expect(response.status).toBe(200);
    expect(response.body.events).toEqual([]);
  });

  it('pages through the fixture list', async () => {
    const first = await request(buildApp()).get('/api/events?limit=2&skip=0');
    const second = await request(buildApp()).get('/api/events?limit=2&skip=2');

    expect(first.body).toMatchObject({ skip: 0, limit: 2, hasMore: true });
    expect(second.body).toMatchObject({ skip: 2, limit: 2 });

    const firstIds = (first.body.events as Fixture[]).map((e) => e.eventId);
    const secondIds = (second.body.events as Fixture[]).map((e) => e.eventId);
    expect(firstIds.filter((id) => secondIds.includes(id))).toEqual([]);
  });

  it('reports hasMore false once the list runs out', async () => {
    // The feed sends no total, only an end-of-list flag — so this is upstream's answer, not a
    // count comparison.
    const response = await request(buildApp()).get('/api/events?limit=50&skip=0');

    expect(response.body.hasMore).toBe(false);
  });

  it.each([
    ['above the cap', 'limit=51'],
    ['a negative skip', 'skip=-1'],
    // `skip` lands in a cache key, so it is bounded like every other key input.
    ['a skip past the ceiling', 'skip=1001'],
    ['below one', 'limit=0'],
    ['not a number', 'limit=abc'],
    ['an empty sport', 'sport='],
    // `sport` lands in a Redis key, so its length is bounded like every other key input.
    ['an over-long sport', `sport=${'x'.repeat(33)}`],
  ])('rejects %s with a field-level 400', async (_name, query) => {
    const response = await request(buildApp()).get(`/api/events?${query}`);

    expect(response.status).toBe(400);
    expect(response.body.error).toBe('invalid_request');
    // Rendered to a user verbatim, so it has to read as a sentence rather than as Zod's
    // "Too big: expected number to be <=50".
    expect(response.body.message).not.toContain('expected number');
  });
});

describe('GET /api/events/:eventId/markets', () => {
  it('returns the full market list in the documented shape', async () => {
    const response = await request(buildApp()).get(`/api/events/${EVENT_ID}/markets`);

    expect(response.status).toBe(200);
    expect(response.body.eventId).toBe(EVENT_ID);
    expect(Object.keys(response.body).sort()).toEqual(['eventId', 'markets']);
    expect(response.body.markets.length).toBeGreaterThan(1);
  });

  it('returns the same Market shape /api/events does', async () => {
    const events = await request(buildApp()).get('/api/events');
    const markets = await request(buildApp()).get(`/api/events/${EVENT_ID}/markets`);

    const fromEvents = Object.keys((events.body.events as Fixture[])[0]!.markets[0]!).sort();
    expect(Object.keys(markets.body.markets[0]).sort()).toEqual(fromEvents);
  });

  it('404s an event with no markets rather than returning an empty 200', async () => {
    const response = await request(buildApp()).get('/api/events/10000000/markets');

    expect(response.status).toBe(404);
    expect(response.body).toMatchObject({ error: 'not_found', message: expect.any(String) });
  });

  it('rejects a non-numeric eventId before it reaches upstream', async () => {
    const response = await request(buildApp()).get('/api/events/not-an-id/markets');

    expect(response.status).toBe(400);
    expect(response.body.error).toBe('invalid_request');
  });
});

describe('caching', () => {
  it('gives reference data a far longer TTL than anything carrying odds', async () => {
    const { cache, calls } = recordingCache();
    const app = buildApp({ cache });

    await request(app).get('/api/sports');
    await request(app).get('/api/events?sport=soccer&limit=20');
    await request(app).get(`/api/events/${EVENT_ID}/markets`);

    expect(calls).toEqual([
      { key: 'sports', ttl: 3600 },
      { key: 'events:soccer:0:20', ttl: 30 },
      { key: `markets:${EVENT_ID}`, ttl: 30 },
    ]);
  });

  it('keys events by sport, skip and limit, so one page cannot be served for another', async () => {
    const { cache, calls } = recordingCache();
    const app = buildApp({ cache });

    await request(app).get('/api/events?sport=soccer&limit=20');
    await request(app).get('/api/events?sport=tennis&limit=20');
    await request(app).get('/api/events?sport=soccer&limit=5');
    await request(app).get('/api/events?sport=soccer&limit=20&skip=20');

    expect(calls.map((call) => call.key)).toEqual([
      'events:soccer:0:20',
      'events:tennis:0:20',
      'events:soccer:0:5',
      'events:soccer:20:20',
    ]);
  });

  it('serves a second identical request without going upstream again', async () => {
    const { cache } = recordingCache();
    const provider = new FixturesProvider();
    const upstream = vi.spyOn(provider, 'sports');
    const app = buildApp({ cache, provider });

    await request(app).get('/api/sports');
    await request(app).get('/api/sports');

    // The point of the cache is rate-limit headroom: the second request must not reach Betway.
    expect(upstream).toHaveBeenCalledTimes(1);
  });
});

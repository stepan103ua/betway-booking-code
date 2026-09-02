import type express from 'express';
import request from 'supertest';
import { describe, expect, it } from 'vitest';

import { createApp } from '../src/app.js';
import { createNoopCache } from '../src/lib/redis.js';
import { FixturesProvider } from '../src/providers/fixtures.provider.js';

/**
 * Smoke test for the wiring, not for business logic.
 *
 * It drives the app object directly — no port, no network, no live Betway (docs/backend.md
 * §7). What it proves is that routing, the error middleware and the response contract are
 * connected: a real endpoint answers, an unimplemented one fails in the documented shape,
 * validation rejects before reaching a service, and an unknown path 404s.
 *
 * Resolve has since been implemented and has its own suite in `booking-codes.test.ts`; the
 * 501 assertion here now covers a route that genuinely is still a stub.
 */
function buildApp(): express.Express {
  return createApp({
    provider: new FixturesProvider(),
    cache: createNoopCache(),
    allowedOrigins: ['http://localhost:3001'],
  });
}

describe('GET /api/health', () => {
  it('reports service and cache status', async () => {
    const response = await request(buildApp()).get('/api/health');

    expect(response.status).toBe(200);
    expect(response.body).toEqual({
      status: 'ok',
      redis: 'disabled',
      betwayLastSuccessAt: null,
    });
  });
});

describe('error contract', () => {
  it('returns ApiError for an endpoint that is not built yet', async () => {
    const response = await request(buildApp()).get('/api/sports');

    expect(response.status).toBe(501);
    expect(response.body).toMatchObject({
      error: 'not_implemented',
      message: expect.any(String),
    });
  });

  it('rejects a malformed body with a field-level 400', async () => {
    const response = await request(buildApp()).post('/api/booking-codes').send({});

    expect(response.status).toBe(400);
    expect(response.body.error).toBe('invalid_request');
    expect(response.body.message).toContain('outcomeIds');
  });

  it('enforces the 20-selection cap', async () => {
    const outcomeIds = Array.from({ length: 21 }, (_, i) => `74232940${i}`);
    const response = await request(buildApp()).post('/api/booking-codes').send({ outcomeIds });

    expect(response.status).toBe(400);
    expect(response.body.message).toContain('at most 20');
  });

  it('404s an unknown path in the same shape', async () => {
    const response = await request(buildApp()).get('/api/nope');

    expect(response.status).toBe(404);
    expect(response.body).toMatchObject({ error: 'not_found' });
  });
});

import { Router } from 'express';

import type { HealthStatus } from '@booking-code/contracts';

import type { Cache } from '../lib/redis.js';
import type { BookingCodeProvider } from '../providers/booking-code-provider.js';

/**
 * `GET /api/health` — pings Redis and reports the last successful upstream call.
 *
 * Always 200, even when a dependency is down: this is a readiness signal for a human or an
 * uptime check, and a body saying `redis: "down"` is more useful than a bare 503 that says
 * only "something". `status` is `degraded` when the cache is configured but unreachable —
 * not when it is deliberately disabled, which is a valid way to run.
 */
export function healthRoutes(cache: Cache, provider: BookingCodeProvider): Router {
  const router = Router();

  router.get('/', async (_req, res) => {
    const redis = await cache.status();

    const body: HealthStatus = {
      status: redis === 'down' ? 'degraded' : 'ok',
      redis,
      betwayLastSuccessAt: provider.lastSuccessAt(),
    };

    res.json(body);
  });

  return router;
}

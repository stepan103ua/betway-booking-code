import cors from 'cors';
import express, { type Express } from 'express';

import { createRateLimiter } from './lib/rate-limit.js';
import type { Cache } from './lib/redis.js';
import { errorHandler, notFoundHandler } from './middleware/error-handler.js';
import type { BookingCodeProvider } from './providers/booking-code-provider.js';
import { apiRoutes } from './routes/index.js';

export type AppDependencies = {
  provider: BookingCodeProvider;
  cache: Cache;
  allowedOrigins: string[];
};

/**
 * Builds the Express app without binding a port, so tests can drive it with Supertest
 * directly — no listening server, no network (docs/backend.md §7).
 *
 * Middleware order is load-bearing: CORS and the rate limiter run before routing so a
 * rejected request never reaches a handler, and the error handler is registered last because
 * Express only routes to error middleware declared after the handlers that throw.
 */
export function createApp({ provider, cache, allowedOrigins }: AppDependencies): Express {
  const app = express();

  // Behind Railway/Fly the client IP arrives in X-Forwarded-For. Without this the rate
  // limiter counts every request against the proxy's single address.
  app.set('trust proxy', 1);
  app.disable('x-powered-by');

  app.use(
    cors({
      // An explicit allowlist, not `*`. The Flutter client sends no Origin header from a
      // native HTTP client, so it is unaffected either way (docs/backend.md §6).
      origin: allowedOrigins,
    }),
  );

  // Bodies here are small: a booking code, or at most 20 outcome ids.
  app.use(express.json({ limit: '32kb' }));

  app.use(createRateLimiter());

  app.use('/api', apiRoutes(provider, cache));

  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}

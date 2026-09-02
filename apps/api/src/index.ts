import { createApp } from './app.js';
import { loadConfig } from './config.js';
import { logger } from './lib/logger.js';
import { createCache } from './lib/redis.js';
import { BetwayProvider } from './providers/betway.provider.js';
import type { BookingCodeProvider } from './providers/booking-code-provider.js';

/**
 * Composition root — the only place that decides which concrete implementations run.
 *
 * Swapping to `FixturesProvider` for an offline demo is the one-line change below, and
 * nothing above it (services, routes, either client) knows the difference. That is the whole
 * payoff of the provider interface (docs/backend.md §3).
 */
function main(): void {
  const config = loadConfig();
  const cache = createCache(config.redisUrl);

  // Offline demo or no network: swap for `new FixturesProvider()`.
  const provider: BookingCodeProvider = new BetwayProvider(config.betwayBaseUrl);

  const app = createApp({ provider, cache, allowedOrigins: config.allowedOrigins });

  const server = app.listen(config.port, () => {
    logger.info('api listening', {
      port: config.port,
      env: config.nodeEnv,
      cache: config.redisUrl ? 'redis' : 'disabled',
    });
  });

  // Railway and Fly send SIGTERM and then kill. Draining in-flight requests first turns a
  // deploy into a clean handover rather than a burst of dropped connections.
  const shutdown = (signal: string) => {
    logger.info('shutting down', { signal });
    server.close(() => {
      void cache.close().then(() => process.exit(0));
    });
    setTimeout(() => process.exit(1), 10_000).unref();
  };

  process.on('SIGTERM', () => shutdown('SIGTERM'));
  process.on('SIGINT', () => shutdown('SIGINT'));
}

try {
  main();
} catch (error) {
  logger.error('failed to start', {
    error: error instanceof Error ? error.message : String(error),
  });
  process.exit(1);
}

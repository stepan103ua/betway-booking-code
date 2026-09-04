import { Redis } from 'ioredis';

import { logger } from './logger.js';

/**
 * Redis is a cache and nothing else.
 *
 * It is the only store in this service, and it holds nothing that cannot be rebuilt by
 * asking Betway again (docs/backend.md §5). Two properties follow from that, and both are
 * deliberate:
 *
 *   1. **Optional.** With `REDIS_URL` unset the cache degrades to a pass-through, so the
 *      service runs with zero setup. Production always configures it.
 *   2. **Fail-open.** A Redis error is logged and then ignored — the request continues to
 *      upstream. A broken cache must not become a broken API, because losing the cache costs
 *      latency and rate-limit headroom, not correctness.
 *
 * TTLs are chosen per call site, matched to how fast the underlying data actually moves:
 * an hour for the sport list, 30–60s for anything carrying live odds.
 */

export type Cache = {
  /** Read-through: return the cached value, or compute it, store it and return it. */
  cached<T>(key: string, ttlSeconds: number, compute: () => Promise<T>): Promise<T>;
  /** Cache health for `GET /api/health`. */
  status(): Promise<'ok' | 'down' | 'disabled'>;
  close(): Promise<void>;
};

/** Used when REDIS_URL is unset. Every read goes straight to `compute`. */
export function createNoopCache(): Cache {
  return {
    async cached(_key, _ttlSeconds, compute) {
      return compute();
    },
    async status() {
      return 'disabled';
    },
    async close() {},
  };
}

export function createRedisCache(url: string): Cache {
  const client = new Redis(url, {
    // Fail fast rather than queueing requests behind a dead connection — the whole point of
    // fail-open is that a request never waits on Redis.
    maxRetriesPerRequest: 1,
    enableOfflineQueue: false,
    lazyConnect: false,
    connectTimeout: 2_000,
  });

  client.on('error', (error: Error) => {
    logger.warn('redis error, continuing without cache', { error: error.message });
  });

  return {
    async cached<T>(key: string, ttlSeconds: number, compute: () => Promise<T>): Promise<T> {
      try {
        const hit = await client.get(key);
        if (hit !== null) return JSON.parse(hit) as T;
      } catch (error) {
        logger.warn('cache read failed', { key, error: errorMessage(error) });
      }

      const value = await compute();

      try {
        await client.set(key, JSON.stringify(value), 'EX', ttlSeconds);
      } catch (error) {
        logger.warn('cache write failed', { key, error: errorMessage(error) });
      }

      return value;
    },

    async status() {
      try {
        const pong = await client.ping();
        return pong === 'PONG' ? 'ok' : 'down';
      } catch {
        return 'down';
      }
    },

    async close() {
      await client.quit().catch(() => client.disconnect());
    },
  };
}

export function createCache(redisUrl: string | undefined): Cache {
  if (!redisUrl) {
    logger.warn('REDIS_URL not set — running without a cache');
    return createNoopCache();
  }
  return createRedisCache(redisUrl);
}

function errorMessage(error: unknown): string {
  return error instanceof Error ? error.message : String(error);
}

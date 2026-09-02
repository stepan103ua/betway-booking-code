import { z } from 'zod';

/**
 * Environment, parsed once at startup.
 *
 * Deliberately strict and eager: a bad value fails the process on boot with a readable
 * message, rather than surfacing as a confusing 500 on the first request that happens to
 * need it. See docs/backend.md §8 for where real values live.
 */
const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),

  /** Betway's betting API. Pinned host — see docs/betway-api.md §7. */
  BETWAY_BASE_URL: z.url().default('https://www.betway.com.ng/appsynapse/bet-api-sr'),

  /**
   * Optional. Unset means "run without a cache" — every read goes straight upstream. That
   * keeps `npm run dev` working with zero setup; production always sets it.
   */
  REDIS_URL: z.string().trim().optional(),

  PORT: z.coerce.number().int().positive().max(65535).default(3000),

  /** Comma-separated list of origins the web app may call from. */
  ALLOWED_ORIGIN: z.string().default('http://localhost:3001'),
});

export type Config = {
  nodeEnv: 'development' | 'test' | 'production';
  betwayBaseUrl: string;
  redisUrl: string | undefined;
  port: number;
  allowedOrigins: string[];
};

export function loadConfig(env: NodeJS.ProcessEnv = process.env): Config {
  const parsed = envSchema.safeParse(env);

  if (!parsed.success) {
    const issues = parsed.error.issues
      .map((issue) => `  ${issue.path.join('.') || '(root)'}: ${issue.message}`)
      .join('\n');
    throw new Error(`Invalid environment:\n${issues}`);
  }

  const value = parsed.data;

  return {
    nodeEnv: value.NODE_ENV,
    betwayBaseUrl: value.BETWAY_BASE_URL.replace(/\/+$/, ''),
    // An empty string in a .env file is "not set", not "connect to empty host".
    redisUrl: value.REDIS_URL === '' ? undefined : value.REDIS_URL,
    port: value.PORT,
    allowedOrigins: value.ALLOWED_ORIGIN.split(',')
      .map((origin) => origin.trim())
      .filter(Boolean),
  };
}

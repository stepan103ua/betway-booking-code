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

  /**
   * Betway's betting API — decode and encode. Pinned host, see docs/betway-api.md §7.
   *
   * Four hosts, not one, because Betway genuinely serves these from four places. Never
   * `betway.com`: it is geo-restricted and redirects.
   */
  BETWAY_BASE_URL: z.url().default('https://www.betway.com.ng/appsynapse/bet-api-sr'),

  /** Reference data — the sport list. */
  BETWAY_CONFIG_URL: z.url().default('https://config.betwayafrica.com'),

  /** The odds feed — event lists and market groups. */
  BETWAY_FEEDS_URL: z.url().default('https://feeds-roa2.betwayafrica.com/br/_apis/sport/v1'),

  /** The public widget API — the catalogue of live booking codes. */
  BETWAY_APIC_URL: z.url().default('https://apic.betwayafrica.com'),

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
  betwayConfigUrl: string;
  betwayFeedsUrl: string;
  betwayApicUrl: string;
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
    betwayBaseUrl: stripTrailingSlash(value.BETWAY_BASE_URL),
    betwayConfigUrl: stripTrailingSlash(value.BETWAY_CONFIG_URL),
    betwayFeedsUrl: stripTrailingSlash(value.BETWAY_FEEDS_URL),
    betwayApicUrl: stripTrailingSlash(value.BETWAY_APIC_URL),
    // An empty string in a .env file is "not set", not "connect to empty host".
    redisUrl: value.REDIS_URL === '' ? undefined : value.REDIS_URL,
    port: value.PORT,
    allowedOrigins: value.ALLOWED_ORIGIN.split(',')
      .map((origin) => origin.trim())
      .filter(Boolean),
  };
}

function stripTrailingSlash(url: string): string {
  return url.replace(/\/+$/, '');
}

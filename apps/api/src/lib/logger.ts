/**
 * Minimal structured logger — JSON lines to stdout, which is what Railway/Fly ingest.
 *
 * No logging library: this is a handful of lines and pulling in pino would be the larger
 * decision of the two. Swap it later if log volume ever justifies one.
 *
 * Never log a request body, a Redis URL or an upstream response wholesale. Booking codes are
 * fine (they are public and anonymous), but the habit of logging whole payloads is how
 * secrets end up in a log aggregator.
 */

type Level = 'debug' | 'info' | 'warn' | 'error';

const LEVELS: Record<Level, number> = { debug: 10, info: 20, warn: 30, error: 40 };

const threshold = LEVELS[(process.env.LOG_LEVEL as Level) ?? 'info'] ?? LEVELS.info;

function emit(level: Level, message: string, fields?: Record<string, unknown>): void {
  if (LEVELS[level] < threshold) return;

  const line = JSON.stringify({
    level,
    time: new Date().toISOString(),
    message,
    ...fields,
  });

  if (level === 'error' || level === 'warn') {
    console.error(line);
  } else {
    // eslint-disable-next-line no-console
    console.log(line);
  }
}

export const logger = {
  debug: (message: string, fields?: Record<string, unknown>) => emit('debug', message, fields),
  info: (message: string, fields?: Record<string, unknown>) => emit('info', message, fields),
  warn: (message: string, fields?: Record<string, unknown>) => emit('warn', message, fields),
  error: (message: string, fields?: Record<string, unknown>) => emit('error', message, fields),
};

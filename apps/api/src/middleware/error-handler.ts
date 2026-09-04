import type { NextFunction, Request, Response } from 'express';

import type { ApiError } from '@booking-code/contracts';

import { isAppError } from '../lib/errors.js';
import { logger } from '../lib/logger.js';

/**
 * The single exit point for every failure in the service.
 *
 * Express 5 forwards rejected promises from async handlers here automatically, so handlers
 * throw and this decides what the client sees. Nothing else in the codebase should write an
 * error response body.
 *
 * An unrecognised error is a bug: log it with its stack, tell the client nothing beyond
 * "something went wrong". Leaking an upstream message or a stack trace to an anonymous
 * caller is how internal detail escapes.
 */
export function errorHandler(
  error: unknown,
  req: Request,
  res: Response,
  // Express identifies error middleware by arity — the 4th parameter must exist even unused.
  _next: NextFunction,
): void {
  if (isAppError(error)) {
    // 5xx means we broke or upstream did; either way it deserves a log line with the cause.
    // `not_implemented` is the exception — it is a deliberate state of an unfinished route,
    // not a failure, and logging it as an error trains you to ignore real ones.
    if (error.status >= 500 && error.code !== 'not_implemented') {
      logger.error(error.message, {
        code: error.code,
        path: req.path,
        cause: describe(error.cause),
      });
    }

    const body: ApiError = { error: error.code, message: error.message };
    res.status(error.status).json(body);
    return;
  }

  logger.error('unhandled error', {
    path: req.path,
    method: req.method,
    error: describe(error),
    stack: error instanceof Error ? error.stack : undefined,
  });

  const body: ApiError = {
    error: 'internal_error',
    message: 'Something went wrong on our side. Please try again.',
  };
  res.status(500).json(body);
}

/** 404 for a path that is not in the contract at all. */
export function notFoundHandler(req: Request, res: Response): void {
  const body: ApiError = {
    error: 'not_found',
    message: `No route for ${req.method} ${req.path}.`,
  };
  res.status(404).json(body);
}

function describe(value: unknown): string | undefined {
  if (value === undefined || value === null) return undefined;
  return value instanceof Error ? value.message : String(value);
}

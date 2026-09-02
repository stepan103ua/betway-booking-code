import type { NextFunction, Request, RequestHandler, Response } from 'express';
import type { ZodType } from 'zod';

import { AppError } from '../lib/errors.js';

/**
 * Zod validation at the route edge, before anything reaches a service.
 *
 * The service layer is then free to trust its inputs — it never re-checks that a code is a
 * string or that an array is non-empty. Malformed input becomes a 400 with a field-level
 * message here, instead of a 500 thrown from somewhere three layers down.
 *
 * The parsed value replaces the raw one, so handlers read typed, coerced data rather than
 * `unknown` from the wire.
 */

export function validateBody<T>(schema: ZodType<T>): RequestHandler {
  return (req: Request, _res: Response, next: NextFunction) => {
    const result = schema.safeParse(req.body);

    if (!result.success) {
      next(new AppError('invalid_request', formatIssues(result.error.issues)));
      return;
    }

    req.body = result.data;
    next();
  };
}

export function validateQuery<T>(schema: ZodType<T>): RequestHandler {
  return (req: Request, _res: Response, next: NextFunction) => {
    const result = schema.safeParse(req.query);

    if (!result.success) {
      next(new AppError('invalid_request', formatIssues(result.error.issues)));
      return;
    }

    // Express 5 makes req.query a getter, so assigning to it throws. Handlers read the
    // validated value from res.locals instead.
    _res.locals.query = result.data;
    next();
  };
}

/** Reads the value put there by `validateQuery`. */
export function validatedQuery<T>(res: Response): T {
  return res.locals.query as T;
}

type Issue = { path: PropertyKey[]; message: string };

function formatIssues(issues: readonly Issue[]): string {
  return issues
    .map((issue) => {
      const path = issue.path.map(String).join('.');
      return path ? `${path}: ${issue.message}` : issue.message;
    })
    .join('; ');
}

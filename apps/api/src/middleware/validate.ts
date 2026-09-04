import type { NextFunction, Request, RequestHandler, Response } from 'express';
import type { ZodType } from 'zod';

import { AppError, ERROR_CODES, type ErrorCode } from '../lib/errors.js';

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
      next(validationError(result.error.issues));
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
      next(validationError(result.error.issues));
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

/**
 * Path params. Worth validating even though Express already matched the route: a param goes
 * straight into an upstream URL, and this endpoint must not be a wider door than Betway's.
 */
export function validateParams<T>(schema: ZodType<T>): RequestHandler {
  return (req: Request, res: Response, next: NextFunction) => {
    const result = schema.safeParse(req.params);

    if (!result.success) {
      next(validationError(result.error.issues));
      return;
    }

    res.locals.params = result.data;
    next();
  };
}

/** Reads the value put there by `validateParams`. */
export function validatedParams<T>(res: Response): T {
  return res.locals.params as T;
}

type Issue = { path: PropertyKey[]; message: string; params?: Record<string, unknown> };

/**
 * Most validation failures are `invalid_request`, but a few have their own documented code —
 * `too_many_outcomes` for an oversized slip (docs/backend-api.md §1). Rather than teach this
 * middleware which endpoint is which, a schema declares the code on its own issue and this
 * reads it back. The middleware stays generic; the mapping lives next to the rule it belongs to.
 *
 * Only 4xx codes are honoured. A schema is describing what the *caller* got wrong, so letting
 * one declare `upstream_error` or `internal_error` would report a bad request as an incident —
 * and the whole value of these codes is that a bug and an expected outcome look different in
 * the logs.
 *
 * Generic failures keep the `field: message` form, because there "which field" is the useful
 * half. A declared code does not, because the schema already wrote the whole sentence.
 */
function validationError(issues: readonly Issue[]): AppError {
  for (const issue of issues) {
    const code = issue.params?.errorCode;
    if (typeof code !== 'string' || !(code in ERROR_CODES)) continue;

    const candidate = code as ErrorCode;
    if (ERROR_CODES[candidate] < 400 || ERROR_CODES[candidate] >= 500) continue;

    // A schema that declared its own code also wrote a finished sentence for it, so it is used
    // as-is. Prefixing it with the field path ("outcomeIds: A slip can hold at most 20…") turns
    // a line meant for a user back into a developer's assertion.
    return new AppError(candidate, issue.message);
  }

  return new AppError('invalid_request', formatIssues(issues));
}

function formatIssues(issues: readonly Issue[]): string {
  return issues
    .map((issue) => {
      const path = issue.path.map(String).join('.');
      return path ? `${path}: ${issue.message}` : issue.message;
    })
    .join('; ');
}

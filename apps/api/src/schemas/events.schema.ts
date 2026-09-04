import { z } from 'zod';

import { skipField } from './paging.js';

/**
 * `limit` is capped so a client cannot ask this endpoint to fan out into an unbounded number
 * of upstream calls. The cap still mirrors Betway's own paging; the *name* does not, because
 * a client writes this alongside `/api/booking-codes/popular?limit=` and two words for one
 * concept is a cost paid by every consumer to save one word here.
 *
 * `sport` is bounded for a different reason: it lands in a Redis key (`events:{sport}:{skip}:{limit}`),
 * so an unbounded string is unbounded key cardinality and key size. Every id upstream actually
 * uses is a short slug — `soccer`, `table-tennis`, `american-football`.
 */
export const eventsQuerySchema = z.object({
  sport: z.string().trim().min(1).max(32, 'sport must be 32 characters or fewer.').default('soccer'),
  limit: z.coerce
    .number({ error: 'limit must be a number.' })
    .int('limit must be a whole number.')
    .min(1, 'Ask for at least one event.')
    .max(50, 'You can ask for at most 50 events at a time.')
    .default(20),
  skip: skipField,
});

export type EventsQuery = z.infer<typeof eventsQuerySchema>;

/**
 * The path param for `GET /api/events/:eventId/markets`.
 *
 * Digits only: the value is interpolated into an upstream URL, and Express has already matched
 * the route by the time this runs, so this is the only thing standing between an arbitrary
 * path segment and Betway.
 */
export const eventParamsSchema = z.object({
  eventId: z
    .string()
    .regex(/^\d{1,20}$/, 'eventId must be a number.'),
});

export type EventParams = z.infer<typeof eventParamsSchema>;

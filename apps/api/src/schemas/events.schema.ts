import { z } from 'zod';

/**
 * `take` is capped so a client cannot ask this endpoint to fan out into an unbounded number
 * of upstream calls — it mirrors Betway's own paging (docs/backend-api.md §2).
 *
 * `sport` is bounded for a different reason: it lands in a Redis key (`events:{sport}:{take}`),
 * so an unbounded string is unbounded key cardinality and key size. Every id upstream actually
 * uses is a short slug — `soccer`, `table-tennis`, `american-football`.
 */
export const eventsQuerySchema = z.object({
  sport: z.string().trim().min(1).max(32, 'sport must be 32 characters or fewer.').default('soccer'),
  take: z.coerce.number().int().min(1).max(50).default(20),
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

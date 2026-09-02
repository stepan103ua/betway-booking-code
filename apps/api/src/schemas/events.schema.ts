import { z } from 'zod';

/**
 * `take` is capped so a client cannot ask this endpoint to fan out into an unbounded number
 * of upstream calls — it mirrors Betway's own paging (docs/backend-api.md §2).
 */
export const eventsQuerySchema = z.object({
  sport: z.string().trim().min(1).default('soccer'),
  take: z.coerce.number().int().min(1).max(50).default(20),
});

export type EventsQuery = z.infer<typeof eventsQuerySchema>;

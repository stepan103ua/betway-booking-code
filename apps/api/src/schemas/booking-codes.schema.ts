import { z } from 'zod';

/**
 * Request schemas for the three core operations.
 *
 * These carry bounds Betway itself does not enforce. That is intentional: our endpoint should
 * not be a wider door than theirs. An unbounded `outcomeIds` array is an open invitation to
 * build a 500-leg slip and hammer `BookABet` through us (docs/backend-api.md §1).
 */

/** `BW` + 8 hex characters, case-insensitive (docs/betway-api.md §2). */
const bookingCode = z
  .string()
  .trim()
  .toUpperCase()
  .regex(/^BW[0-9A-F]{8}$/, 'Booking codes look like BW followed by 8 characters.');

/**
 * Bounded and shape-checked, not merely non-empty.
 *
 * Betway will happily mint a booking code from an outcome id that does not exist — verified:
 * `00000000000` returned a real code, which then decoded to zero selections
 * (docs/betway-api.md §3). Nothing here can catch a well-formed id that has since been
 * withdrawn, but it does stop free-form junk from reaching `BookABet` and coming back as a
 * code that our own `/resolve` answers 404 for.
 *
 * The pattern is deliberately loose about the composite part — ids embed market parameters as
 * text (`7426320018total=6.5~12`, §6) and the grammar of those is not fully known, so this
 * checks "starts with digits, contains only id characters, bounded length" rather than
 * guessing at a form Betway might extend.
 */
const outcomeId = z
  .string()
  .trim()
  .regex(/^[0-9][0-9a-z=.~-]{5,63}$/, 'That does not look like a selection id.');

export const resolveBodySchema = z.object({
  code: bookingCode,
});

/** The cap from docs/backend-api.md §1. Betway enforces none; this is our own door. */
const MAX_OUTCOMES = 20;

/**
 * Over the cap gets its own error code rather than a generic `invalid_request`, because it is
 * the one validation failure a client can act on: "remove a selection" is a different UI from
 * "your request was malformed". `ERROR_CODES.too_many_outcomes` exists for exactly this and
 * had no emitter until now.
 */
const outcomeIds = z
  .array(outcomeId)
  .min(1, 'A slip needs at least one selection.')
  .superRefine((ids, ctx) => {
    if (ids.length <= MAX_OUTCOMES) return;
    ctx.addIssue({
      code: 'custom',
      message: `A slip can hold at most ${MAX_OUTCOMES} selections.`,
      params: { errorCode: 'too_many_outcomes' },
    });
  });

export const createBodySchema = z.object({ outcomeIds });

export const convertBodySchema = z.object({
  code: bookingCode,
  dropOutcomeIds: z.array(outcomeId).max(MAX_OUTCOMES).default([]),
});

export type ResolveBody = z.infer<typeof resolveBodySchema>;
export type CreateBody = z.infer<typeof createBodySchema>;
export type ConvertBody = z.infer<typeof convertBodySchema>;

/**
 * `GET /api/booking-codes/popular`.
 *
 * `limit` is capped harder than the other list endpoints because it drives a **fan-out**: the
 * catalogue carries no odds, so every code costs one decode to enrich (docs/betway-api.md §5).
 * Twenty codes is twenty-one upstream calls and roughly seven hundred selections on the wire;
 * six is what the Decode empty state actually shows.
 */
export const popularQuerySchema = z.object({
  limit: z.coerce
    .number({ error: 'limit must be a number.' })
    .int('limit must be a whole number.')
    .min(1, 'Ask for at least one code.')
    .max(20, 'You can ask for at most 20 codes at a time.')
    .default(6),
});

export type PopularQuery = z.infer<typeof popularQuerySchema>;

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

const outcomeId = z.string().trim().min(1, 'An outcome id cannot be empty.');

export const resolveBodySchema = z.object({
  code: bookingCode,
});

export const createBodySchema = z.object({
  outcomeIds: z
    .array(outcomeId)
    .min(1, 'A slip needs at least one selection.')
    .max(20, 'A slip can hold at most 20 selections.'),
});

export const convertBodySchema = z.object({
  code: bookingCode,
  dropOutcomeIds: z.array(outcomeId).max(20).default([]),
});

export type ResolveBody = z.infer<typeof resolveBodySchema>;
export type CreateBody = z.infer<typeof createBodySchema>;
export type ConvertBody = z.infer<typeof convertBodySchema>;

import { z } from 'zod';

import type { Selection, Slip } from '@booking-code/contracts';

import { AppError } from '../lib/errors.js';

/**
 * Betway's response shape → our DTOs. The whole of the upstream vocabulary stops here.
 *
 * A pure function with a schema in front of it, deliberately separate from the provider so it
 * can be tested without HTTP. The parser is where the mapping traps live, so it is the part of
 * this service most worth testing directly (docs/backend.md §7).
 *
 * Validating upstream with Zod rather than casting means a shape change fails loudly at the
 * boundary with a readable message, instead of producing `undefined` fields three layers up
 * where the cause is no longer obvious. The schema is strict about the fields we read and
 * indifferent to the rest — Betway sends far more than we use, and none of it should be a
 * reason to reject a response.
 */

/**
 * Staleness is reported in six places, not the three that docs/betway-api.md §2 lists. The
 * nested objects carry `market.isSuspended`, `sportEvent.isFinished` and
 * `outcome.isTradingActive`, and each is a genuine reason a leg cannot be bet.
 *
 * All are optional: a missing signal defaults to active. A null sub-object is a gap in what
 * upstream told us, and treating silence as "dead" would drop legs that are perfectly live —
 * Convert removes inactive legs, so a false negative here silently shrinks a user's slip.
 */
const selectionSchema = z.object({
  outcomeId: z.string(),
  marketName: z.string(),
  outcomeName: z.string(),
  eventName: z.string(),
  eventEpoch: z.number(),
  // Nullable on purpose. An outcome that is not being priced — suspended market, finished
  // event — can come back without one, and that is precisely the leg this product exists to
  // show. Requiring a number here would turn one dead leg into a 502 for the whole slip.
  priceDecimal: z.number().nullish(),
  league: z.string().nullish(),

  isMarketActive: z.boolean().nullish(),
  isEventActive: z.boolean().nullish(),
  isOutcomeActive: z.boolean().nullish(),

  market: z.object({ isSuspended: z.boolean().nullish() }).nullish(),
  sportEvent: z.object({ isFinished: z.boolean().nullish() }).nullish(),
  outcome: z.object({ isTradingActive: z.boolean().nullish() }).nullish(),
});

export const findBookABetSchema = z.object({
  selections: z.array(selectionSchema),
  isBuildABet: z.boolean().nullish(),
  isSingleBet: z.boolean().nullish(),
});

export type FindBookABetResponse = z.infer<typeof findBookABetSchema>;

/**
 * Parses an upstream `FindBookABet` body, throwing `upstream_error` if it is not the shape we
 * know. Kept separate from `toSlip` so tests can map a known-good object without going through
 * validation, and so the provider validates exactly once.
 */
export function parseFindBookABet(body: unknown): FindBookABetResponse {
  const result = findBookABetSchema.safeParse(body);

  if (!result.success) {
    throw AppError.upstream(
      'Betway returned a slip we could not read.',
      result.error.issues.map((issue) => `${issue.path.join('.')}: ${issue.message}`).join('; '),
    );
  }

  return result.data;
}

/** Upstream selection → our `Selection`. */
function toSelection(raw: FindBookABetResponse['selections'][number]): Selection {
  return {
    outcomeId: raw.outcomeId,
    marketName: raw.marketName.trim(),
    // On Totals markets this arrives as `"Over "` — trailing space, and meaningless on its
    // own. The line it refers to is already in `marketName` ("Total (1.5)"), so trimming is
    // all that is needed; composing the two is the client's job.
    outcomeName: raw.outcomeName.trim(),
    eventName: raw.eventName.trim(),
    league: raw.league?.trim() ?? '',
    // `eventEpoch` is unix **seconds**. Feeding it to `new Date()` unmultiplied yields 1970
    // and still renders happily, which is what makes this worth a comment.
    kickoffAt: new Date(raw.eventEpoch * 1000).toISOString(),
    // 0 means "upstream is not pricing this right now". `isBettable` reads the same absence and
    // marks the leg inactive, and `totalOdds` skips it rather than multiplying the accumulator
    // down to nothing.
    odds: raw.priceDecimal ?? 0,
    isActive: isBettable(raw),
  };
}

function isBettable(raw: FindBookABetResponse['selections'][number]): boolean {
  return (
    // No price is itself a reason a leg cannot be bet, and it is the seventh signal — the other
    // six can all say "active" while upstream quietly stops quoting the outcome.
    raw.priceDecimal != null &&
    raw.isMarketActive !== false &&
    raw.isEventActive !== false &&
    raw.isOutcomeActive !== false &&
    raw.market?.isSuspended !== true &&
    raw.sportEvent?.isFinished !== true &&
    raw.outcome?.isTradingActive !== false
  );
}

/**
 * The full mapping. `bookingCode` is echoed from the request because upstream does not return
 * it — the response says what is in the slip, not which code asked for it.
 */
export function toSlip(raw: FindBookABetResponse, bookingCode: string): Slip {
  const selections = raw.selections.map(toSelection);

  // A slip with no legs is not a slip. Returning one as a 200 would render an empty card
  // instead of "that code doesn't look right", which is the answer the user actually needs.
  if (selections.length === 0) throw AppError.invalidCode();

  return {
    bookingCode,
    totalOdds: totalOdds(selections),
    // Neither is available from `FindBookABet`; it returns only selections and two booleans.
    // The public catalogue (`Widget/BookingCodes`) carries an expiry and a use count, but only
    // for its ~120 listed codes — enriching from it would add an upstream call to every decode
    // for data that is absent for most codes. Both fields are nullable for exactly this reason.
    expiresAt: null,
    usageCount: null,
    selections,
  };
}

/**
 * Accumulator odds multiply. Rounded to 2dp because the product of decimals accumulates
 * float noise fast — seven legs is enough to turn 2.76 into 2.7600000000000007.
 *
 * Computed over every leg that has a price, including inactive ones: this is what the code
 * contains. Convert recomputes over the legs it keeps, which is why its result carries
 * `previousTotalOdds`.
 *
 * Unpriced legs are skipped rather than multiplied in, since a 0 would collapse the whole
 * accumulator and report a total nobody's slip has.
 */
function totalOdds(selections: Selection[]): number {
  const product = selections
    .filter((selection) => selection.odds > 0)
    .reduce((total, selection) => total * selection.odds, 1);

  return Math.round(product * 100) / 100;
}

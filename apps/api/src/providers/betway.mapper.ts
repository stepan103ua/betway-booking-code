import { z } from 'zod';

import type { Selection, Slip } from '@booking-code/contracts';

import { AppError } from '../lib/errors.js';
import { totalOdds } from '../lib/odds.js';

import type { CatalogueCode } from './booking-code-provider.js';

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
 * `BookABet`'s response — the whole of it is one field.
 *
 * Validated rather than cast for the usual reason, plus a specific one: this is the only
 * write in the service, so a malformed response here means we have created something upstream
 * and cannot tell the caller what it is. Better a 502 than a `{ bookingCode: undefined }`.
 */
export const bookABetSchema = z.object({
  bookingCode: z.string().trim().min(1),
});

export function parseBookABet(body: unknown): string {
  const result = bookABetSchema.safeParse(body);

  if (!result.success) {
    throw AppError.upstream(
      'Betway did not return a booking code.',
      result.error.issues.map((issue) => `${issue.path.join('.')}: ${issue.message}`).join('; '),
    );
  }

  return result.data.bookingCode;
}

/**
 * The public catalogue (docs/betway-api.md §5).
 *
 * `bets[]` is parsed but not mapped: it carries bare ids with no names or prices, so it can
 * confirm the shape and nothing more. The decode is the source of truth for what a code
 * contains — §2 records a code listed with 8 bets decoding to 7 selections.
 */
const catalogueEntrySchema = z.object({
  bookingCode: z.string(),
  /** An offset datetime with sub-second precision: `2026-09-04T11:26:42.9704472+02:00`. */
  expiryDateTime: z.string().nullish(),
  /** How many times the code has been used. Upstream sorts the list by this, descending. */
  count: z.number(),
  bets: z.array(z.object({ outcomeID: z.string() })),
});

export const widgetBookingCodesSchema = z.object({
  data: z.array(catalogueEntrySchema),
});

export function parseWidgetBookingCodes(body: unknown): z.infer<typeof widgetBookingCodesSchema> {
  const result = widgetBookingCodesSchema.safeParse(body);

  if (!result.success) {
    throw AppError.upstream(
      'Betway returned a code list we could not read.',
      result.error.issues.map((issue) => `${issue.path.join('.')}: ${issue.message}`).join('; '),
    );
  }

  return result.data;
}

/** Order is upstream's — already sorted by usage — so it is preserved rather than re-sorted. */
export function toCatalogueCodes(raw: z.infer<typeof widgetBookingCodesSchema>): CatalogueCode[] {
  return raw.data.map((entry) => ({
    bookingCode: entry.bookingCode.trim().toUpperCase(),
    expiresAt: toIso(entry.expiryDateTime),
    usageCount: entry.count,
  }));
}

/**
 * Upstream's offset datetime → ISO. Unparseable input becomes `null` rather than an
 * `Invalid Date` that survives serialisation as the string "Invalid Date".
 */
function toIso(value: string | null | undefined): string | null {
  if (!value) return null;

  const parsed = new Date(value);
  return Number.isNaN(parsed.getTime()) ? null : parsed.toISOString();
}

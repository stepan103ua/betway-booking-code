import { z } from 'zod';

import type { Fixture, Market, MarketOutcome, Sport } from '@booking-code/contracts';

import { AppError } from '../lib/errors.js';

/**
 * Betway's browse responses → our DTOs. Companion to `betway.mapper.ts`, which does the same
 * job for a decoded slip; the split is by upstream endpoint family, not by layer.
 *
 * Three upstream shapes land here — the sport list, `BetBook/Upcoming`, and one market group
 * for an event. The last two are the *same* flat, id-joined shape (docs/betway-api.md §4.3),
 * so they share `buildMarkets` and every trap it handles is fixed once for both.
 */

/* ------------------------------------------------------------------ sports */

const sportSchema = z.object({
  sportId: z.string(),
  name: z.string(),
  /**
   * `"Sport"` or `"Promo"`. The list is Betway's *navigation* menu, so it carries three
   * entries that are not sports at all — `Codes`, `Swipe Bet`, `Betway Stream` — each with a
   * `redirectURL` into their web app. Passing one to `/api/events` returns nothing, so a
   * picker built from the unfiltered list offers dead options.
   */
  sportType: z.string().nullish(),
});

export const configSportsSchema = z.object({ sports: z.array(sportSchema) });

export function parseConfigSports(body: unknown): z.infer<typeof configSportsSchema> {
  return parse(configSportsSchema, body, 'Betway returned a sport list we could not read.');
}

export function toSports(raw: z.infer<typeof configSportsSchema>): Sport[] {
  return raw.sports
    .filter((sport) => sport.sportType === 'Sport')
    .map((sport) => ({ id: sport.sportId, name: sport.name.trim() }));
}

/* ------------------------------------------------- markets, shared by both feeds */

const marketSchema = z.object({
  marketId: z.string(),
  eventId: z.number(),
  /** Display-ready. `name` is `"[Win/Draw/Win]"` — the query-param form, not a UI string. */
  displayName: z.string(),
  marketTypeCName: z.string(),
  /**
   * A market with a line (Total, Handicap) arrives twice: a parent holding the outcomes under
   * a generic name ("Total Goals"), and a squashed child holding the qualified name
   * ("Total (6.5)") with no outcomes of its own. Keeping both emits one market with a
   * meaningless name and one that is empty.
   */
  isSquashedParent: z.boolean().nullish(),
  isActive: z.boolean().nullish(),
  isSuspended: z.boolean().nullish(),
  shouldDisplay: z.boolean().nullish(),
});

const outcomeSchema = z.object({
  outcomeId: z.string(),
  marketId: z.string(),
  /**
   * The join key, and not the same thing as `marketId` on a squashed market: `marketId`
   * points at the parent, `originalMarketId` at the child whose name carries the line — and
   * it is the child's id that prefixes `outcomeId`. Equal to `marketId` everywhere else, so
   * `originalMarketId ?? marketId` is the single rule for both feeds.
   */
  originalMarketId: z.string().nullish(),
  displayName: z.string(),
  /** Upstream's ranking. For 1X2: 2, 3, 4 — home, draw, away. */
  index: z.number().nullish(),
  isTradingActive: z.boolean().nullish(),
  shouldDisplay: z.boolean().nullish(),
});

const priceSchema = z.object({
  outcomeId: z.string(),
  priceDecimal: z.number().nullish(),
});

type RawMarket = z.infer<typeof marketSchema>;
type RawOutcome = z.infer<typeof outcomeSchema>;
type RawPrice = z.infer<typeof priceSchema>;

/**
 * Outcomes, priced and ordered, filed under the market that owns them.
 *
 * Built once per upstream response rather than once per event: the feed sends one flat
 * `outcomes` array for every event in the page, so indexing inside the per-event loop would
 * rebuild the whole thing `events.length` times.
 *
 * Three things are dropped rather than surfaced, all for the same reason: `Market` has no
 * "unavailable" flag, so anything a user could not actually back would render as a live
 * button. A slip's `Selection` does carry `isActive`, because there the point is to *show*
 * you a dead leg; a picker's job is the opposite.
 */
function indexOutcomes(
  outcomes: RawOutcome[],
  prices: RawPrice[],
): Map<string, MarketOutcome[]> {
  // One map per entity type, and every join reads an explicit field. Market ids and outcome
  // ids share a namespace and do collide — on event 74263200, "7426320011" is both the Draw No
  // Bet market and the 1X2 home outcome — so a shared map, or a `startsWith` join, silently
  // attaches outcomes to the wrong market (docs/betway-api.md §6).
  const priceByOutcome = new Map(prices.map((price) => [price.outcomeId, price.priceDecimal]));
  const ranked = new Map<string, { rank: number; outcome: MarketOutcome }[]>();

  for (const outcome of outcomes) {
    if (outcome.isTradingActive === false || outcome.shouldDisplay === false) continue;

    const odds = priceByOutcome.get(outcome.outcomeId);
    // No price means upstream is not quoting this outcome right now. There is nothing to put
    // in `odds` — a 0 renders as a selectable button at 0.00 — so it does not appear.
    if (odds == null || odds <= 0) continue;

    const marketId = outcome.originalMarketId ?? outcome.marketId;
    const list = ranked.get(marketId) ?? [];

    list.push({
      // Unranked sorts last rather than first: an outcome upstream declined to place is not
      // one to show in the leading position of a picker.
      rank: outcome.index ?? Number.MAX_SAFE_INTEGER,
      outcome: {
        outcomeId: outcome.outcomeId,
        // `"Over "` arrives with a trailing space (docs/betway-api.md §5).
        label: outcome.displayName.trim(),
        odds,
      },
    });

    ranked.set(marketId, list);
  }

  return new Map(
    [...ranked].map(([marketId, entries]) => [
      marketId,
      entries.sort((a, b) => a.rank - b.rank).map((entry) => entry.outcome),
    ]),
  );
}

/** Filters the markets worth showing and attaches the outcomes indexed above. */
function buildMarkets(
  markets: RawMarket[],
  outcomesByMarket: Map<string, MarketOutcome[]>,
): Market[] {
  return markets
    .filter(
      (market) =>
        market.isSquashedParent !== true &&
        market.isActive !== false &&
        market.isSuspended !== true &&
        market.shouldDisplay !== false,
    )
    .map((market) => ({
      marketId: market.marketId,
      name: market.displayName.trim(),
      type: market.marketTypeCName,
      outcomes: outcomesByMarket.get(market.marketId) ?? [],
    }))
    // A market whose outcomes were all filtered out is an empty row in the picker.
    .filter((market) => market.outcomes.length > 0);
}

/* ------------------------------------------------------- upcoming events feed */

const upcomingEventSchema = z.object({
  eventId: z.number(),
  name: z.string(),
  league: z.string().nullish(),
  /** Unix **seconds**. Unmultiplied it yields 1970 and still renders happily. */
  expectedStartEpoch: z.number(),
  isActive: z.boolean().nullish(),
  isFinished: z.boolean().nullish(),
});

export const betBookUpcomingSchema = z.object({
  events: z.array(upcomingEventSchema),
  markets: z.array(marketSchema),
  outcomes: z.array(outcomeSchema),
  prices: z.array(priceSchema),
  /**
   * The feed's only paging signal — it reports no total. Optional because a missing flag should
   * not fail the whole read; absent means "assume there is more", which costs one empty page at
   * worst and never hides a fixture.
   */
  isFinalPage: z.boolean().nullish(),
});

export function parseBetBookUpcoming(body: unknown): z.infer<typeof betBookUpcomingSchema> {
  return parse(betBookUpcomingSchema, body, 'Betway returned an event list we could not read.');
}

/**
 * `hasMore` comes from upstream's own flag rather than from how many fixtures survived
 * filtering: a page can legitimately yield zero renderable events — every market suspended, say
 * — while more pages remain. Deriving it from the result count would stop paging early and hide
 * them.
 */
export function toFixturesPage(raw: z.infer<typeof betBookUpcomingSchema>): {
  events: Fixture[];
  hasMore: boolean;
} {
  return { events: toFixtures(raw), hasMore: raw.isFinalPage !== true };
}

export function toFixtures(raw: z.infer<typeof betBookUpcomingSchema>): Fixture[] {
  const marketsByEvent = new Map<number, RawMarket[]>();
  for (const market of raw.markets) {
    marketsByEvent.set(market.eventId, [...(marketsByEvent.get(market.eventId) ?? []), market]);
  }

  const outcomesByMarket = indexOutcomes(raw.outcomes, raw.prices);

  return raw.events
    .filter((event) => event.isActive !== false && event.isFinished !== true)
    .map((event) => ({
      eventId: String(event.eventId),
      name: event.name.trim(),
      league: event.league?.trim() ?? '',
      kickoffAt: new Date(event.expectedStartEpoch * 1000).toISOString(),
      markets: buildMarkets(marketsByEvent.get(event.eventId) ?? [], outcomesByMarket),
    }))
    // An event with no priced market is nothing a picker can offer.
    .filter((fixture) => fixture.markets.length > 0);
}

/* --------------------------------------------------- one market group for an event */

export const marketGroupSchema = z.object({
  marketsInGroup: z.array(marketSchema),
  outcomes: z.array(outcomeSchema),
  prices: z.array(priceSchema),
});

export function parseMarketGroup(body: unknown): z.infer<typeof marketGroupSchema> {
  return parse(marketGroupSchema, body, 'Betway returned a market list we could not read.');
}

export function toMarkets(raw: z.infer<typeof marketGroupSchema>): Market[] {
  return buildMarkets(raw.marketsInGroup, indexOutcomes(raw.outcomes, raw.prices));
}

/* ---------------------------------------------------------------------- shared */

/**
 * Validating upstream rather than casting means a shape change fails at the boundary with a
 * readable message, instead of surfacing as `undefined` three layers up.
 */
function parse<T>(schema: z.ZodType<T>, body: unknown, message: string): T {
  const result = schema.safeParse(body);

  if (!result.success) {
    throw AppError.upstream(
      message,
      result.error.issues.map((issue) => `${issue.path.join('.')}: ${issue.message}`).join('; '),
    );
  }

  return result.data;
}

import type { Fixture, Market, MarketOutcome, Selection } from '@booking-code/contracts';

/**
 * One leg the user has added while building a slip, before any code exists — the one UI-only
 * shape this app carries (docs/frontend.md §4 / docs/mobile.md §3). It is an aggregate of
 * event + market + outcome that no single endpoint returns, so it lives in `lib/`, not in a
 * contract type.
 */
export type DraftPick = {
  outcomeId: string;
  outcomeLabel: string;
  marketName: string;
  eventId: string;
  eventName: string;
  league: string;
  kickoffAt: string;
  odds: number;
};

/** The cap `POST /api/booking-codes` enforces (docs/backend-api.md §1) — held here so the
 * picker stops at 20 rather than letting the 21st leg round-trip as `too_many_outcomes`. */
export const MAX_DRAFT = 20;

export function draftPick(event: Fixture, market: Market, outcome: MarketOutcome): DraftPick {
  return {
    outcomeId: outcome.outcomeId,
    outcomeLabel: outcome.label,
    marketName: market.name,
    eventId: event.eventId,
    eventName: event.name,
    league: event.league,
    kickoffAt: event.kickoffAt,
    odds: outcome.odds,
  };
}

/**
 * Add the leg if it is new and there is room; remove it if already there. A remove always
 * succeeds, even at the cap. One pick per event — a booking code is a plain accumulator, so
 * two legs on one match conflict (docs/betway-api.md §3); the picker disables the other
 * outcomes, this is the guard behind it.
 */
export function togglePick(picks: DraftPick[], pick: DraftPick): DraftPick[] {
  const without = picks.filter((p) => p.outcomeId !== pick.outcomeId);
  if (without.length !== picks.length) return without;
  if (picks.length >= MAX_DRAFT) return picks;
  if (picks.some((p) => p.eventId === pick.eventId)) return picks;
  return [...picks, pick];
}

/** Product of every leg's odds — the same computation the backend does for `Slip.totalOdds`. */
export const draftTotalOdds = (picks: DraftPick[]): number =>
  picks.reduce((running, p) => running * p.odds, 1);

/**
 * Render a pick through the shared `SelectionRow` / `SlipCard` — always `isActive: true`, a
 * leg just picked cannot be a dead leg yet (the server's read-back is what surfaces one that
 * died, as `outcomes_unavailable`).
 */
export const draftToSelection = (pick: DraftPick): Selection => ({
  outcomeId: pick.outcomeId,
  eventId: pick.eventId,
  marketName: pick.marketName,
  outcomeName: pick.outcomeLabel,
  eventName: pick.eventName,
  league: pick.league,
  kickoffAt: pick.kickoffAt,
  odds: pick.odds,
  isActive: true,
});

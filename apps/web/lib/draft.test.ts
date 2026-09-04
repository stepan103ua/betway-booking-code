import { describe, expect, it } from 'vitest';
import { type DraftPick, MAX_DRAFT, draftTotalOdds, togglePick } from './draft';

const pick = (over: Partial<DraftPick> = {}): DraftPick => ({
  outcomeId: 'o1',
  outcomeLabel: 'Home',
  marketName: '1X2',
  eventId: 'e1',
  eventName: 'A vs B',
  league: 'L',
  kickoffAt: '2026-09-04T18:00:00Z',
  odds: 2,
  ...over,
});

describe('togglePick', () => {
  it('adds a new leg', () => {
    expect(togglePick([], pick())).toHaveLength(1);
  });

  it('removes a leg already in the draft', () => {
    expect(togglePick([pick()], pick())).toEqual([]);
  });

  it('a remove succeeds even at the cap', () => {
    const full = Array.from({ length: MAX_DRAFT }, (_, i) =>
      pick({ outcomeId: `o${i}`, eventId: `e${i}` }),
    );
    expect(togglePick(full, full[0]!)).toHaveLength(MAX_DRAFT - 1);
  });

  it('refuses a second leg on the same event', () => {
    const first = [pick({ outcomeId: 'o1', eventId: 'e1' })];
    expect(togglePick(first, pick({ outcomeId: 'o2', eventId: 'e1' }))).toEqual(first);
  });

  it('refuses an add past the cap', () => {
    const full = Array.from({ length: MAX_DRAFT }, (_, i) =>
      pick({ outcomeId: `o${i}`, eventId: `e${i}` }),
    );
    expect(togglePick(full, pick({ outcomeId: 'new', eventId: 'new' }))).toBe(full);
  });
});

describe('draftTotalOdds', () => {
  it('multiplies every leg, 1 for empty', () => {
    expect(draftTotalOdds([])).toBe(1);
    expect(
      draftTotalOdds([pick({ odds: 1.5 }), pick({ outcomeId: 'o2', eventId: 'e2', odds: 2 })]),
    ).toBe(3);
  });
});

import { describe, expect, it } from 'vitest';
import type { Selection } from '@booking-code/contracts';
import { convertPreview } from './convert-preview';

const leg = (id: string, odds: number, isActive = true): Selection => ({
  outcomeId: id,
  eventId: `e-${id}`,
  marketName: '1X2',
  outcomeName: 'Home',
  eventName: 'A vs B',
  league: 'L',
  kickoffAt: '2026-09-04T18:00:00Z',
  odds,
  isActive,
});

describe('convertPreview', () => {
  it('keeps live, undropped legs and multiplies their odds', () => {
    const p = convertPreview([leg('a', 2), leg('b', 1.5), leg('c', 3)], new Set(['b']));
    expect(p.kept.map((s) => s.outcomeId)).toEqual(['a', 'c']);
    expect(p.previewOdds).toBe(6);
    expect(p.droppedCount).toBe(1);
    expect(p.canConvert).toBe(true);
  });

  it('counts dead legs as dropped without needing them in the set', () => {
    const p = convertPreview([leg('a', 2), leg('b', 2, false)], new Set());
    expect(p.deadCount).toBe(1);
    expect(p.droppedCount).toBe(1);
    expect(p.kept.map((s) => s.outcomeId)).toEqual(['a']);
  });

  it('cannot convert when every leg is dropped or dead', () => {
    expect(convertPreview([leg('a', 2, false), leg('b', 2, false)], new Set()).allDead).toBe(true);
    expect(convertPreview([leg('a', 2), leg('b', 2)], new Set(['a', 'b'])).canConvert).toBe(false);
  });
});

import { describe, expect, it } from 'vitest';
import type { Slip } from '@booking-code/contracts';
import { mergeCodes } from './popular';

const slip = (bookingCode: string): Slip => ({
  bookingCode,
  totalOdds: 2,
  expiresAt: null,
  usageCount: null,
  selections: [],
});

describe('mergeCodes', () => {
  it('appends the next page', () => {
    expect(mergeCodes([slip('A'), slip('B')], [slip('C')]).map((c) => c.bookingCode)).toEqual([
      'A',
      'B',
      'C',
    ]);
  });

  it('drops a code already in the list', () => {
    expect(
      mergeCodes([slip('A'), slip('B')], [slip('B'), slip('C')]).map((c) => c.bookingCode),
    ).toEqual(['A', 'B', 'C']);
  });
});

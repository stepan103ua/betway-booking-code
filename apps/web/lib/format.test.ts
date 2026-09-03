import { describe, expect, it } from 'vitest';
import { formatOdds, formatUsage, slipStatus } from './format';

describe('formatOdds', () => {
  it('always shows two decimals', () => {
    expect(formatOdds(2.3)).toBe('2.30');
    expect(formatOdds(2)).toBe('2.00');
    expect(formatOdds(74.125)).toBe('74.13');
  });
});

describe('formatUsage', () => {
  it('groups thousands', () => {
    expect(formatUsage(9227)).toBe('9,227 loaded');
  });
});

describe('slipStatus', () => {
  it('is live only when every leg is active', () => {
    expect(slipStatus([{ isActive: true }, { isActive: true }])).toBe('live');
    expect(slipStatus([{ isActive: true }, { isActive: false }])).toBe('partial');
  });
});

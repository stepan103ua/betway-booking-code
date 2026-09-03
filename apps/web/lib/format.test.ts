import { describe, expect, it, vi } from 'vitest';
import {
  formatExpiry,
  formatOdds,
  formatUsage,
  isValidCode,
  pluralize,
  slipStatus,
} from './format';

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

describe('formatExpiry', () => {
  it('reads forward and backward from now', () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date('2026-09-04T12:00:00Z'));
    expect(formatExpiry('2026-09-04T14:15:00Z')).toBe('Expires in 2h 15m');
    expect(formatExpiry('2026-09-04T11:55:00Z')).toBe('Expired 5m ago');
    expect(formatExpiry('2026-09-04T13:00:00Z')).toBe('Expires in 1h');
    vi.useRealTimers();
  });
});

describe('pluralize', () => {
  it('switches on count', () => {
    expect(pluralize(1, 'selection')).toBe('1 selection');
    expect(pluralize(3, 'selection')).toBe('3 selections');
  });
});

describe('slipStatus', () => {
  it('is live only when every leg is active', () => {
    expect(slipStatus([{ isActive: true }, { isActive: true }])).toBe('live');
    expect(slipStatus([{ isActive: true }, { isActive: false }])).toBe('partial');
  });
});

describe('isValidCode', () => {
  it('accepts BW + 8 hex, case-insensitively, after trimming', () => {
    expect(isValidCode('BW6E19810C')).toBe(true);
    expect(isValidCode('  bw6e19810c ')).toBe(true);
  });
  it('rejects the wrong shape', () => {
    expect(isValidCode('BW6E19810')).toBe(false); // 7 chars
    expect(isValidCode('BWZZZZZZZZ')).toBe(false); // not hex
    expect(isValidCode('6E19810C')).toBe(false); // no prefix
  });
});

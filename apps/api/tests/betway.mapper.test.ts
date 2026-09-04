import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

import { describe, expect, it } from 'vitest';

import { AppError } from '../src/lib/errors.js';
import {
  parseFindBookABet,
  parseWidgetBookingCodes,
  toCatalogueCodes,
  toSlip,
} from '../src/providers/betway.mapper.js';

/**
 * The parser is where the mapping traps live, so these are the highest-value tests in the
 * service — pure, offline, and run against a **real captured response** rather than an
 * imagined one (see `fixtures/README.md`).
 */

const FIXTURES = join(dirname(fileURLToPath(import.meta.url)), '../fixtures');

function loadFixture(name: string): unknown {
  return JSON.parse(readFileSync(join(FIXTURES, `${name}.json`), 'utf8'));
}

/** A minimal upstream selection, for the cases the capture does not contain. */
function rawSelection(overrides: Record<string, unknown> = {}) {
  return {
    outcomeId: '7393972418total=1.5~12',
    eventId: 73939724,
    marketName: 'Total (1.5)',
    outcomeName: 'Over ',
    eventName: 'Independiente Santa Fe vs. America de Cali Sa',
    eventEpoch: 1788388200,
    priceDecimal: 1.35,
    league: 'Liga Femenina',
    isMarketActive: true,
    isEventActive: true,
    isOutcomeActive: true,
    market: { isSuspended: false },
    sportEvent: { isFinished: false },
    outcome: { isTradingActive: true },
    ...overrides,
  };
}

function slipFrom(...selections: Record<string, unknown>[]) {
  return toSlip(parseFindBookABet({ selections }), 'BW6E487423');
}

describe('toSlip — against the real capture', () => {
  const slip = toSlip(parseFindBookABet(loadFixture('find-book-a-bet')), 'BW6E487423');

  it('echoes the requested code, which upstream does not return', () => {
    expect(slip.bookingCode).toBe('BW6E487423');
  });

  it('maps every selection', () => {
    expect(slip.selections).toHaveLength(4);
  });

  it('produces a Selection matching the documented DTO', () => {
    expect(slip.selections[0]).toEqual({
      outcomeId: expect.any(String),
      eventId: expect.any(String),
      marketName: expect.any(String),
      outcomeName: expect.any(String),
      eventName: expect.any(String),
      league: expect.any(String),
      kickoffAt: expect.any(String),
      odds: expect.any(Number),
      isActive: true,
    });
  });

  it('leaves expiresAt and usageCount null — FindBookABet reports neither', () => {
    expect(slip.expiresAt).toBeNull();
    expect(slip.usageCount).toBeNull();
  });

  it('carries no Betway field names into the DTO', () => {
    const serialised = JSON.stringify(slip);
    for (const upstream of ['priceDecimal', 'eventEpoch', 'isMarketActive', 'sportEvent']) {
      expect(serialised).not.toContain(upstream);
    }
  });
});

describe('field mapping', () => {
  it('reads eventEpoch as seconds, not milliseconds', () => {
    const slip = slipFrom(rawSelection({ eventEpoch: 1788388200 }));

    expect(slip.selections[0]?.kickoffAt).toBe('2026-09-02T22:30:00.000Z');
    // Read as milliseconds this would be 1970 — and would still render as a date, which is
    // what makes the mistake survive a casual look at the UI.
    expect(slip.selections[0]?.kickoffAt).not.toContain('1970');
  });

  it('trims the trailing space Totals markets put on outcomeName', () => {
    const slip = slipFrom(rawSelection({ outcomeName: 'Over ' }));

    expect(slip.selections[0]?.outcomeName).toBe('Over');
  });

  it('leaves a self-describing 1X2 outcome name alone', () => {
    const slip = slipFrom(rawSelection({ outcomeName: 'Arsenal', marketName: '1X2' }));

    expect(slip.selections[0]?.outcomeName).toBe('Arsenal');
  });

  it('defaults a missing league to an empty string rather than undefined', () => {
    const slip = slipFrom(rawSelection({ league: null }));

    expect(slip.selections[0]?.league).toBe('');
  });
});

describe('isActive — six signals, any one of which makes a leg unbettable', () => {
  it.each([
    ['isMarketActive false', { isMarketActive: false }],
    ['isEventActive false', { isEventActive: false }],
    ['isOutcomeActive false', { isOutcomeActive: false }],
    ['market suspended', { market: { isSuspended: true } }],
    ['event finished', { sportEvent: { isFinished: true } }],
    ['outcome not trading', { outcome: { isTradingActive: false } }],
  ])('is false when %s', (_label, override) => {
    const slip = slipFrom(rawSelection(override));

    expect(slip.selections[0]?.isActive).toBe(false);
  });

  it('is true when every signal says bettable', () => {
    expect(slipFrom(rawSelection()).selections[0]?.isActive).toBe(true);
  });

  it('treats a missing nested object as active, not dead', () => {
    // A gap in what upstream told us must not silently shrink a user's slip — Convert drops
    // inactive legs, so a false negative here loses a bet the user wanted.
    const slip = slipFrom(rawSelection({ market: null, sportEvent: null, outcome: null }));

    expect(slip.selections[0]?.isActive).toBe(true);
  });

  it('marks the dead legs in the derived fixture and leaves the rest live', () => {
    const slip = toSlip(parseFindBookABet(loadFixture('find-book-a-bet-inactive')), 'BW00000001');

    expect(slip.selections.map((s) => s.isActive)).toEqual([true, false, false, true]);
  });
});

describe('totalOdds', () => {
  it('multiplies the legs', () => {
    const slip = slipFrom(
      rawSelection({ priceDecimal: 1.5 }),
      rawSelection({ priceDecimal: 2 }),
      rawSelection({ priceDecimal: 3 }),
    );

    expect(slip.totalOdds).toBe(9);
  });

  it('totals the 2dp odds each client shows, not the raw price', () => {
    // Raw 1.234 * 1.234 = 1.522756 -> 1.52, but both legs render as "1.23" on the card and
    // 1.23 * 1.23 = 1.5129 -> 1.51. The badge has to match the numbers next to it.
    const slip = slipFrom(
      rawSelection({ priceDecimal: 1.234 }),
      rawSelection({ priceDecimal: 1.234 }),
    );

    expect(slip.totalOdds).toBe(1.51);
  });

  it('rounds away float noise', () => {
    // 1.26 * 1.1 * 2 is 2.7720000000000002 in IEEE 754.
    const slip = slipFrom(
      rawSelection({ priceDecimal: 1.26 }),
      rawSelection({ priceDecimal: 1.1 }),
      rawSelection({ priceDecimal: 2 }),
    );

    expect(slip.totalOdds).toBe(2.77);
  });

  it('includes inactive legs — the code contains them', () => {
    const slip = slipFrom(
      rawSelection({ priceDecimal: 2 }),
      rawSelection({ priceDecimal: 3, isOutcomeActive: false }),
    );

    expect(slip.totalOdds).toBe(6);
  });

  it('skips unpriced legs instead of collapsing the total to zero', () => {
    const slip = slipFrom(
      rawSelection({ priceDecimal: 2 }),
      rawSelection({ priceDecimal: null }),
      rawSelection({ priceDecimal: 3 }),
    );

    expect(slip.totalOdds).toBe(6);
  });
});

describe('a leg upstream has stopped pricing', () => {
  it('is kept in the slip rather than failing the whole decode', () => {
    // The realistic shape of a dead leg: still flagged active, but no longer quoted. Rejecting
    // it would turn one stale selection into a 502 for a slip that is otherwise fine.
    const slip = slipFrom(rawSelection(), rawSelection({ priceDecimal: null }));

    expect(slip.selections).toHaveLength(2);
  });

  it('is reported as unbettable with zero odds', () => {
    const slip = slipFrom(rawSelection({ priceDecimal: null }));

    expect(slip.selections[0]?.odds).toBe(0);
    expect(slip.selections[0]?.isActive).toBe(false);
  });

  it('is unbettable even when all six other signals say active', () => {
    const slip = slipFrom(
      rawSelection({
        priceDecimal: null,
        isMarketActive: true,
        isEventActive: true,
        isOutcomeActive: true,
        market: { isSuspended: false },
        sportEvent: { isFinished: false },
        outcome: { isTradingActive: true },
      }),
    );

    expect(slip.selections[0]?.isActive).toBe(false);
  });
});

describe('an empty slip', () => {
  it('is a 404, not a 200 with nothing in it', () => {
    // A code that decodes to no legs is not a slip. Returning one would render an empty card
    // where the user needs "that code doesn't look right".
    const error = (() => {
      try {
        slipFrom();
        return null;
      } catch (e) {
        return e as AppError;
      }
    })();

    expect(error?.code).toBe('invalid_code');
    expect(error?.status).toBe(404);
  });
});

describe('parseFindBookABet', () => {
  it('rejects a body that is not a slip rather than half-building one', () => {
    expect(() => parseFindBookABet({ nope: true })).toThrow(AppError);
    expect(() => parseFindBookABet({ nope: true })).toThrow(/could not read/i);
  });

  it('rejects a selection missing a field the DTO cannot do without', () => {
    // outcomeId, not priceDecimal — a price is genuinely optional upstream, an outcome id is
    // the one thing a selection is useless without.
    const { outcomeId: _omitted, ...incomplete } = rawSelection();

    expect(() => parseFindBookABet({ selections: [incomplete] })).toThrow(AppError);
  });

  it('accepts a selection with no price, which upstream really does send', () => {
    expect(() =>
      parseFindBookABet({ selections: [rawSelection({ priceDecimal: null })] }),
    ).not.toThrow();
  });

  it('surfaces as upstream_error, not internal_error', () => {
    try {
      parseFindBookABet({ nope: true });
      expect.unreachable('should have thrown');
    } catch (error) {
      expect((error as AppError).code).toBe('upstream_error');
      expect((error as AppError).status).toBe(502);
    }
  });

  it('ignores the many upstream fields we do not read', () => {
    const raw = { selections: [rawSelection()], isBuildABet: false, accountId: 'x', extra: 1 };

    expect(() => parseFindBookABet(raw)).not.toThrow();
  });
});

describe('toCatalogueCodes', () => {
  const codes = toCatalogueCodes(parseWidgetBookingCodes(loadFixture('widget-booking-codes')));

  it('maps the catalogue onto our field names', () => {
    expect(Object.keys(codes[0]!).sort()).toEqual(['bookingCode', 'expiresAt', 'usageCount']);
    expect(codes[0]!.bookingCode).toMatch(/^BW[0-9A-F]{8}$/);
    expect(codes[0]!.usageCount).toBeGreaterThan(0);
  });

  it('normalises the offset datetime upstream sends to ISO', () => {
    // Upstream: "2026-09-04T11:26:42.9704472+02:00" — an offset, and 7 fractional digits.
    expect(codes[0]!.expiresAt).toMatch(/^\d{4}-\d{2}-\d{2}T[\d:.]+Z$/);
  });

  it('preserves upstream order, which is already sorted by usage', () => {
    // Nothing re-sorts, so dropping codes that fail to decode keeps the popularity ranking.
    const counts = codes.map((code) => code.usageCount);
    expect(counts).toEqual([...counts].sort((a, b) => b - a));
  });

  it('survives an entry with no expiry rather than emitting an Invalid Date', () => {
    const parsed = parseWidgetBookingCodes({
      data: [{ bookingCode: 'BW6E5B94E1', expiryDateTime: null, count: 1, bets: [] }],
    });

    expect(toCatalogueCodes(parsed)[0]!.expiresAt).toBeNull();
  });

  it('turns an unreadable catalogue into upstream_error', () => {
    try {
      parseWidgetBookingCodes({ nope: true });
      expect.unreachable('expected the call to throw');
    } catch (error) {
      expect((error as AppError).code).toBe('upstream_error');
    }
  });
});

import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

import { describe, expect, it } from 'vitest';

import type { AppError } from '../src/lib/errors.js';
import {
  parseBetBookUpcoming,
  parseConfigSports,
  parseMarketGroup,
  toFixtures,
  toMarkets,
  toSports,
} from '../src/providers/betway.catalogue.mapper.js';

/**
 * The browse mapper against the real captures.
 *
 * Every case here is a trap that cost time to find, and each one is invisible from the
 * endpoint tests: the wrong answer is a well-formed 200 that reads fine until you compare it
 * with what Betway actually sent.
 */

const FIXTURES = join(dirname(fileURLToPath(import.meta.url)), '../fixtures');

function load(name: string): unknown {
  return JSON.parse(readFileSync(join(FIXTURES, `${name}.json`), 'utf8'));
}

function captureError(fn: () => unknown): AppError {
  try {
    fn();
    expect.unreachable('expected the call to throw');
  } catch (error) {
    return error as AppError;
  }
}

describe('toSports', () => {
  const sports = toSports(parseConfigSports(load('config-sports')));

  it('maps sportId and name onto the DTO', () => {
    expect(sports).toContainEqual({ id: 'soccer', name: 'Soccer' });
  });

  it('drops the promo entries — they are nav items, not sports', () => {
    // Unfiltered, the picker offers "Codes" as a sport and /api/events returns nothing for it.
    const ids = sports.map((sport) => sport.id);
    expect(ids).not.toContain('Codes');
    expect(ids).not.toContain('Swipe Bet');
    expect(ids).not.toContain('Betway Stream');
  });

  it('keeps every real sport', () => {
    expect(sports).toHaveLength(24);
  });
});

describe('toFixtures', () => {
  const fixtures = toFixtures(parseBetBookUpcoming(load('betbook-upcoming')));
  const fixture = fixtures.find((candidate) => candidate.eventId === '74263200')!;

  it('normalises the event onto the DTO', () => {
    expect(fixture).toMatchObject({
      eventId: '74263200',
      name: 'Everton FC (Gabriel) vs. Chelsea FC (Noah)',
      league: expect.any(String),
    });
    // Upstream sends unix seconds; unmultiplied this would be 1970 and still render happily.
    expect(fixture.kickoffAt).toMatch(/^20\d\d-/);
    expect(new Date(fixture.kickoffAt).getTime()).toBeGreaterThan(0);
  });

  it('returns the 1X2 market as a list entry, not a keyed field', () => {
    expect(fixture.markets).toHaveLength(1);
    expect(fixture.markets[0]).toMatchObject({ name: '1X2', type: 'win-draw-win' });
  });

  it('names the market from displayName, not the query-param form', () => {
    // `name` upstream is "[Win/Draw/Win]" — putting that in the UI is the easy mistake here.
    expect(fixture.markets[0]!.name).not.toContain('[');
  });

  it('orders outcomes home, draw, away — where a 1/X/2 picker gets its columns', () => {
    expect(fixture.markets[0]!.outcomes.map((outcome) => outcome.label)).toEqual([
      'Everton FC (Gabriel)',
      'Draw',
      'Chelsea FC (Noah)',
    ]);
  });

  it('labels outcomes with what upstream calls them, never a positional "Home"', () => {
    const labels = fixtures.flatMap((f) => f.markets.flatMap((m) => m.outcomes.map((o) => o.label)));
    expect(labels).not.toContain('Home');
    expect(labels).not.toContain('Away');
  });

  it('carries decimal odds through from prices', () => {
    for (const outcome of fixture.markets[0]!.outcomes) {
      expect(outcome.odds).toBeGreaterThan(1);
    }
  });
});

describe('toMarkets', () => {
  const markets = toMarkets(parseMarketGroup(load('market-group-main')));
  const byName = (name: string) => markets.find((market) => market.name === name);

  it('returns every market in the group that can actually be bet', () => {
    expect(markets.map((market) => market.name)).toEqual([
      '1X2',
      'Double Chance',
      'Draw No Bet',
      'Total (6.5)',
      'Handicap (0 : 1.5)',
    ]);
  });

  it('never emits a market with no outcomes', () => {
    // Joining on `outcome.marketId` — the rule docs/betway-api.md §4.3 gives — leaves the two
    // squashed markets empty, because their outcomes are filed under the parent.
    for (const market of markets) expect(market.outcomes.length).toBeGreaterThan(0);
  });

  it('drops the squashed parent and keeps the child that carries the line', () => {
    expect(byName('Total Goals')).toBeUndefined();
    expect(byName('Handicap 2-Way')).toBeUndefined();
    expect(byName('Total (6.5)')).toBeDefined();
  });

  it('files the outcomes on the child market, not the parent they arrive under', () => {
    const total = byName('Total (6.5)')!;

    expect(total.marketId).toBe('7426320018total=6.5~');
    // Upstream files both of these under marketId "7426320018" — the parent named "Total Goals".
    expect(total.outcomes.map((outcome) => outcome.outcomeId)).toEqual([
      '7426320018total=6.5~12',
      '7426320018total=6.5~13',
    ]);
  });

  it('survives an outcomeId that is also a marketId for the same event', () => {
    // Betway's ids share one namespace and genuinely collide (docs/betway-api.md §6): on this
    // event "7426320011" is both the Draw No Bet market and the 1X2 home outcome. Anything
    // that joins by string prefix, or keys one map by both kinds of id, gets this wrong.
    const collision = '7426320011';

    expect(byName('Draw No Bet')!.marketId).toBe(collision);
    expect(byName('1X2')!.outcomes.map((outcome) => outcome.outcomeId)).toContain(collision);

    // Each still holds its own outcomes rather than one having swallowed the other's.
    expect(byName('1X2')!.outcomes).toHaveLength(3);
    expect(byName('Draw No Bet')!.outcomes.map((outcome) => outcome.outcomeId)).toEqual([
      '74263200114',
      '74263200115',
    ]);
  });

  it('trims the trailing space off "Over "', () => {
    expect(byName('Total (6.5)')!.outcomes.map((outcome) => outcome.label)).toEqual([
      'Over',
      'Under',
    ]);
  });

  it('does not treat market type as a unique key — which is why markets is a list', () => {
    // Upstream repeats `marketTypeCName` within one event: the Total parent and its 6.5 child
    // are both `handicap-goals-over`, and a Totals group carries one market per line. Our
    // output happens to be duplicate-free only because the parents are filtered out.
    const upstreamTypes = parseMarketGroup(load('market-group-main')).marketsInGroup.map(
      (market) => market.marketTypeCName,
    );

    expect(new Set(upstreamTypes).size).toBeLessThan(upstreamTypes.length);
    expect(byName('Total (6.5)')!.type).toBe('handicap-goals-over');
  });
});

describe('upstream shape changes', () => {
  it.each([
    ['sports', () => parseConfigSports({ nope: true })],
    ['events', () => parseBetBookUpcoming({ nope: true })],
    ['markets', () => parseMarketGroup({ nope: true })],
  ])('turns an unreadable %s response into upstream_error, not a half-built DTO', (_name, fn) => {
    const error = captureError(fn);
    expect(error.code).toBe('upstream_error');
    expect(error.status).toBe(502);
  });
});

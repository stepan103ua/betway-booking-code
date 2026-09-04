import type { Selection } from '@booking-code/contracts';

/**
 * Accumulator odds for a set of legs.
 *
 * Lives here rather than in a provider because it is arithmetic over *our* DTO, not a mapping
 * of anyone's payload: the decode mapper uses it to total a slip, and Convert uses it to total
 * the legs it kept. Two copies would drift on the rounding, and the rounding is the part that
 * matters.
 *
 * Each leg is rounded to 2dp *before* multiplying, then the product is rounded again. Betway
 * quotes and every client shows leg odds at 2dp, so totalling the raw `priceDecimal` produced a
 * badge that did not equal the product of the numbers on the card — off by a cent on some
 * slips. Multiplying what the user sees keeps the total hand-verifiable; the lost precision was
 * never displayed anyway. Betway's own betslip total can still differ by ~0.01 — it totals a
 * live price snapshot taken at a different instant (docs/betway-api.md §3), which no rounding
 * rule on our side can track.
 *
 * The final round also mops up float noise, which accumulates fast — seven legs is enough to
 * turn 2.76 into 2.7600000000000007.
 *
 * Unpriced legs are skipped rather than multiplied in, since a 0 would collapse the whole
 * accumulator and report a total nobody's slip has.
 */
export function totalOdds(selections: Selection[]): number {
  const round2 = (n: number) => Math.round(n * 100) / 100;

  const product = selections
    .filter((selection) => selection.odds > 0)
    .reduce((total, selection) => total * round2(selection.odds), 1);

  return round2(product);
}

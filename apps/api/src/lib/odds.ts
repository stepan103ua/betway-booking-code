import type { Selection } from '@booking-code/contracts';

/**
 * Accumulator odds for a set of legs.
 *
 * Lives here rather than in a provider because it is arithmetic over *our* DTO, not a mapping
 * of anyone's payload: the decode mapper uses it to total a slip, and Convert uses it to total
 * the legs it kept. Two copies would drift on the rounding, and the rounding is the part that
 * matters.
 *
 * Rounded to 2dp because a product of decimals accumulates float noise fast — seven legs is
 * enough to turn 2.76 into 2.7600000000000007.
 *
 * Unpriced legs are skipped rather than multiplied in, since a 0 would collapse the whole
 * accumulator and report a total nobody's slip has.
 */
export function totalOdds(selections: Selection[]): number {
  const product = selections
    .filter((selection) => selection.odds > 0)
    .reduce((total, selection) => total * selection.odds, 1);

  return Math.round(product * 100) / 100;
}

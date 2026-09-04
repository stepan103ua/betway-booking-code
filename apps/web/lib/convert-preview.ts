import type { Selection } from '@booking-code/contracts';

/**
 * What a Convert would produce, given the loaded slip and the set of **live** legs the user
 * chose to drop. Dead legs (`isActive: false`) are always dropped by the server, so they are
 * counted here but never in the user's drop set.
 *
 * `previewOdds` is the product of the kept legs' *current* odds — a preview only. The real
 * total is set when `/convert` re-encodes, and prices drift in between (docs/betway-api.md
 * §3). `canConvert` is false when nothing would survive: the server answers `empty_slip` and
 * there is no honest code for "nothing left".
 */
export function convertPreview(selections: Selection[], drops: Set<string>) {
  const kept = selections.filter((s) => s.isActive && !drops.has(s.outcomeId));
  const deadCount = selections.reduce((n, s) => n + (s.isActive ? 0 : 1), 0);

  return {
    kept,
    droppedCount: selections.length - kept.length,
    deadCount,
    previewOdds: kept.reduce((running, s) => running * s.odds, 1),
    canConvert: kept.length > 0,
    allDead: deadCount > 0 && deadCount === selections.length,
  };
}

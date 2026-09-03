/**
 * Display formatting — pure functions, mirrors design-system.md §6 exactly (the same rules
 * apps/mobile applies in its widgets). No model carries these; the view does.
 */

/** Odds always show two decimals: `2.30`, never `2.3`. */
export const formatOdds = (odds: number): string => odds.toFixed(2);

/** `EEE HH:mm` in the viewer's local time. `kickoffAt` is UTC — a Lagos user must see WAT. */
export const formatKickoff = (kickoffAt: string): string =>
  new Date(kickoffAt).toLocaleString(undefined, {
    weekday: 'short',
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
  });

/** `en-NG` thousands grouping: `9,227 loaded`. */
export const formatUsage = (usageCount: number): string =>
  `${usageCount.toLocaleString('en-NG')} loaded`;

/**
 * The API collapses Betway's three staleness flags into one `isActive` and reports no reason
 * (docs/backend-api.md §0). Inventing "Market closed" would be fiction — this is the constant.
 */
export const DEAD_LEG_REASON = 'No longer available';

/**
 * A slip is `partial` when any leg has gone inactive, `live` otherwise. There is deliberately
 * no `expired` state — `/resolve` always returns `expiresAt: null`, so the app cannot know
 * (design-system.md §5).
 */
export const slipStatus = (selections: { isActive: boolean }[]): 'live' | 'partial' =>
  selections.every((s) => s.isActive) ? 'live' : 'partial';

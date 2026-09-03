/**
 * Display formatting — pure functions, mirrors design-system.md §6 and apps/mobile's
 * `widgets/slip/slip_format.dart` exactly. No model carries these; the view does.
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

/**
 * `expiresAt` relative to *now* — "Expires in 2h 15m" / "Expired 5m ago". Non-null only from
 * `GET /api/booking-codes/popular` (docs/backend-api.md §1); `/resolve` never populates it,
 * so this never runs on a decoded slip. Drifts by however long the response sat in Redis —
 * the same up-to-a-minute staleness the odds beside it already carry.
 */
export const formatExpiry = (expiresAt: string): string => {
  const deltaMs = new Date(expiresAt).getTime() - Date.now();
  const abs = humanizeDuration(Math.abs(deltaMs));
  return deltaMs < 0 ? `Expired ${abs} ago` : `Expires in ${abs}`;
};

const humanizeDuration = (ms: number): string => {
  const totalMinutes = Math.floor(ms / 60_000);
  const hours = Math.floor(totalMinutes / 60);
  const minutes = totalMinutes % 60;
  if (hours > 0) return minutes > 0 ? `${hours}h ${minutes}m` : `${hours}h`;
  return `${totalMinutes}m`;
};

/** `en-NG` thousands grouping: `9,227 loaded`. */
export const formatUsage = (usageCount: number): string =>
  `${usageCount.toLocaleString('en-NG')} loaded`;

/** `1 selection` / `4 selections`. */
export const pluralize = (count: number, noun: string): string =>
  `${count} ${count === 1 ? noun : `${noun}s`}`;

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

/** The API's `CodeInput` gate (design-system.md §4) — `BW` + 8 hex, case-insensitive. */
export const CODE_PATTERN = /^BW[0-9A-F]{8}$/;

export const isValidCode = (raw: string): boolean => CODE_PATTERN.test(raw.trim().toUpperCase());

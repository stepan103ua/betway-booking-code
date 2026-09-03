/**
 * Betway's own site — the pinned host from docs/betway-api.md §1. Every "Open / Load in
 * Betway" and every share target points here: no deep-link format for a specific code was
 * ever supplied or verified (design-system.md §8), so this takes the user to the site rather
 * than guessing a URL scheme.
 */
export const BETWAY_URL = 'https://www.betway.com.ng';

/** One string for all three share routes (WhatsApp, Telegram, copy), so they carry the same thing. */
export const shareText = (code: string, totalOdds: number): string =>
  `Betway booking code ${code} — total odds ${totalOdds.toFixed(2)}. ` +
  `Decode it before you stake: ${BETWAY_URL}`;

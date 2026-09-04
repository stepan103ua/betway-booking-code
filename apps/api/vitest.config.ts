import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    environment: 'node',
    include: ['tests/**/*.test.ts', 'src/**/*.test.ts'],
    // Tests drive the Express app object directly (see tests/health.test.ts) — no port, no
    // network, no live Betway. `providers/fixtures.provider.ts` backs anything that needs
    // upstream data. See docs/backend.md §7.
    restoreMocks: true,
  },
});

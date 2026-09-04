import { fileURLToPath } from 'node:url';
import { defineConfig } from 'vitest/config';

// Vitest transforms .ts/.tsx through esbuild — no plugin needed for the logic tests here.
// React Testing Library component tests (docs/frontend.md §8) will want @vitejs/plugin-react;
// add it alongside the first one.
export default defineConfig({
  esbuild: { jsx: 'automatic' },
  resolve: {
    alias: { '@': fileURLToPath(new URL('.', import.meta.url)) },
  },
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./vitest.setup.ts'],
    include: ['**/*.test.{ts,tsx}'],
  },
});

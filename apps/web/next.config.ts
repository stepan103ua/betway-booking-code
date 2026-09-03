import { fileURLToPath } from 'node:url';
import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  // @booking-code/contracts ships as TypeScript source (it is type-only, so nothing of it
  // reaches the bundle — but Next still has to resolve the workspace path).
  transpilePackages: ['@booking-code/contracts'],

  // Next 16 otherwise writes its own AGENTS.md / CLAUDE.md into apps/web on every run. The
  // repo already has one CLAUDE.md at the root; a second, auto-generated one is just noise.
  agentRules: false,

  // Traced, self-contained server bundle for the Docker image (apps/web/Dockerfile). Vercel
  // ignores this — it does its own thing (docs/frontend.md §9). `outputFileTracingRoot` pins
  // the monorepo root so tracing pulls the hoisted node_modules, not just apps/web's.
  output: 'standalone',
  outputFileTracingRoot: fileURLToPath(new URL('../../', import.meta.url)),
};

export default nextConfig;

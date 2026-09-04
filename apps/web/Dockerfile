# syntax=docker/dockerfile:1

# Build context is the **repo root**, not apps/web — this is an npm workspace, so the install
# needs the root package-lock.json and every workspace's package.json to resolve. Build as:
#
#   docker build -f apps/web/Dockerfile .
#
# or let docker-compose.yml do it, which sets the context.
#
# The web app's real deployment target is Vercel (docs/frontend.md §9). This image exists so
# `npm run docker:up` can bring web + api + redis up together for a local end-to-end demo,
# and to prove the production build works — it is not the deploy path.

ARG NODE_VERSION=24-alpine


# ---- deps -----------------------------------------------------------------------------------
# Manifests only, so this layer stays cached until a dependency actually changes.
FROM node:${NODE_VERSION} AS deps
WORKDIR /app

COPY package.json package-lock.json ./
COPY apps/web/package.json apps/web/
COPY packages/contracts/package.json packages/contracts/

# --workspace scopes the install to web + contracts — without it npm ci resolves every
# workspace's tree (api's express/ioredis/vitest too). This layer is cached until a manifest
# above changes, so source-only edits don't re-run it.
RUN npm ci --workspace @booking-code/web --no-audit --fund=false --prefer-offline


# ---- build ----------------------------------------------------------------------------------
FROM deps AS build
WORKDIR /app

ENV NEXT_TELEMETRY_DISABLED=1

COPY packages/contracts ./packages/contracts
COPY apps/web ./apps/web

# `output: 'standalone'` (next.config.ts) traces the minimal server + node_modules into
# .next/standalone. The Server Component read in app/page.tsx tolerates an unreachable API at
# build time (it falls back to null), so no API is needed here.
RUN npm run build --workspace @booking-code/web


# ---- runtime --------------------------------------------------------------------------------
FROM node:${NODE_VERSION} AS runtime
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000
# Docker sets HOSTNAME to the container id; without this the standalone server tries to bind
# to that name and nothing outside the container can reach it.
ENV HOSTNAME=0.0.0.0

# The standalone bundle is already just what's needed to run — no `npm ci` in this stage, no
# typescript / eslint / tailwind in the image. Static assets are traced separately by design.
COPY --from=build /app/apps/web/.next/standalone ./
COPY --from=build /app/apps/web/.next/static ./apps/web/.next/static

# The base image ships an unprivileged `node` user; nothing here writes to disk.
USER node

EXPOSE 3000

# Node's built-in fetch — the alpine image has no curl. Hits the app's own root route.
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:'+(process.env.PORT||3000)+'/').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"

# Exec form → the server is PID 1 and gets SIGTERM directly on `docker stop` / redeploy.
CMD ["node", "apps/web/server.js"]

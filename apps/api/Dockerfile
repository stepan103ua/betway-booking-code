# syntax=docker/dockerfile:1

# Build context is the **repo root**, not apps/api — this is an npm workspace, so the install
# needs the root package-lock.json and every workspace's package.json to resolve. Build it as:
#
#   docker build -f apps/api/Dockerfile .
#
# or let docker-compose.yml do it, which sets the context correctly.

# Node 24: current active LTS, and what local development runs. Note this is ahead of the
# "Node.js 20" in docs/backend.md §1 — Node 20 reached end of life in April 2026 and no longer
# gets security patches, so pinning an image to it would ship a runtime nobody is fixing.
ARG NODE_VERSION=24-alpine


# ---- deps -------------------------------------------------------------------------------
# Separated so a source-only change does not re-run npm ci. Only manifests land here, so this
# layer is cached until a dependency actually changes.
FROM node:${NODE_VERSION} AS deps
WORKDIR /app

COPY package.json package-lock.json ./
COPY apps/api/package.json apps/api/
COPY packages/contracts/package.json packages/contracts/

RUN npm ci


# ---- build ------------------------------------------------------------------------------
FROM deps AS build
WORKDIR /app

COPY tsconfig.base.json ./
COPY packages/contracts ./packages/contracts
COPY apps/api ./apps/api

RUN npm run build --workspace @booking-code/api


# ---- runtime ----------------------------------------------------------------------------
FROM node:${NODE_VERSION} AS runtime
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

# Production dependencies only — no typescript, tsx, vitest or eslint in the shipped image.
COPY package.json package-lock.json ./
COPY apps/api/package.json apps/api/
COPY packages/contracts/package.json packages/contracts/

RUN npm ci --omit=dev && npm cache clean --force

COPY --from=build /app/apps/api/dist ./apps/api/dist

# Required, not optional. `FixturesProvider` resolves fixtures relative to its own compiled
# location — from dist/providers/ that is /app/apps/api/fixtures — and it is the fallback the
# service switches to when Betway is unreachable. Omitting these would break exactly the
# provider that exists for the outage case.
COPY apps/api/fixtures ./apps/api/fixtures

# packages/contracts ships no runtime code: every import of it is `import type`, which
# TypeScript erases, so no .js in dist references it. Its package.json is present above only
# so npm can resolve the workspace link.

# The base image provides an unprivileged `node` user. Nothing here needs to write to disk.
USER node

EXPOSE 3000

# Uses the service's own health endpoint, via Node's built-in fetch — the alpine image has no
# curl, and adding one just for a health check is a package to patch forever.
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:'+(process.env.PORT||3000)+'/api/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"

# Exec form, so the process is PID 1 and receives SIGTERM directly — src/index.ts registers a
# handler that drains in-flight requests before exiting. The shell form would swallow it and
# every deploy would drop live connections.
CMD ["node", "apps/api/dist/index.js"]

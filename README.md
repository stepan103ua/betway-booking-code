# Betway Nigeria — booking code product

Decode a Betway booking code into a readable slip, create a new code from a set of
selections, and convert an existing code into a fresh one with the dead legs dropped.

A booking code is how bettors share a slip: `BW6E19810C` stands for a set of selections and
their odds. Betway's own site can redeem one but gives you little insight into what is inside
it — this product decodes it, shows what has gone stale, and reissues it.

## Live

| | URL |
|---|---|
| Web | <https://wonderful-eagerness-production.up.railway.app> |
| API | <https://betway-booking-code-production.up.railway.app/api/health> |
| Android APK | Firebase App Distribution — <https://appdistribution.firebase.dev/i/e316379ad4fbf958> |

The APK link is a self-serve invite: open it, accept, sign in with a Google account, install
the "App Tester" app, and the build appears there. It is built against the API above. See
[`apps/mobile/README.md`](apps/mobile/README.md) for the iOS path and how the build is made.

## Status

All three core operations — decode, encode, convert — are implemented and run against live
Betway, along with the catalogue endpoints (`/api/sports`, `/api/events`,
`/api/events/:id/markets`) that back the Create picker. Both clients are built: `apps/web`
(Next.js) and `apps/mobile` (Flutter), each a plain HTTP consumer of `apps/api`.

`npm run typecheck && npm run lint && npm test` is green across every workspace (158 API + 18
web tests); `apps/mobile` adds `flutter analyze` and 72 tests.

## Layout

```
apps/api/            Express service — the only thing that talks to Betway
apps/web/            Next.js client
apps/mobile/         Flutter client
packages/contracts/  shared DTOs, imported by every client
docs/                design documents (see below)
```

Both clients are plain HTTP consumers of `apps/api`. Nothing calls Betway directly — it
publishes no CORS headers for third-party origins, so every request has to originate
server-side, and making that a standalone service rather than Next.js route handlers means
Flutter and the web app are equal clients of one API.

## Running it

```bash
npm install
npm run dev
```

`http://localhost:3000/api/health`. Redis is optional in development — with `REDIS_URL` unset
the cache degrades to a pass-through and the service runs anyway. For the real thing:

```bash
npm run redis:up
```

Copy `apps/api/.env.example` to `apps/api/.env` and fill it in. Real values live in the deploy
platform's environment settings, never in the repo.

```bash
npm test          # vitest, offline — no live Betway dependency
npm run typecheck
npm run lint
```

### In Docker

To run it the way it deploys — API and Redis together, production dependencies only:

```bash
npm run docker:up
```

`http://localhost:3000/api/health`. `npm run docker:logs` to follow the API, `npm run
docker:down` to stop. The image is multi-stage and runs as a non-root user; `apps/api/Dockerfile`
builds from the repo root because this is an npm workspace.

## API

| Method & path | Purpose |
|---|---|
| `POST /api/booking-codes/resolve` | Decode a code |
| `POST /api/booking-codes` | Encode a new code |
| `POST /api/booking-codes/convert` | Reissue a code, dropping dead legs |
| `GET /api/booking-codes/popular` | Live codes for the Decode empty state, as full slips |
| `GET /api/sports` | Sport list |
| `GET /api/events?sport=` | Upcoming fixtures with 1X2 inline |
| `GET /api/events/:eventId/markets` | Every market for one event |
| `GET /api/health` | Redis and upstream status |

Full request/response contract in [`docs/backend-api.md`](docs/backend-api.md).

## Docs

The design work is done and lives in `docs/`. It is the source of truth for this repository.

- [`architecture.md`](docs/architecture.md) — how the pieces fit; Decode, Convert and the
  deployment topology as diagrams
- [`backend.md`](docs/backend.md) — stack, structure, caching, and the reasoning
- [`backend-api.md`](docs/backend-api.md) — the request/response contract
- [`betway-api.md`](docs/betway-api.md) — reverse-engineered upstream API, verified live
- [`frontend.md`](docs/frontend.md), [`mobile.md`](docs/mobile.md) — the two clients
- [`deployment.md`](docs/deployment.md) — where this actually runs, env vars, and every
  platform gotcha hit getting there
- [`verification.md`](docs/verification.md) — generated and converted codes, loaded on
  Betway's own site, against the live deployment

Two things worth knowing before reading the code:

**There is no database.** The three core operations are stateless pass-throughs to Betway, so
nothing needs to survive a restart. Redis is the only store and it is used as what it is — an
ephemeral cache, primarily as a rate-limit buffer in front of an API that publishes no limit.
The reasoning is in `docs/backend.md` §1.

**Convert is not an upstream endpoint.** It is resolve → filter → encode, composed on our side.
Against a single bookmaker that is close to a formality; the complexity it is built to carry
later is cross-bookmaker market mapping, and `BookingCodeProvider` is the seam for it.

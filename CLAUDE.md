# Betway Nigeria — booking code product

Decode a Betway booking code into a readable slip, create a new code from a set of
selections, and convert an existing code into a fresh one with dead legs dropped.

`apps/api` is the only thing that talks to Betway. The web and mobile clients are equal HTTP
consumers of it and never call upstream directly.

---

## Read the docs first

`docs/` is the source of truth and it is unusually complete — the contract, the stack and the
verified upstream behaviour are all already decided there. **Read the relevant doc before
writing code, and do not restate its content in this file or in comments.** Two copies of the
same fact drift; the docs say so themselves (`backend.md` §4).

| Doc | What it settles |
|---|---|
| `docs/backend-api.md` | The request/response contract, endpoint by endpoint. Shared DTOs in §0 |
| `docs/backend.md` | Stack, folder structure, caching policy, cross-cutting concerns, deploy |
| `docs/betway-api.md` | Verified upstream endpoints, payloads, ID scheme, and the traps |
| `docs/architecture.md` | How the pieces fit; the Decode and Convert flows as diagrams |
| `docs/frontend.md`, `docs/mobile.md` | The two clients — both `apps/web` and `apps/mobile` are built |
| `docs/design-system.md` | Tokens, components and visual rules shared by both clients — `apps/mobile/lib/design/` is the reference implementation |

If code and a doc disagree, that is a bug in one of them — say so rather than silently
picking a side.

---

## Layout

```
apps/api/              Express service (the only backend)
  src/routes/            HTTP concerns only: path, method, validation, status
  src/controllers/       request → service call → response shape. No logic
  src/services/          business logic, cache policy, Convert composition
  src/providers/         BookingCodeProvider interface + betway / fixtures implementations
  src/lib/               redis, errors, rate-limit, logger
  src/middleware/        error-handler, validate
  src/schemas/           Zod request schemas
  fixtures/              committed upstream JSON, for offline tests and demos
  tests/                 Vitest + Supertest against the app object
apps/web/              Next.js client — plain HTTP consumer of apps/api
apps/mobile/           Flutter client — plain HTTP consumer of apps/api
packages/contracts/    shared DTOs, type-only. Imported by every client
docs/                  design documents — source of truth
```

`apps/web` (Next.js) and `apps/mobile` (Flutter) are both built; each is an equal HTTP
consumer of `apps/api` and never calls Betway directly.

## Commands

```bash
npm install            # once, from the repo root
npm run dev            # tsx watch, http://localhost:3000
npm test               # vitest, offline
npm run typecheck      # tsc --noEmit across workspaces
npm run lint           # eslint, run before calling anything done
npm run redis:up       # local Redis in Docker (optional — see below)
npm run build          # tsc → apps/api/dist
npm run docker:up      # whole stack in containers, close to what deploys
npm run docker:down    # stop it
```

Two ways to run it. `npm run dev` (plus `redis:up`) is the everyday loop — hot reload, no image
rebuild. `npm run docker:up` builds the image and runs API and Redis together; use it to check
the image works before pushing, not to develop against.

Redis is optional in development: with `REDIS_URL` unset the cache degrades to a pass-through
and the service runs anyway. `GET /api/health` reports which mode it is in.

---

## Invariants

These are the rules the design turns on. Breaking one is a bug even when the tests pass.

- **Betway's shape never reaches a client.** `priceDecimal` → `odds`, `eventEpoch` → ISO
  `kickoffAt`, the three staleness flags → one `isActive`. Normalisation happens inside a
  provider, so nothing above it knows which bookmaker answered.
- **Every non-2xx response is `ApiError`** — `{ error, message }`, from every endpoint,
  validation failures and upstream errors alike. Only `middleware/error-handler.ts` writes an
  error body. Handlers throw `AppError`; they never build a response themselves.
- **Services depend on `BookingCodeProvider`, never on `betway.provider.ts`.** The concrete
  provider is chosen once, in `src/index.ts`. That is the seam a second bookmaker plugs into.
- **Redis is a cache, never a source of truth.** Namespace keys by endpoint and input
  (`resolve:{code}`), match the TTL to how fast the data moves, and never cache a write
  (`POST /api/booking-codes`, `/convert`).
- **No database.** The core operations are stateless pass-throughs; `docs/backend.md` §1
  explains why one was considered and deliberately left out. Do not add one.
- **No `/api/v1` prefix.** Deliberate, not an oversight — `docs/backend-api.md`, preamble.
- **Validate at the route edge.** A Zod schema runs before anything reaches a service, so the
  service layer can trust its inputs and never re-checks them.
- **`apps/api/fixtures/` ships with the image.** `FixturesProvider` resolves it relative to its
  own compiled location, so a Docker build that copies only `dist/` breaks the very provider
  the service falls back to when Betway is down. `apps/api/Dockerfile` copies it explicitly.

## Conventions

- **ESM with `nodenext`: relative imports need an explicit `.js` extension**, even from a
  `.ts` file — `import { logger } from './logger.js'`. This is the single most common thing
  to get wrong here; the build fails loudly if you do.
- **`verbatimModuleSyntax` is on**: type-only imports must say `import type`. ESLint autofixes
  this — `npm run lint:fix`.
- **DTOs come from `@booking-code/contracts`.** Never redeclare a response shape locally. The
  package is type-only, so importing it costs nothing at runtime.
- Errors carry a stable machine code from `ERROR_CODES` in `src/lib/errors.ts`. Clients branch
  on `error`, so treat those strings as part of the contract.
- Never log a request body or a connection string. Booking codes are public and fine to log.

## Upstream traps

All verified and recorded in `docs/betway-api.md` — these are the ones that cost time when
forgotten:

- **Pin the hosts.** `www.betway.com.ng`, `feeds-roa2.betwayafrica.com`,
  `config.betwayafrica.com`, `apic.betwayafrica.com`. **Never `betway.com`** — geo-restricted,
  and it redirects.
- **`FindBookABet` is v2, `BookABet` is v1.** Not a typo.
- **Retry once before declaring a code invalid.** A valid code returned 400 once, then 200
  seconds later.
- **Odds drift between encode and decode.** Prices are live; a code created at 2.27 may decode
  at 2.17. Expected — surface it in the UI, do not "fix" it.
- **Do not parse the numeric market suffix.** IDs are composite and non-soccer sports use a
  different index space. Read `marketTypeCName`.
- No auth, no captcha, no cookies needed. Cloudflare guards Betway's HTML, not its API.

## Anti-goals

Reach for none of these without saying why first:

- a database, or a second cache layer on top of Redis
- SignalR / live odds streaming — snapshot plus a short TTL is the deliberate choice
- an `/api/v1` prefix, or DTO fields that are not in `docs/backend-api.md` §0
- CQRS, hexagonal layering, event sourcing, or a microservice split. This is one small
  service; indirection it does not need makes it worse, not more professional.

## Done means

`npm run typecheck && npm run lint && npm test` all pass, the endpoint matches
`docs/backend-api.md`, no secret is committed, and any new upstream behaviour discovered along
the way is written back into `docs/betway-api.md`.

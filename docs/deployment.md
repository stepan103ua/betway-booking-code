# Deployment — Betway Nigeria Booking Code Product

What's actually live, where, and why it ended up there — as opposed to `docs/backend.md` §8
and `docs/frontend.md` §9, which record the platform each app was *designed* for. Where this
disagrees with those, this file is the one to trust; they're left as-is because the reasoning
in them (persistent process over serverless, Render's cold-start trap) is still correct, it
just didn't end up being the deployment picture. Diagram: `docs/architecture.md` §4.

---

## 1. Topology

One Railway project, three services:

| Service | Source | URL |
|---|---|---|
| `api` | `apps/api/Dockerfile` | <https://betway-booking-code-production.up.railway.app> |
| `web` | `apps/web/Dockerfile` | <https://wonderful-eagerness-production.up.railway.app> |
| `Redis` | Railway-managed | internal only |

Both app services build from the repo's own Dockerfiles rather than Railway's Nixpacks
auto-detection — this is an npm workspace, so the build needs the root `package-lock.json`
plus every workspace's manifest, which only works if the **build context is the repo root**,
not the app directory. In Railway that means the service's `Root Directory` setting stays `/`
and only `Dockerfile Path` points into `apps/api` or `apps/web`; setting `Root Directory` to
the app folder breaks the `npm ci` step, because it can no longer see the root lockfile.

## 2. Why both apps on Railway, not Vercel + Railway/Fly

`docs/frontend.md` §9 designed `apps/web` for Vercel — still a fine choice, and the app needs
no code change to move there (`API_URL` is the only thing that'd point somewhere else). It's
on Railway instead because `apps/web/Dockerfile` already existed (for `docker-compose.yml`'s
local parity story) and one platform for both services means one dashboard, one place to read
logs, and no second account to wire up mid-assessment. If this were going into real use rather
than being handed to a reviewer, Vercel for `web` is the better default — CDN-fronted static
assets and no idle cost for a UI that isn't the bottleneck. Noting the trade, not reversing the
original argument.

## 3. Environment variables

What each service actually has set, beyond the defaults already documented in
`apps/api/.env.example`:

| Service | Variable | Value | Why |
|---|---|---|---|
| `api` | `REDIS_URL` | `${{Redis.REDIS_URL}}` | Railway reference variable — resolves to the managed Redis's internal URL |
| `api` | `ALLOWED_ORIGIN` | `https://wonderful-eagerness-production.up.railway.app` | CORS allow-list for the web origin. Low-stakes here: `web` calls `api` server-side (Server Components / Server Actions), so no browser request ever carries this Origin — it matters only if a Client Component ever fetches `api` directly |
| `api` | `PORT` | injected by Railway | `config.ts` reads whatever Railway sets; the Dockerfile's `ENV PORT=3000` is only the container default |
| `web` | `API_URL` | `https://betway-booking-code-production.up.railway.app` | server-side only (`apps/web/lib/api.ts`) — public URL works, so private networking was left as a later optimization, not a day-one need |
| `apps/mobile` | `API_BASE_URL` | baked into the APK from `dart_defines.json` at build time | not a runtime environment variable — Dart's `String.fromEnvironment` resolves at compile time, so this has to be right before `flutter build apk`, not settable after |

Betway's four hosts (`BETWAY_BASE_URL` etc.) and `REDIS_URL`'s absence-is-fine default are
unchanged from `apps/api/.env.example` — nothing platform-specific about them.

## 4. Build gotchas hit getting here

- **Railway's builder rejects BuildKit cache mounts without an explicit `id`.** Both
  Dockerfiles originally had `RUN --mount=type=cache,target=/root/.npm \ npm ci …` — a
  local-build speed-up. Railway's build backend parses that as invalid
  (`flag '--mount=type=cache,…' is missing an id argument`) and refuses the build. Fixed by
  dropping the mounts rather than chasing an `id=` that may or may not satisfy whatever
  frontend Railway runs — Railway's own layer cache already keeps the `npm ci` layer cached
  across builds where only source (not a manifest) changed, so nothing was actually lost.
- **`Root Directory` must stay the repo root** — see §1. The failure mode if it doesn't
  (`apps` directory not found, or `npm ci` unable to resolve workspace packages) looks like a
  monorepo misconfiguration, because it is one.
- **Betway is reachable from Railway's build/runtime region.** Worth checking explicitly
  before assuming it — `docs/betway-api.md` §7 only confirms the global `betway.com` domain is
  geo-blocked, not that every Betway Africa host answers from every datacenter region. It does
  from Railway's; `GET /api/health` returning `"betwayLastSuccessAt"` with a recent timestamp
  is the fastest way to re-check this after a redeploy or a region change.

## 5. Mobile: config file, not environment variables

The APK has no server to hold environment variables at runtime, so `apps/mobile`'s config is a
build-time JSON file instead: `dart_defines.json` (gitignored — holds real URLs) alongside a
committed `dart_defines.example.json` template. `flutter build apk --release
--dart-define-from-file=dart_defines.json` bakes `API_BASE_URL` into the binary; a build
without it falls back to `http://localhost:3000` and reaches nothing on a real device. Full
build → Firebase App Distribution steps: `apps/mobile/README.md` § Distribution.

## 6. Firebase App Distribution

Project `booking-code-2b4f7`, Android app `com.stepandobrianskyi.booking_code`. Distribution
needs no `google-services.json` and no Firebase SDK in the app — it's a pure upload/install
channel, not a runtime dependency (see `apps/mobile/CLAUDE.md`'s anti-goals: no dependency
gets added without a reason, and App Distribution gives none for `firebase_core`).

Testers join through a group invite link (`Testers & Groups` → a group → `Invite links`,
"restrict to the account it was sent to" left off) rather than being added one email at a
time — that link is what's in the root README, and it stays valid until revoked, unlike the
CLI's own "download the binary" link, which expires in an hour.

The APK ships **debug-signed** — `android/app/build.gradle.kts` falls back to the debug
keystore when `android/key.properties` is absent, and App Distribution accepts that; testers
install it the same way. The trade-off, and why a release keystore wasn't generated for this
submission, is in `apps/mobile/README.md` § Distribution.

## 7. What isn't here

- **No CI/CD.** Every deploy so far is a manual `git push` (Railway redeploys on push to the
  watched branch) or a manual `firebase appdistribution:distribute`. A GitHub Actions workflow
  running `typecheck && lint && test` on every push would be the natural next thing, not added
  here to stay inside the brief's two-day scope.
- **No custom domain.** Railway's own `*.up.railway.app` subdomains are the public URLs.
- **iOS distribution.** Out of scope entirely — `apps/mobile/README.md` § Distribution covers
  what the IPA path would need.

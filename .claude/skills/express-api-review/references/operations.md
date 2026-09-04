# Operations — running this thing in front of people

`docs/backend.md` §6 and §8. The service is an anonymous public proxy in front of a third
party's API, which shapes most of what follows.

## Rate limiting

`express-rate-limit` across the whole API. The point is protecting **Betway** from being
hammered through us, not protecting ourselves — Betway publishes no limit, and we are an
unauthenticated door to it.

- Behind Railway or Fly the client IP arrives in `X-Forwarded-For`. Without `trust proxy`, every
  request counts against the proxy's single address and the limiter either blocks everyone or
  nobody. Missing `trust proxy` is a **Should fix**.
- Setting `trust proxy: true` (rather than a hop count) lets a caller spoof `X-Forwarded-For`
  and bypass the limiter entirely.
- A 429 answers in the standard `ApiError` shape like everything else.
- The in-memory store counts per process, so a multi-instance deploy multiplies the effective
  limit. Fine at one instance; worth a **Consider** with the Redis store as the fix.

## CORS

An explicit origin allowlist, never `*`. The Flutter client sends no `Origin` header from a
native HTTP client, so it is unaffected either way — a change to CORS is only ever about the
web app. `origin: '*'` alongside any future credentialed request is a **Blocker**; today it is a
**Should fix** and a bad habit to leave in a repo someone reads.

## Health

`GET /api/health` pings Redis and reports the last successful upstream call. It should stay
cheap and never call Betway itself — a health check that hits upstream turns an uptime monitor
into a load generator.

200 with `redis: "down"` is more useful than a bare 503: it says *which* dependency is unhappy.
`degraded` means configured-but-unreachable, not deliberately disabled — collapsing those two
makes local development look broken.

## Logging

Structured JSON to stdout, which is what the platforms ingest.

- **Never log a request body, a connection string, or an env dump.** Booking codes are public
  and anonymous, so they are fine — the habit of logging whole payloads is what puts secrets in
  a log aggregator. Any of the former is a **Blocker**.
- Log 5xx with the cause. Do not log expected outcomes (`invalid_code`, `not_implemented`) at
  error level: a log full of routine events trains you to ignore it, and the real incident
  scrolls past unread.
- `console.log` scattered through a handler is debug residue. **Nit** once, then stop counting.

## Configuration

Parsed and validated once at startup, failing loud on a bad value. `process.env` read anywhere
but `config.ts` is a **Should fix** — it hides a dependency from the composition root and from
every test.

`.env` is gitignored; `.env.example` is committed with empty values. A real secret in a
committed file is a **Blocker** even if it is only a base URL today.

## Shutdown

Railway and Fly send `SIGTERM` and then kill. Close the server, drain in-flight requests, then
close Redis. Without it every deploy drops live connections — invisible in development, visible
as intermittent failures in production. A timeout on the drain prevents a stuck request holding
the process open forever.

## Deployment shape

A persistent Node process — Railway or Fly, not Vercel's serverless model. Avoid Render's free
tier specifically: it spins down after inactivity, and a 30–50s cold start on a reviewer's first
request reads as broken rather than slow.

Code that assumes a serverless runtime (per-request module init, no shared connection pooling)
is worth flagging: the in-memory rate limiter and the persistent Redis connection both assume a
long-lived process.

## Questions worth asking

- What does a reviewer see if Betway is down? If Redis is down? If both are?
- Could anything sensitive reach stdout?
- Does a deploy drop in-flight requests?
- Is the rate limiter counting real client IPs?
- Is any configuration read outside `config.ts`?

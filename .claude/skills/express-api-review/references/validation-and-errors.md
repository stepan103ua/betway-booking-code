# Validation and the error contract

Two rules carry most of the weight here, both from `docs/backend-api.md` §0 and
`docs/backend.md` §6:

1. Nothing reaches a service unvalidated.
2. Every non-2xx response is `{ error, message }` — from every endpoint, for every kind of
   failure.

## Validation at the edge

- A Zod schema runs as route middleware, before the controller. Validation inside a service is
  a **Should fix**: it means the service cannot trust its own inputs, so every caller re-checks
  and the checks drift apart.
- **Enforce bounds Betway does not.** `outcomeIds` is capped at 20 and `take` at 50 —
  deliberately, so our endpoint is not a wider door than theirs. An unbounded array is a
  **Blocker**: it lets anyone build a 500-leg slip and hammer upstream through us.
- Error messages are rendered to users verbatim. "A slip can hold at most 20 selections" is
  right; "Array must contain at most 20 element(s)" is a type assertion that leaked into a UI.
- Validate the *shape*, not the domain. Whether `BW6E19810C` exists is upstream's answer
  (`invalid_code`, 404); whether it looks like a booking code at all is Zod's (`invalid_request`,
  400). Conflating them makes a typo indistinguishable from an expired code.
- Express 5 makes `req.query` a getter — assigning to it throws at runtime, not at compile
  time. Validated query values go through `res.locals`.

## The error contract

- **Only the error middleware writes an error body.** A handler that builds `res.status(404)
  .json({...})` itself is a **Should fix** — that is how a second error shape appears, and a
  client branching on `error` breaks against it.
- Handlers throw `AppError` with a code from `ERROR_CODES`. Express 5 forwards rejected
  promises to the error middleware automatically, so a `try/catch` that only re-throws is noise
  and a `try/catch` that swallows is a **Blocker**.
- **No upstream detail escapes.** `BookABetInvalidCode`, error code `6000331`, an upstream
  response body, or a stack trace reaching a client is a **Blocker**. It becomes `invalid_code`
  with a sentence a user can read; the original goes to the log.
- Codes are part of the contract. Clients branch on `error`, so renaming one is a breaking
  change even though nothing type-checks against it.
- A schema may declare its own code for one specific violation (`too_many_outcomes` rather than
  a generic `invalid_request`) so the client can act on it. Only 4xx codes are valid there — a
  validation failure reporting as `upstream_error` makes a bad request look like an incident.

## Status mapping

| Situation | Status | Code |
|---|---|---|
| malformed body or query | 400 | `invalid_request` |
| more than 20 outcomes | 400 | `too_many_outcomes` |
| a selection is no longer bettable at encode time | 400 | `outcomes_unavailable` |
| Convert has no legs left to encode | 400 | `empty_slip` |
| code well-formed, upstream has no slip | 404 | `invalid_code` |
| unknown path | 404 | `not_found` |
| rate limit tripped | 429 | `rate_limited` |
| route exists in the contract, not built yet | 501 | `not_implemented` |
| Betway unreachable or unusable response | 502 | `upstream_error` |
| Betway timed out | 504 | `upstream_timeout` |
| anything unrecognised | 500 | `internal_error` |

A 500 for an expected outcome is a **Should fix**: it makes real incidents unfindable in the
logs. An invalid booking code is an ordinary result of this product, not an exception.

Inverse check: a 200 carrying `{ error: ... }` in the body is a **Blocker**. Status codes are
the contract; clients check `res.ok`.

## Questions worth asking

- Can any input reach a service without passing a schema?
- Which bound stops a caller from making this endpoint expensive?
- Would this message make sense to a user with no context?
- Is any upstream string reachable from a response body?
- Is a bug and an expected outcome distinguishable in the logs?

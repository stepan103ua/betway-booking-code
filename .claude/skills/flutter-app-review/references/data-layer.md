# Data layer — one `Dio`, real timeouts, and turning transport errors into words

`docs/mobile.md` §5–§6. The data source knows the network; the repository knows what to tell
the user. Everything in this file is about keeping those two jobs apart.

## The `Dio` instance

One instance, built in `core/network/dio_client.dart`, injected everywhere. A second `Dio()`
constructed anywhere else is a **Should fix** — the timeouts and interceptors then apply to
some calls and not others, and the ones that skip them are the ones nobody notices.

**Timeouts are off by default.** `connectTimeout`, `receiveTimeout` and `sendTimeout` are all
`null` on a fresh `BaseOptions`, which means a request to a host that accepts the connection and
then stalls hangs until the OS gives up. On a Nigerian mobile connection that is a spinner with
no end and no way back — the user force-quits. Set all three explicitly; **Should fix** when
any is missing, and the review should say what happens on the device rather than citing a rule.

`validateStatus` defaults to accepting 2xx only, so every 4xx and 5xx from our API arrives as a
`DioException` with `type == badResponse` and a populated `response`. That default is what makes
the repository's mapping below possible — widening it means non-2xx bodies start flowing into
`Slip.fromJson` instead.

## Base URL

Never a hardcoded machine address, and never a committed non-local one. `--dart-define` with
`String.fromEnvironment` and a local default is the shape (see `tooling-and-release.md`).

`localhost` on a device means the phone, not the laptop. The Android emulator reaches the host
at `10.0.2.2`, the iOS simulator shares the host's `localhost`, and a physical device needs the
LAN address. A base URL that only works in one of those three is not a bug in the code so much
as a trap for the next person to run it — worth a **Consider** and a line in the README.

Cleartext HTTP is blocked by default on both platforms (Android since API 28, iOS by App
Transport Security). Whatever exception makes `http://` work in development must not survive
into a release build — **Should fix** if it is unconditional in the manifest or `Info.plist`.

## The data source boundary

The data source is the only file that imports `dio` and the only file that knows a path. An
endpoint string built anywhere else is a **Should fix**: when `docs/backend-api.md` changes, the
grep that should find one file finds three.

It returns a parsed model or throws — it does not translate errors. A data source that catches
`DioException` and returns `null` has destroyed the distinction between "no slip" and "no
network", and the repository above it can no longer tell the user which happened. **Blocker.**

A logging interceptor is worth having and must be off in release. Booking codes are public and
fine to log; a whole request or response body is the habit that eventually logs something that
is not (same rule as the backend's).

## `DioException` → `Failure`

This mapping is the highest-value code in the app: it is the only place transport semantics
become sentences a user reads.

**Map on the API's `error` code, not only on the status.** `docs/backend-api.md` §0 defines
every non-2xx body as `{ error, message }` with a stable machine-readable code, and the status
alone throws information away — `invalid_request`, `too_many_outcomes`, `outcomes_unavailable`
and `empty_slip` are all `400`. A repository switching only on `statusCode` collapses four
distinct outcomes into one message, and the two that Create and Convert actually produce become
indistinguishable from a typo. `docs/mobile.md` §5 sketches the `statusCode` switch — that is a
sketch of the mechanism, not the full table, so a review recommending the code-based mapping
should say plainly that it goes further than the doc, and why.

`message` in that body is written to be shown verbatim (§0). Replacing it with a hardcoded
client string discards the more specific sentence the server already composed. The local
messages in the `Failure` subclasses are for the cases where there is no body at all —
connection failure and timeout.

`e.response == null` collapses timeout and connectivity into one branch. `DioExceptionType`
separates `connectionTimeout`, `receiveTimeout` and `connectionError`, and those are different
sentences: "the server is taking too long" invites a retry, "you appear to be offline" does not.
**Consider**, weighted by whether the UI actually offers a retry.

**Do not add a client-side retry without saying why.** `resolve` is already retried once
server-side against Betway (`CLAUDE.md`, upstream traps), so a client retry on top makes a
single user tap up to four upstream calls. If one is added it belongs in an interceptor with a
bounded count, and the reason belongs in a comment.

Nothing above the repository catches `DioException`, and nothing below it constructs a
`Failure`. Either direction is a layer violation with a concrete cost: the first drags `dio`
into the Cubit's tests, the second puts user-facing copy in a file that only knows about JSON.

## Questions worth asking

- What does the user see if the API takes 90 seconds to answer?
- Can this repository tell `invalid_code` apart from `too_many_outcomes`?
- Is any `message` the server wrote being thrown away and replaced?
- How many upstream calls does one tap cause, worst case?
- Would this base URL work on a physical device?

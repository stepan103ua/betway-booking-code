# Testing

`docs/mobile.md` §8, and the same principle as the backend's fixture-provider tests
(`docs/backend.md` §7): every layer verifiable without the one below it actually running.

## Shape

- **`SlipCubit` is tested against a fake `BookingCodeRepository`** — the interface, not the
  implementation. A Cubit test that constructs `BookingCodeRepositoryImpl` or mocks `Dio` is a
  **Should fix**: it exercises three layers, so it fails for three reasons and diagnoses none
  of them.
- **The repository is tested against a fake data source**, asserting the `DioException` →
  `Failure` mapping. This is the highest-value test in the app — it is the only place transport
  semantics turn into words a user reads, and the mapping is invisible in a widget test.
- **The data source is tested against a mocked `HttpClientAdapter`** (or `http_mock_adapter`),
  asserting the request shape: method, path, body. It is the only file that knows the endpoint,
  so it is the only place a path typo can be caught.
- A test that reaches the real API is a **Blocker**. It fails when the dev server is not
  running, when the machine is offline, and in CI — and each failure looks like a bug in the
  code under test rather than in the test.

## `bloc_test` and `mocktail` specifics

- **The initial state is not in `expect`.** `blocTest` asserts only states emitted after `act`,
  so a list starting with `SlipState.initial()` fails with a diff that reads like the Cubit is
  broken. Worth knowing before it costs an hour.
- Prefer `isA<SlipLoaded>()` with a field matcher over `equals` on a whole state object. An
  assertion on the entire state breaks on every unrelated field added later and teaches nothing
  when it does — same smell as `toEqual` on a whole response body server-side.
- `verify(() => repo.resolve('BW6E19810C')).called(1)` where "did it actually fetch, and once"
  is the thing under test — a debounce, a guard against double submission, or the deliberate
  absence of a client retry.
- `registerFallbackValue` for any non-primitive passed to `any()`. Without it `mocktail` throws
  at run time with a message that does not name the missing type.
- `emitsInOrder` / `expectLater` on `cubit.stream` for anything `blocTest` cannot express; a
  hand-rolled `await Future.delayed` to let a state land is a flake waiting for a slow CI box.

## What deserves a test

In priority order — this is one screen, and coverage percentage is not the goal:

1. **The `fromJson` boundary.** Every trap in `models-and-contracts.md` lives here: an integer
   price, a null `expiresAt`, a `Z` timestamp. One test with a real response body captured from
   the API is worth more than the rest of the suite.
2. **The `Failure` mapping**, including the case with no `response` at all.
3. **The Cubit's state sequence** for success and for each failure branch the UI renders
   differently.
4. **One widget test per state branch** — `pumpWidget` with `BlocProvider.value` and a
   `MockCubit`. Cheap, and it is what catches the empty error branch in `ui.md`.

## What does not

Freezed-generated `copyWith` and `==`, the `Failure` message strings, a widget with no
branching. Tests over generated or trivial code inflate the count and make the suite duller to
read — **Nit**, at most once.

Golden and integration tests are explicitly out of scope (`docs/mobile.md` §12). Do not flag
their absence; flagging a documented decision as a gap is how a review loses credibility.

## Smells

- A fixture invented by hand rather than captured from the API. It drifts from the real shape
  and quietly stops exercising the parser — the same rule as `apps/api/fixtures/`.
- No test for the failure path. A Cubit with only a happy-path test is a **Should fix**; the
  failure paths are the ones a user on a mobile connection meets first.
- Shared mutable state between tests — a `getIt` registration that survives, a singleton Cubit —
  producing passes that depend on file order. `getIt.reset()` in `tearDown`.
- A test asserting current behaviour rather than intended behaviour. It pins the bug in place.

## Questions worth asking

- Does this suite pass with the API not running?
- Which field would I have to break in a fixture to make a test fail?
- Is every branch the UI renders differently covered by a state test?
- Does any test depend on the order the others ran in?
- Is this fixture real, or imagined?

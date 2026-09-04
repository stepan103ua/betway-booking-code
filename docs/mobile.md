# Mobile — Betway Nigeria Booking Code Product

`apps/mobile` — feature-first architecture: every screen owns its own Bloc/Cubit,
repository, and remote data source, in an identical skeleton. All three features are built —
`decode` (the slip view the brief asks for), `create` (build a slip from scratch, generate a
code) and `convert` (reissue a code without its dead legs) — and `create` and `convert` were
each added by copying `decode`'s four-layer shape, not by restructuring anything. That's the
point of feature-first: the shape of the codebase doesn't change when the app grows, only the
number of `features/*` folders does.

Checked against the official Bloc library architecture docs (bloclibrary.dev) and pub.dev
package pages, not recalled from memory. Pin the exact Flutter/Dart version with
`flutter --version` at project start rather than trusting a number written down here — the
SDK ships new stables often enough that hardcoding one in a doc is itself a bad habit.

---

## 1. Stack

| | |
|---|---|
| Framework | Flutter, latest stable channel |
| State management | `flutter_bloc` — Cubit per feature, not full Bloc (§4) |
| DI | `get_it` — one registration per feature's dependency chain |
| Immutable state / unions | `freezed` + `json_serializable` |
| Networking | `dio` |
| Testing | `bloc_test` + `mocktail` |
| Distribution | Firebase App Distribution (APK) |
| Design | `lib/design/` — the reference implementation of `docs/design-system.md` (tokens, component kit, shared with `apps/web`) |

---

## 2. Folder structure

```
lib/
  core/
    network/
      dio_client.dart              one Dio instance: base URL, timeout, logging interceptor
    di.dart                        get_it setup — registers every feature's chain
    failure.dart                   shared Failure hierarchy (§5), every feature throws it
  features/
    decode/
      data/
        datasources/
          booking_code_remote_data_source.dart   raw dio call, raw JSON in/out
        repositories/
          booking_code_repository_impl.dart       implements the domain interface
      domain/
        repositories/
          booking_code_repository.dart             abstract interface
      presentation/
        cubit/
          slip_cubit.dart            resolve on submit
          popular_codes_cubit.dart   the "try a code" list, its own load / load-more
        pages/
          decode_screen.dart
    create/                          same four layers as decode/
      data/{datasources,repositories}/
      domain/repositories/
      presentation/
        cubit/
          create_cubit.dart          sports + draft + generate
          events_cubit.dart          the paginated fixture list
          event_markets_cubit.dart   markets for one event, scoped to the sheet
        model/
          draft_pick.dart            UI-only leg shape — see §3
        pages/create_screen.dart     `CreateView` — the scrolling content only
        widgets/                     sport_selector, outcome_chip,
                                     market_picker_sheet, created_code_view,
                                     event_tile (shows the event's draft leg —
                                       even one picked from "More markets"),
                                     draft_bar (floating island: summary opens
                                       the sheet, Generate acts direct) +
                                     draft_sheet (the full slip)
    convert/                         same four layers as decode/
      data/{datasources,repositories}/   resolve, then convert
      domain/repositories/
      presentation/
        cubit/convert_cubit.dart     loaded slip + drop set + convert
        pages/convert_screen.dart
        widgets/                     convert_leg_row (keep/drop toggle), convert_result_view
  shell/app_shell.dart               wordmark + mode tabs + the active screen in one page
                                     scroll (the web's model); Create adds a floating
                                     `DraftBar` in an overlay above that scroll, and
                                     owns the scroll controller so generating a code
                                     jumps back to the top where the recap lands
  design/                            tokens + core widget kit — implements docs/design-system.md §2–§4
  widgets/slip/                      slip anatomy (SelectionRow, SlipCard, …) — docs/design-system.md §5–§6
  models/
    slip.dart, selection.dart        mirror packages/contracts §0, shared above features/
    fixture.dart                     Fixture, Market, MarketOutcome — for Create's browse
    events_page.dart, popular_codes_page.dart, sport.dart
    convert_result.dart              Slip fields + previousBookingCode/previousTotalOdds/droppedCount
  main.dart
```

`models/` sits outside `features/` deliberately: `Slip` is the one shape every feature would
share (Decode reads it, Create would build it, Convert would diff it) — putting it inside
`features/decode/` would mean `features/create/` importing across another feature's
boundary, which is the exact coupling feature-first is meant to avoid.

---

## 3. Layer responsibilities

Four layers per feature, each with one job:

| Layer | Owns | Knows about |
|---|---|---|
| `data/datasources` | The actual HTTP call via `dio`, raw JSON ↔ `Slip.fromJson`/`toJson` | The API's URL and shape. Nothing else. |
| `data/repositories` | Calling the data source, translating `DioException` into `Failure` (§5) | The data source. Not `dio` directly, not the UI. |
| `domain/repositories` | The abstract contract (`abstract class BookingCodeRepository`) the Cubit depends on | Nothing — it's an interface, no imports from `data/` or `presentation/` |
| `presentation/cubit` | Holding `SlipState`, calling the repository, catching `Failure` | The domain interface only — never the concrete `RemoteBookingCodeRepository` or `dio` |

The Cubit constructor takes `BookingCodeRepository` (the interface), not
`BookingCodeRepositoryImpl` — that's what makes `bloc_test` possible without a mocked `dio`
anywhere near it (§8), and it's the same seam `BookingCodeProvider` plays server-side
(`docs/backend.md` §3): swap the implementation, the Cubit never notices.

One layer deliberately **not** present: a domain `Entity` distinct from the `Slip` model.
Clean Architecture write-ups often split "data model" (DTO, knows how to (de)serialize) from
"domain entity" (plain object, no JSON awareness) with a mapper between them. Here that
mapper would convert `Slip` into an identical `Slip` — there's no divergence between what the
API returns and what the UI needs, so the split has no job to do. If Create or Convert later
needs a UI-only shape that isn't what the API returns, that's the moment to introduce it —
not before.

Create reached that moment. `DraftPick` (`features/create/presentation/model/draft_pick.dart`)
is a leg the user has added while building a slip, before any code exists — an aggregate of
`Fixture` + `Market` + `MarketOutcome` that no single endpoint returns. It lives in
`presentation/`, not `lib/models/`, precisely because `lib/models/` mirrors the API DTOs and
this deliberately does not. It carries a `toSelection()` so the shared `SelectionRow` still
renders it.

---

## 4. State management — Cubit, not Bloc

`flutter_bloc` ships both `Bloc` (events → states — an explicit event log, worth it when
several places in the UI can trigger the same transition) and `Cubit` (methods emit states
directly). Decode has exactly one trigger, "code submitted," so `Bloc` would mean a one-member
`Event` hierarchy for a single event. `Cubit` is proportional here; Create's picker, with
several distinct triggers (select outcome, remove outcome, generate), was the more plausible
candidate for `Bloc`.

Create is built now, and it stayed on `Cubit` — three of them, split by concern rather than
one fat cubit or one event hierarchy: `CreateCubit` (sport list, the draft, generate),
`EventsCubit` (the paginated fixture list, its own load / load-more triggers and its own
failure surface), and a per-sheet `EventMarketsCubit`. Each has one job and is
`bloc_test`-able in isolation, and the app carries no `Event` classes anywhere — the
consistency was worth more than the explicit event log a `Bloc` would have added. `Bloc`
remains the right call the day a single transition genuinely fires from several places.

```dart
// slip_state.dart
@freezed
sealed class SlipState with _$SlipState {
  const factory SlipState.initial() = SlipInitial;
  const factory SlipState.loading() = SlipLoading;
  const factory SlipState.loaded(Slip slip) = SlipLoaded;
  const factory SlipState.error(Failure failure) = SlipError;
}
```

```dart
// slip_cubit.dart
class SlipCubit extends Cubit<SlipState> {
  SlipCubit(this._repository) : super(const SlipState.initial());
  final BookingCodeRepository _repository;

  Future<void> resolve(String code) async {
    emit(const SlipState.loading());
    try {
      final slip = await _repository.resolve(code);
      emit(SlipState.loaded(slip));
    } on Failure catch (f) {
      emit(SlipState.error(f));
    }
  }
}
```

`sealed` makes the widget's `switch` over `SlipState` exhaustive at compile time — a fifth
state added later without a matching UI branch is a build error, not a silent gap.

---

## 5. Error handling — a shared `Failure` hierarchy

Without the data source / repository split, a `DioException` would either leak straight into
the Cubit (coupling business logic to a networking library) or get caught ad hoc per feature.
With the split, the repository's one real job is translating transport-level errors into
something the Cubit can pattern-match on:

```dart
// core/failure.dart
sealed class Failure {
  const Failure(this.message);
  final String message;
}
class NetworkFailure extends Failure {
  const NetworkFailure() : super('Check your connection and try again.');
}
class InvalidCodeFailure extends Failure {
  const InvalidCodeFailure() : super('That code doesn\'t look right.');
}
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
```

```dart
// booking_code_repository_impl.dart
class BookingCodeRepositoryImpl implements BookingCodeRepository {
  BookingCodeRepositoryImpl(this._remote);
  final BookingCodeRemoteDataSource _remote;

  @override
  Future<Slip> resolve(String code) async {
    try {
      return await _remote.resolve(code);
    } on DioException catch (e) {
      switch (e.response?.statusCode) {
        case 404: throw const InvalidCodeFailure();
        case null: throw const NetworkFailure(); // no response = connectivity/timeout
        default: throw UnknownFailure(e.message ?? 'Unexpected error.');
      }
    }
  }
}
```

`Failure` lives in `core/`, not inside `features/decode/`, for the same reason `models/`
does — the Cubit-side `switch (failure) { ... }` pattern is identical across features.

Decode uses the three shapes above. Create adds four more to the same shared hierarchy —
`NotFoundFailure` (event has no markets), `TooManyOutcomesFailure` and
`OutcomesUnavailableFailure` (the two `POST /api/booking-codes` 400s a client can act on
differently), told apart by the `ApiError.error` code rather than the status. This is the
"richer hierarchy once a feature has more than one 4xx to tell apart" the three-shape rule
anticipated, not a departure from it.

`Either<Failure, Slip>` (via `dartz`/`fpdart`) is the more "purist" functional alternative to
throw/catch here — deliberately not used. It's a real, defensible choice on a larger team; for
one feature it's a second way to express the same three-branch outcome, and `bloc_test`
asserts on emitted states either way, so it wouldn't change what's actually verified.

---

## 6. Remote data source

```dart
// booking_code_remote_data_source.dart
class BookingCodeRemoteDataSource {
  BookingCodeRemoteDataSource(this._dio);
  final Dio _dio;

  Future<Slip> resolve(String code) async {
    final res = await _dio.post('/api/booking-codes/resolve', data: {'code': code});
    return Slip.fromJson(res.data as Map<String, dynamic>);
  }
}
```

This is the only file in the feature that imports `dio` or knows the endpoint path — if the
API's route or payload shape changes, this is the one place that changes. `dio`'s own
`DioException` (distinguishing timeout / connection / bad-response) is why it's used over the
bare `http` package: that distinction is exactly what `BookingCodeRepositoryImpl` needs to
produce a useful `Failure` instead of one generic message, which matters more than usual given
the audience (NG mobile connections — same framing as `docs/backend.md`'s caching rationale).

The single `Dio` instance (base URL, timeout, logging interceptor) lives in
`core/network/dio_client.dart` and is injected into every feature's data source — one client,
shared, not reconstructed per feature.

---

## 7. Dependency injection

```dart
// core/di.dart
final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<Dio>(() => buildDioClient());
  getIt.registerLazySingleton<BookingCodeRemoteDataSource>(
    () => BookingCodeRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<BookingCodeRepository>(
    () => BookingCodeRepositoryImpl(getIt()),
  );
  getIt.registerFactory(() => SlipCubit(getIt()));
}
```

With one feature, this is arguably more than a single `BlocProvider(create: (_) =>
SlipCubit(RemoteBookingCodeRepository(dio)))` strictly needs. It's included anyway because
the ask here is a scalable shape, not the minimum code for today: `get_it` is what stops
`main.dart` from accumulating a hand-wired constructor chain per feature as Create and Convert
get added — the cost is paid once, now, while there's only one chain to register.

---

## 8. Testing

Each layer is tested where it can fail, not just at the top:

- **`BookingCodeRemoteDataSource`** — `mocktail` on a fake `Dio` adapter, asserting the
  request shape (`POST /api/booking-codes/resolve`, correct body) and that a non-2xx response
  surfaces as `DioException`.
- **`BookingCodeRepositoryImpl`** — given a fake data source, asserts the
  `DioException → Failure` mapping in §5 (404 → `InvalidCodeFailure`, no response →
  `NetworkFailure`).
- **`SlipCubit`** — `bloc_test` against a fake `BookingCodeRepository` (the interface),
  asserting the state sequence:

```dart
blocTest<SlipCubit, SlipState>(
  'emits loading then loaded on successful resolve',
  build: () => SlipCubit(FakeBookingCodeRepository()),
  act: (cubit) => cubit.resolve('BW6E19810C'),
  expect: () => [const SlipState.loading(), isA<SlipLoaded>()],
);
```

No layer's test depends on the layer below actually running — the Cubit test never touches
`dio`, the repository test never touches the network. Same principle as the backend's
fixture-provider tests (`docs/backend.md` §7): every layer is verifiable in isolation.

---

## 9. Adding the second and third screens

Concretely, what "scalable" bought: Create was `features/create/{data,domain,presentation}/`
in the same four-layer shape, new `Failure` subtypes (§5), new DTO models for the browse
endpoints (§2), and one more block in `core/di.dart`. Nothing in `core/`, `models/slip.dart`,
`widgets/slip/`, or `features/decode/` changed. Create is larger than Decode — a
three-step picker and a bottom sheet rather than one input — so it grew to three cubits and a
handful of feature-local widgets, but every one of those sits inside `features/create/`.

Convert was cheaper still: one `ConvertCubit`, one data source (`resolve` then `convert`),
one model (`convert_result.dart`), two feature widgets, `EmptySlipFailure` /
`ConflictingSelectionsFailure` added to the shared hierarchy. The only edit outside
`features/convert/` was `shell/app_shell.dart` — Decode's "Rebuild" button now hands the code
to the Convert tab (`onConvert` went from `VoidCallback` to `void Function(String)`), and a
one-line `_convertCode` on the shell carries it. That's the concrete test of whether
"feature-first" was real: each new feature cost roughly what the first one's shape promised.

---

## 10. UI

`SlipCard` renders the identical information the web app's slip card does
(`docs/frontend.md` §2): booking code, total odds, expiry, usage count, per-selection
event/market/outcome/odds/kick-off, inactive-row treatment. `decode_screen.dart`'s
`switch (state) { SlipInitial() => ..., SlipLoading() => ..., SlipLoaded(:final slip) => ...,
SlipError(:final failure) => Text(failure.message) }` — Dart 3 pattern-matching over the
freezed union, exhaustive, no default branch to accidentally fall into.

Create's screen is the same idea at a larger scale: a `switch` over `CreateState`
(loading sports → picker → success), the picker itself a `switch` over `EventsState`, and
the sheet a `switch` over `EventMarketsState`. The draft tray and success recap both reuse
`SlipCard` / `SelectionRow` unchanged — `DraftPick.toSelection()` is the only glue. Outcome
odds get the same mono odds face and the running total the same `oddsHero` treatment the
decoded slip's total does.

The picker enforces **one pick per match**: once an event has a leg in the draft, its other
outcomes go disabled (inline and in the sheet) with a one-line note. A booking code is a plain
accumulator, so two legs on one event conflict — `POST /api/booking-codes` rejects such a slip
as `conflicting_selections` (`docs/betway-api.md` §3), and this keeps the user from hitting
that. `CreateCubit.toggleOutcome` also drops a conflicting add, so a race can't slip one past
the disabled chips.

Convert's screen is a `switch` over `ConvertState` (enter a code → pick what to drop → the
after view). The picker reuses `CodeInput` for the code entry and a feature-local
`ConvertLegRow` for the checklist — that row is *not* `SelectionRow`, because `SelectionRow`'s
only "struck through" state is `!isActive` and Convert needs a third: a live leg the user
chose to drop. Dead legs render struck and disabled ("dropped automatically"); the before/
after odds are `original.totalOdds` versus a **preview** product of the kept legs, clearly
marked `≈` because the real total is re-priced by `/convert`. The after view is a plain
`SlipCard` of `ConvertResult` with the diff in its notice slot — no recap caveat needed, since
`ConvertResult` carries the decoded new slip.

---

## 11. Distribution

Android build → APK → Firebase App Distribution, per the brief. iOS: no build in scope, one
paragraph in the README on what the IPA path would require — Apple Developer Program
enrollment, a distribution certificate and provisioning profile in place of Android's simpler
signing, and either registered tester UDIDs for an ad-hoc build or TestFlight, which goes
through Apple review.

---

## 12. Explicitly not used, and why

- **Domain `Entity` distinct from `Slip`** — §3. `DraftPick` is a presentation shape, not a
  domain entity with a mapper to and from an identical model.
- **`Bloc` (event classes) over `Cubit`** — §4. Decode has one trigger; Create and Convert
  have several each but stayed on `Cubit` (Create split into three by concern) to keep the app
  free of `Event` classes. `Bloc` still fits the day one transition fires from several places.
- **`Either`/`dartz`/`fpdart`** — §5. Throw/catch expresses the same outcomes; `bloc_test`
  verifies the same states either way, and Create's larger `Failure` hierarchy doesn't
  change that.
- **Riverpod / GetX for state management** — `flutter_bloc` chosen deliberately over the
  author's own production background with GetX (eKreative), to demonstrate range.
- **Golden tests / integration tests** — one screen shipped, two days; layer-isolated unit
  tests (§8) are where the return on time actually is.
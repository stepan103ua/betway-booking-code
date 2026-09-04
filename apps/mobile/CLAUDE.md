# apps/mobile — Flutter client

A plain HTTP consumer of `apps/api`, on the same footing as `apps/web`. Nothing in this app
talks to Betway directly, and nothing in it needs to know Betway exists.

## Read the docs first

`docs/mobile.md` is the source of truth for this app's architecture and settles nearly every
structural question a reviewer would ask. Read it before writing code here, and don't restate
it in this file or in comments — two copies of the same fact drift, and the root `CLAUDE.md`
already makes that argument once for the whole repo.

| Doc | What it settles |
|---|---|
| `docs/mobile.md` | Stack, folder structure, Cubit-per-feature, the repository seam, `get_it`, the `Failure` hierarchy, testing shape |
| `docs/backend-api.md` §0 | The DTOs `lib/models/` mirrors — field names, types, nullability, exactly |
| `docs/backend-api.md` §1 | The booking-code endpoints' request/response contract and error cases, per endpoint |
| `docs/architecture.md` | System overview and the Decode/Convert sequence diagrams |
| `docs/backend.md` | Why `apps/api` looks the way it does, when a client-side decision seems to assume something about the backend |
| `docs/betway-api.md` | Upstream traps — rarely relevant here directly, but the reason behind an API behavior this app has to render (e.g. why `expiresAt` is always null) usually traces back to this doc |
| `docs/design-system.md` | What `lib/design/` and `lib/widgets/slip/` implement — tokens, components, the visual rules. `lib/design/` is that doc's reference implementation, so this app is where it and the doc are most likely to disagree |

If this app's code and a doc disagree, that's a bug in one of them — say so rather than
silently picking a side.

---

## Layout

Full rationale is `docs/mobile.md` §2–§3. The shape in this repo today:

```
lib/
  design/            ported design-system tokens + core widget kit (Button, Card, Badge, ...)
  widgets/slip/       the slip anatomy — shared across every feature, same reason models/
                      sits above features/
  models/             Slip, Selection, Fixture (Market, MarketOutcome), EventsPage, Sport,
                      PopularCodesPage, ConvertResult — freezed + json_serializable, mirror
                      docs/backend-api.md §0 field for field
  core/
    network/dio_client.dart   the one Dio instance
    di.dart                    get_it registrations
    failure.dart                shared Failure hierarchy
  features/
    decode/{data,domain,presentation}/   resolve + popular codes
    create/{data,domain,presentation}/   sport → event → markets picker → generate a code
    convert/{data,domain,presentation}/  resolve a code → drop legs → reissue it
  shell/app_shell.dart   header + mode tabs
  main.dart
```

All three features follow the `features/decode/` skeleton. `features/create/` splits into
three cubits (`CreateCubit`, `EventsCubit`, `EventMarketsCubit` — by concern, still all
`Cubit`, see `docs/mobile.md` §4) and has `presentation/model/draft_pick.dart`, the one UI-only
shape the app carries (sanctioned by `docs/mobile.md` §3 — a draft leg is not any endpoint's
response). `features/convert/` is one `ConvertCubit` over `resolve` then `convert`, with a
feature-local `ConvertLegRow` (a keep/drop checklist row — deliberately not `SelectionRow`,
which only knows the dead/live split). Decode's "Rebuild" button hands its code to the Convert
tab through `shell/app_shell.dart` (`onConvert` carries the code).

## Commands

```bash
flutter pub get
cp dart_defines.example.json dart_defines.json                  # once — gitignored, real URLs
flutter run --dart-define-from-file=dart_defines.json           # see core/network/dio_client.dart
dart run build_runner build --delete-conflicting-outputs        # after touching an @freezed model or state
flutter analyze
dart format --output=none --set-exit-if-changed lib test
flutter test
```

Generated `.freezed.dart` / `.g.dart` files are committed. Anyone touching a `@freezed` class
(`lib/models/`, `lib/features/*/presentation/cubit/*_state.dart`) reruns `build_runner` and
commits the result — a stale generated file is a worse failure mode than a large diff, since
`flutter analyze` won't catch a generated file that's silently out of sync with its source.

## Invariants

- **Nothing above `data/datasources` imports `dio`.** An import of `package:dio` in
  `domain/`, `presentation/`, or a widget is the one thing the repository/data-source split
  exists to prevent (`docs/mobile.md` §3, §6).
- **A Cubit depends on the domain interface, never the concrete `*Impl`.** Constructing
  `BookingCodeRepositoryImpl` anywhere outside `core/di.dart` defeats the seam `bloc_test`
  needs.
- **A widget under `widgets/slip/` takes the real domain model (`Selection`, `Slip`), not a
  parallel UI-only shape.** `docs/mobile.md` §3 declines a view model distinct from the API
  model until there's a real divergence to justify it — formatting `kickoffAt` or deriving a
  generic dead-leg reason inline in the widget is that divergence's entire job; a new
  `SlipSelectionView`-style class reintroducing it is not.
- **A model field not in `docs/backend-api.md` §0 is a bug**, the same rule the backend holds
  itself to. So is a field with the wrong nullability — `expiresAt` and `usageCount` are
  genuinely `null` on every `resolve` response (§1), and a non-nullable field or a UI branch
  that assumes otherwise is building for data this endpoint cannot produce.
- **Every `@freezed` odds/price field is typed `double`, never inferred.** `jsonDecode` gives
  `int` for a whole-number price; `json_serializable` only guards against that when the field's
  declared type says `double`.
- **A timestamp is rendered through `.toLocal()` before it reaches a `Text` widget.**
  `kickoffAt` is UTC; skipping the conversion shows a Lagos user a kickoff an hour early.
- **No fake data behind a real-looking label.** If a screen doesn't have a real data source
  yet, its demo content says so in a comment and doesn't claim to be something it isn't (see
  Decode's "Try a code" list, not "Recently decoded" — nothing persists a decode).

## Conventions

- Relative imports throughout `lib/` — this is Dart, not the `nodenext` package next door;
  no `.js`-extension rule applies here.
- `flutter_lints` catches missing `const`, unawaited futures, and `BuildContext` use across an
  async gap. Don't re-flag what the analyzer already underlines.
- A `Failure` subclass lives in `core/failure.dart`, shared across features, per
  `docs/mobile.md` §5 — not one hierarchy per feature.
- Base URL is a build-time define — `dart_defines.json` via `--dart-define-from-file`, or a
  bare `--dart-define` — never hardcoded past `core/network/dio_client.dart`'s own documented
  default. `localhost` means the host on an iOS simulator, the emulator itself on Android
  (`10.0.2.2` reaches the host there), and nothing useful on a physical device.

## Anti-goals

Reach for none of these without saying why first — `docs/mobile.md` §12 declines each by name:

- a domain `Entity` distinct from `Slip`/`Selection`
- `Bloc` (event classes) over `Cubit`, for a feature with one trigger
- `Either`/`dartz`/`fpdart` in place of throw/catch
- Riverpod, GetX, or any state management library besides `flutter_bloc`
- golden tests or integration tests, for the same two-day-scope reason the backend's `CLAUDE.md`
  gives for its own anti-goals

## Done means

`flutter analyze && dart format --output=none --set-exit-if-changed lib test && flutter test`
all pass, every model field traces to `docs/backend-api.md` §0, and any new upstream-shaped
behavior discovered while building a screen (a field that's always null, a status code the
backend doesn't document) is written back into the relevant doc — not left as something only
this app's code remembers.

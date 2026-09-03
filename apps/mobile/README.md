# apps/mobile — Flutter client

A plain HTTP consumer of `apps/api`, on the same footing as `apps/web`. Nothing here talks to
Betway directly. See [`CLAUDE.md`](CLAUDE.md) for the doc map and the invariants a change here
has to hold.

## Status

**All three features are real**, end to end, each in the identical
data/domain/presentation split `docs/mobile.md` §2–§7 specifies, with the layer-isolated tests
§8 asks for (`test/features/`):

- **Decode** — `POST /api/booking-codes/resolve` and `GET /api/booking-codes/popular`
  (`SlipCubit`, `PopularCodesCubit`).
- **Create** — `GET /api/sports`, `GET /api/events`, `GET /api/events/:id/markets` and
  `POST /api/booking-codes`, driving a sport → event → markets picker (`CreateCubit`,
  `EventsCubit`, per-sheet `EventMarketsCubit`).
- **Convert** — `POST /api/booking-codes/resolve` then `/convert` (`ConvertCubit`).

## Layout

```
lib/
  design/            tokens (colour, type, spacing, radius, motion) + the core widget kit
                      (Button, Card, Badge, Alert, Input, Tabs, Sheet, Skeleton, icons)
  widgets/slip/       the slip anatomy — SlipCard, SlipHeader, SelectionRow, CodeInput,
                      EmptyState, SlipSkeleton. Takes the real Selection/Slip models
                      directly, shared across all three features
  models/             Slip, Selection, Fixture (Market, MarketOutcome), EventsPage, Sport,
                      PopularCodesPage, ConvertResult — freezed + json_serializable, mirror
                      docs/backend-api.md §0
  core/               dio_client.dart, di.dart (get_it), failure.dart
  features/
    decode/{data,domain,presentation}/    resolve + popular codes
    create/{data,domain,presentation}/    sport → event → markets picker → generate
    convert/{data,domain,presentation}/   resolve a code → drop legs → reissue it
  shell/app_shell.dart  wordmark header + mode tabs (no bottom nav — see Notes)
```

## Running it

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:3000
```

`API_BASE_URL` defaults to `http://localhost:3000` if omitted, which is correct for the iOS
simulator against a locally running `apps/api` (`npm run dev` from the repo root) and nothing
else — see `lib/core/network/dio_client.dart`'s doc comment for the Android emulator
(`10.0.2.2`) and physical-device case.

```bash
dart run build_runner build --delete-conflicting-outputs   # after touching an @freezed class
flutter analyze
dart format --output=none --set-exit-if-changed lib test
flutter test
```

## Distribution

**Android → APK → Firebase App Distribution**, per the brief.

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://<your-api-host>
```

`--dart-define` is compile-time, so the release base URL has to be on this command line (or a
CI variable) — a build without it points at `http://localhost:3000` and reaches nothing. One
fat APK is fine here; `--split-per-abi` is a size optimisation not worth the extra upload step
yet.

Two things must be in place before the first real distribution build, both currently left as
the Flutter template defaults:

- **A release signing config.** `android/app/build.gradle.kts` still signs `release` with the
  debug keystore so `flutter run --release` works. Generate a keystore, put its path and
  passwords in `android/key.properties` (already gitignored, along with `*.jks`/`*.keystore`),
  and point `signingConfigs.release` at it.
- **`version:` in `pubspec.yaml`** bumped per build — App Distribution shows two uploads with
  the same `versionName+versionCode` as indistinguishable.

**iOS is out of scope** — no build was produced. An IPA path would need: Apple Developer
Program enrollment; a distribution certificate and provisioning profile (replacing Android's
single-keystore signing); and either registered tester UDIDs for an ad-hoc build or TestFlight,
which adds an Apple review step. The `Info.plist` here carries no App Transport Security
exception, so a production build already requires an HTTPS API with no code change.

## Notes

- **Fonts**: Archivo + JetBrains Mono via the `google_fonts` package (no binaries were supplied
  with the design system — same substitution the web build's `tokens/fonts.css` makes with a
  Google Fonts `@import`).
- **Icons**: `package:lucide_icons` is a dependency for its bundled `Lucide` font asset only.
  Its own `LucideIcons.*` constants don't compile on current Flutter (`IconData` became a
  `final class` after that package was last published, so its `extends IconData` subclass no
  longer works) — `lib/design/app_icons.dart` builds `IconData` directly from the same
  codepoints instead. See that file's doc comment for the handful of pre-rename icon names.
- **Dark only for v1.** The source kit's bottom nav (`Codes`/`Saved`/`You`), header icons
  (`History`, theme toggle) and light theme switch are all cut — none of those destinations or
  states exist yet. `AppColors.light` / `AppTheme.light()` stay in `lib/design/` regardless:
  they're ported tokens, not UI, and cost nothing sitting unused until a real theme switch is
  in scope.
- **Generated code is committed.** `.freezed.dart` / `.g.dart` files for `lib/models/` and
  every `*_state.dart` / UI-only model under `lib/features/*/presentation/` are checked in, so
  a fresh clone runs `flutter analyze` / `flutter test` without a code-gen step first. Rerun
  `build_runner` and commit the result after changing any `@freezed` class.

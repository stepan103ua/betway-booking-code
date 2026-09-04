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

Build-time config lives in a JSON file, not on the command line — copy the committed template
once and edit it for your target:

```bash
cp dart_defines.example.json dart_defines.json   # gitignored; holds real URLs / secrets
```

```bash
flutter pub get
flutter run --dart-define-from-file=dart_defines.json
```

`dart_defines.json` carries `API_BASE_URL`. The template points at `http://localhost:3000`,
which is correct for the iOS simulator against a locally running `apps/api` (`npm run dev`
from the repo root) and nothing else — see `lib/core/network/dio_client.dart`'s doc comment
for the Android emulator (`10.0.2.2`) and physical-device cases. A bare
`--dart-define=API_BASE_URL=…` still works and overrides the file for a one-off run.

```bash
dart run build_runner build --delete-conflicting-outputs   # after touching an @freezed class
flutter analyze
dart format --output=none --set-exit-if-changed lib test
flutter test
```

## Distribution

**Android → APK → Firebase App Distribution**, per the brief.

Set `API_BASE_URL` in `dart_defines.json` to the deployed API, then:

```bash
flutter build apk --release --dart-define-from-file=dart_defines.json
# → build/app/outputs/flutter-apk/app-release.apk
```

The value is compile-time, so it has to be baked in at build (the file, or a `--dart-define`
/ CI variable) — a build without it points at `http://localhost:3000` and reaches nothing.
One fat APK is fine here; `--split-per-abi` is a size optimisation not worth the extra upload
step yet.

Then push it to testers (Firebase CLI, or drag it into the App Distribution console):

```bash
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app <FIREBASE_ANDROID_APP_ID> --groups reviewers
```

Firebase App Distribution needs no `google-services.json` and no SDK in the app — only the
project's Android App ID and a signed APK.

One thing to put in place before the first tester build:

- **A release signing config.** `android/app/build.gradle.kts` falls back to the debug
  keystore when `android/key.properties` is absent, so `flutter build apk --release` works on
  a fresh clone. For a build testers install, generate a keystore and put its path and
  passwords in `android/key.properties` (gitignored, along with `*.jks`/`*.keystore`) — the
  gradle config already points `signingConfigs.release` at it.
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

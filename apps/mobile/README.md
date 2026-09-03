# apps/mobile — Flutter client

A plain HTTP consumer of `apps/api`, on the same footing as `apps/web`. Nothing here talks to
Betway directly. See [`CLAUDE.md`](CLAUDE.md) for the doc map and the invariants a change here
has to hold.

## Status

**Decode is real**, end to end: `SlipCubit` → `BookingCodeRepository` →
`BookingCodeRemoteDataSource` → `POST /api/booking-codes/resolve`, the full
data/domain/presentation split `docs/mobile.md` §2–§7 specifies, with the layer-isolated tests
§8 asks for (`test/features/decode/`).

**Create and Convert are placeholders** — an `EmptyState` saying plainly that the screen isn't
built, not a picker that looks functional and hands back a hardcoded fake code. Wiring either
for real means giving it the same `data/domain/presentation` skeleton `features/decode/`
already has.

## Layout

```
lib/
  design/            tokens (colour, type, spacing, radius, motion) + the core widget kit
                      (Button, Card, Badge, Alert, Input, Tabs, Sheet, Skeleton, icons)
  widgets/slip/       the slip anatomy — SlipCard, SlipHeader, SelectionRow, CodeInput,
                      CodeResult, EmptyState, SlipSkeleton. Takes the real Selection/Slip
                      models directly, shared across all three features
  models/             Selection, Slip — freezed + json_serializable, mirror
                      docs/backend-api.md §0
  core/               dio_client.dart, di.dart (get_it), failure.dart
  features/
    decode/{data,domain,presentation}/   real API wiring
    create/, convert/                     placeholder screens — see Status
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
- **Generated code is committed.** `.freezed.dart` / `.g.dart` files for everything in
  `lib/models/` and `lib/features/decode/presentation/cubit/` are checked in, so a fresh clone
  runs `flutter analyze` / `flutter test` without a code-gen step first. Rerun `build_runner`
  and commit the result after changing any `@freezed` class.

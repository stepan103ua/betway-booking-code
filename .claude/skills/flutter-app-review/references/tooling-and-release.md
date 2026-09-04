# Tooling, build configuration and getting an APK to a tester

`docs/mobile.md` §11. Android APK via Firebase App Distribution is the whole release story;
iOS is deliberately out of scope, so a missing iOS signing setup is not a finding — a missing
README paragraph explaining what an IPA would take is.

## The checks

`flutter analyze` clean and `dart format --output=none --set-exit-if-changed .` clean are this
app's equivalent of `npm run lint` and `npm run format:check`. The repo's `.prettierignore`
excludes `apps/mobile` on purpose: Dart tooling owns formatting here, and Prettier would
otherwise reflow `pubspec.yaml` and the `Contents.json` files Xcode rewrites on its own.

`analysis_options.yaml` includes `flutter_lints`. Disabling a rule is a legitimate decision and
an undocumented one is a **Nit** — a single comment saying why costs nothing and stops the next
person re-enabling it. Importing a hundred-rule custom lint set into a one-screen app is
ceremony pointed the other way.

## Configuration and secrets

Anything in `lib/` ships inside the binary and is readable after unpacking an APK. There is no
client-side secret, only client-side inconvenience.

- Base URL and any future key come from `--dart-define`, read with `String.fromEnvironment` and
  a local default. A committed non-local URL is a **Should fix**; a committed key of any kind is
  a **Blocker**, exactly as on the backend, and for the same reason — it is the habit that
  matters, not this particular value.
- `--dart-define` values are compile-time constants, so a build script or a documented command
  line has to carry them. If the README's run instructions do not mention them, the next person
  gets a build that points at nothing.

## `pubspec`

- `pubspec.lock` is committed for an application (it is not, for a published package). Without
  it, two builds of the same commit resolve different transitive versions and "works on my
  machine" becomes literal. **Should fix** if it is gitignored.
- Caret ranges for direct dependencies, and a reason in the review if something is pinned exact
  — usually a bug being worked around, which deserves a comment more than it deserves a pin.
- `version:` drives `versionName`/`versionCode` for the APK. Distributing two builds with the
  same version to App Distribution makes them indistinguishable in the console.

## Android

- **The template signs release builds with the debug keystore.** `android/app/build.gradle.kts`
  ships `signingConfig = signingConfigs.getByName("debug")` under `buildTypes.release`, with a
  TODO above it. It exists so `flutter run --release` works; an APK built that way is not
  something to hand to testers. **Should fix** before the first distribution, with the keystore
  itself gitignored and its path and passwords supplied outside the repo.
- `applicationId` is permanent identity. Changing it after anyone has installed the app makes a
  second, unrelated app on their device rather than an update.
- Whatever cleartext exception makes `http://` work against a local API must not be
  unconditional in the release manifest (see `data-layer.md`).
- `flutter build apk --release` produces one fat APK; `--split-per-abi` produces smaller
  per-architecture ones. For App Distribution the fat APK is simpler and the size difference is
  not worth the extra upload step yet. A `--debug` APK handed to a tester reads as a broken app
  rather than a slow one — it is several times slower before it does anything.

## Generated code in CI

If `.freezed.dart` and `.g.dart` are gitignored, every automated step that runs `flutter
analyze` or `flutter test` must run `dart run build_runner build --delete-conflicting-outputs`
first. Without it the analyzer reports hundreds of missing-part errors and the failure looks
nothing like its cause. Cross-referenced in `models-and-contracts.md`; flag it in whichever
file the diff touches, not both.

## Questions worth asking

- Does `flutter analyze` pass on a fresh clone, with no generation step run by hand?
- What is in the binary that should not be?
- Would two people building this commit get the same dependency versions?
- Is the APK a tester receives signed with anything other than the debug key?
- Does the README's run command include the defines the app needs to reach the API?

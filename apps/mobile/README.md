# apps/mobile — Flutter client

A plain HTTP consumer of `apps/api`, on the same footing as `apps/web`. Nothing here talks to
Betway directly.

Scaffold only at this point: `flutter create --empty`, Android and iOS, no dependencies beyond
the SDK. The architecture it grows into — feature-first folders, Cubit per feature, `get_it`,
`dio`, the `Failure` hierarchy — is settled in [`docs/mobile.md`](../../docs/mobile.md).

## Running it

```bash
flutter pub get
flutter run
```

The API's base URL is not wired up yet; on a device or emulator `localhost` is the phone, not
the host, so that indirection lands in `core/network/dio_client.dart` when the first screen does.

```bash
flutter analyze
flutter test
```

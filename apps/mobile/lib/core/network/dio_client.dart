import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// `apps/api`'s base URL. Passed at build/run time — via `dart_defines.json`
/// (`--dart-define-from-file`, see the mobile README) or a bare
/// `--dart-define=API_BASE_URL=http://10.0.2.2:3000` — because `localhost`
/// means something different on every target this app runs on:
///
/// - iOS simulator: `http://localhost:3000` shares the host Mac's loopback,
///   so the default below works unmodified.
/// - Android emulator: the emulator's own loopback is a different machine
///   from the host's; Google's documented address for the host is
///   `10.0.2.2`, not `localhost`.
/// - A physical device on the same network as the API: the host machine's
///   LAN address, e.g. `http://192.168.1.20:3000`.
///
/// No default beyond `localhost` is supplied because there is no one right
/// answer — a wrong guess here fails silently as "network error" with no
/// clue why, which is worse than requiring the flag explicitly once the
/// simulator default stops being enough.
const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000',
);

/// One `Dio` instance — base URL, timeouts, and (debug builds only) request
/// logging — shared by every feature's data source. `docs/mobile.md` §6:
/// this is the only place that constructs it.
Dio buildDioClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      // Bare on purpose: without these, a host that accepts the TCP
      // connection and then stalls hangs forever — there is no default
      // timeout on `BaseOptions`. NG mobile connections are exactly the
      // case this matters for (`CLAUDE.md`, `docs/backend.md`'s caching
      // rationale extends to the client too).
      connectTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      contentType: 'application/json',
    ),
  );

  // Booking codes are public and fine to log (`CLAUDE.md`); this still stays
  // out of release builds on general principle — a request/response log is
  // debug residue in a shipped app either way.
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }

  return dio;
}

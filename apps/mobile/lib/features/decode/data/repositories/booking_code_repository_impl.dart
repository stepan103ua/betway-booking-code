import 'package:dio/dio.dart';

import '../../../../core/failure.dart';
import '../../../../models/slip.dart';
import '../../domain/repositories/booking_code_repository.dart';
import '../datasources/booking_code_remote_data_source.dart';

/// Translates transport-level errors into a [Failure] the Cubit can
/// pattern-match on — the one job this layer has (`docs/mobile.md` §5).
/// Never sees `dio` types past this file's own `catch`.
class BookingCodeRepositoryImpl implements BookingCodeRepository {
  BookingCodeRepositoryImpl(this._remote);
  final BookingCodeRemoteDataSource _remote;

  @override
  Future<Slip> resolve(String code) async {
    try {
      return await _remote.resolve(code);
    } on DioException catch (e) {
      switch (e.response?.statusCode) {
        case 404:
          throw const InvalidCodeFailure();
        case null:
          // No response at all: `DioExceptionType.connectionTimeout`,
          // `.receiveTimeout` and `.connectionError` all land here. One
          // `Failure` for all three is `docs/mobile.md` §5's call — Decode
          // has no retry action that would need to tell them apart.
          throw const NetworkFailure();
        default:
          // The API answers every non-2xx with `{ error, message }`
          // (`docs/backend-api.md` §0), and that `message` is written to be
          // shown verbatim — a real improvement over `e.message`, which is
          // `dio`'s own generic "Http status error [500]" and tells a user
          // nothing. Still falls through to that if the body isn't the
          // shape expected, same as `docs/mobile.md`'s sketch falls back to
          // `'Unexpected error.'`.
          throw UnknownFailure(
            _serverMessage(e) ?? e.message ?? 'Unexpected error.',
          );
      }
    }
  }

  String? _serverMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return null;
  }
}

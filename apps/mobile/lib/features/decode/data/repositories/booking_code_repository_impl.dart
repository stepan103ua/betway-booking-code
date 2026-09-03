import 'package:dio/dio.dart';

import '../../../../core/failure.dart';
import '../../../../models/popular_codes_page.dart';
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
      // A 404 means specifically "no slip for this code" for `resolve` —
      // that reading doesn't apply to `popular` (a fixed, unparameterised
      // path can't 404 the same way), so it's handled here rather than in
      // the shared mapper below.
      if (e.response?.statusCode == 404) throw const InvalidCodeFailure();
      throw _mapTransportFailure(e);
    }
  }

  @override
  Future<PopularCodesPage> popular({int limit = 6, int skip = 0}) async {
    try {
      return await _remote.popular(limit: limit, skip: skip);
    } on DioException catch (e) {
      throw _mapTransportFailure(e);
    }
  }

  /// No response at all: `DioExceptionType.connectionTimeout`,
  /// `.receiveTimeout` and `.connectionError` all land here as
  /// [NetworkFailure] — one `Failure` for all three is `docs/mobile.md`
  /// §5's call, since neither caller has a retry action that would need to
  /// tell them apart. Any answered non-2xx becomes [UnknownFailure],
  /// carrying the server's own `message` (`docs/backend-api.md` §0's
  /// `ApiError`, written to be shown verbatim) rather than `dio`'s generic
  /// "Http status error [500]".
  Failure _mapTransportFailure(DioException e) {
    if (e.response == null) return const NetworkFailure();
    return UnknownFailure(
      _serverMessage(e) ?? e.message ?? 'Unexpected error.',
    );
  }

  String? _serverMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return null;
  }
}

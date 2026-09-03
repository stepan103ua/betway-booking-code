import 'package:dio/dio.dart';

import '../../../../core/failure.dart';
import '../../../../models/convert_result.dart';
import '../../../../models/slip.dart';
import '../../domain/repositories/convert_repository.dart';
import '../datasources/convert_remote_data_source.dart';

/// Translates transport errors into a [Failure] the cubit can pattern-match on
/// (`docs/mobile.md` §5). The convert call has the widest 4xx surface in the
/// app — four distinct codes a user can act on differently — all told apart by
/// the `ApiError.error` field, not the status.
class ConvertRepositoryImpl implements ConvertRepository {
  ConvertRepositoryImpl(this._remote);
  final ConvertRemoteDataSource _remote;

  @override
  Future<Slip> resolve(String code) async {
    try {
      return await _remote.resolve(code);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) throw const InvalidCodeFailure();
      throw _mapTransportFailure(e);
    }
  }

  @override
  Future<ConvertResult> convert(
    String code,
    List<String> dropOutcomeIds,
  ) async {
    try {
      return await _remote.convert(code, dropOutcomeIds);
    } on DioException catch (e) {
      // 404 is the resolve step failing — the same reading as `resolve()`.
      if (e.response?.statusCode == 404) throw const InvalidCodeFailure();

      if (e.response?.statusCode == 400) {
        final message = _serverMessage(e);
        switch (_serverErrorCode(e)) {
          case 'empty_slip':
            throw EmptySlipFailure(
              message ?? 'Dropping those leaves nothing to convert.',
            );
          case 'outcomes_unavailable':
            throw OutcomesUnavailableFailure(
              message ??
                  'Some selections went off while the code was being converted. Try again.',
            );
          case 'conflicting_selections':
            throw ConflictingSelectionsFailure(
              message ??
                  'The kept legs include two on the same match. Drop one of them and try again.',
            );
        }
      }
      throw _mapTransportFailure(e);
    }
  }

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

  String? _serverErrorCode(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['error'] is String) {
      return data['error'] as String;
    }
    return null;
  }
}

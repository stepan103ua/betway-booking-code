import 'package:dio/dio.dart';

import '../../../../core/failure.dart';
import '../../../../models/events_page.dart';
import '../../../../models/fixture.dart';
import '../../../../models/sport.dart';
import '../../domain/repositories/create_repository.dart';
import '../datasources/create_remote_data_source.dart';

/// Translates transport-level errors into a [Failure] the cubits can
/// pattern-match on — the one job this layer has (`docs/mobile.md` §5). Never
/// sees `dio` types past its own `catch`.
class CreateRepositoryImpl implements CreateRepository {
  CreateRepositoryImpl(this._remote);
  final CreateRemoteDataSource _remote;

  @override
  Future<List<Sport>> sports() async {
    try {
      return await _remote.sports();
    } on DioException catch (e) {
      throw _mapTransportFailure(e);
    }
  }

  @override
  Future<EventsPage> events({
    required String sport,
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      return await _remote.events(sport: sport, limit: limit, skip: skip);
    } on DioException catch (e) {
      throw _mapTransportFailure(e);
    }
  }

  @override
  Future<List<Market>> eventMarkets(String eventId) async {
    try {
      return await _remote.eventMarkets(eventId);
    } on DioException catch (e) {
      // A 404 here means "no markets for this event" specifically — the
      // service turns upstream's empty-arrays-for-an-unknown-event into a
      // 404 on purpose (`docs/backend-api.md` §2).
      if (e.response?.statusCode == 404) {
        throw NotFoundFailure(
          _serverMessage(e) ?? 'No markets for this event.',
        );
      }
      throw _mapTransportFailure(e);
    }
  }

  @override
  Future<String> create(List<String> outcomeIds) async {
    try {
      return await _remote.create(outcomeIds);
    } on DioException catch (e) {
      // The two 400s a client can act on are told apart by the `error` field,
      // not the status — `packages/contracts` is explicit that `error` is the
      // stable thing to branch on. `invalid_request` and anything else fall
      // through to the shared mapper as an UnknownFailure.
      if (e.response?.statusCode == 400) {
        final message = _serverMessage(e);
        switch (_serverErrorCode(e)) {
          case 'too_many_outcomes':
            throw TooManyOutcomesFailure(
              message ?? 'A slip can hold at most 20 selections.',
            );
          case 'outcomes_unavailable':
            throw OutcomesUnavailableFailure(
              message ??
                  'Those selections are no longer available. Refresh and pick again.',
            );
        }
      }
      throw _mapTransportFailure(e);
    }
  }

  /// No response at all — `connectionTimeout`, `receiveTimeout`,
  /// `connectionError` — is [NetworkFailure]. Any answered non-2xx we did not
  /// special-case above becomes [UnknownFailure], carrying the server's own
  /// `ApiError.message` (written to be shown verbatim) over `dio`'s generic
  /// "Http status error".
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

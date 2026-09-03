import 'package:dio/dio.dart';

import '../../../../models/events_page.dart';
import '../../../../models/fixture.dart';
import '../../../../models/sport.dart';

/// The only file in this feature that imports `dio` or names an endpoint path
/// (`docs/mobile.md` §6) — raw JSON in, a model's `fromJson` out. Throws the
/// raw [DioException] on anything but `2xx`; turning that into a [Failure] is
/// `CreateRepositoryImpl`'s job.
class CreateRemoteDataSource {
  CreateRemoteDataSource(this._dio);
  final Dio _dio;

  /// `GET /api/sports` (`docs/backend-api.md` §2). Response is `{ sports: [...] }`.
  Future<List<Sport>> sports() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/sports');
    final list = response.data!['sports'] as List<dynamic>;
    return list
        .map((e) => Sport.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  /// `GET /api/events?sport=&limit=&skip=` (`docs/backend-api.md` §2). `limit`
  /// and `skip` mirror the endpoint's bounds (limit ≤ 50, skip ≤ 1000).
  Future<EventsPage> events({
    required String sport,
    int limit = 20,
    int skip = 0,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/events',
      queryParameters: {'sport': sport, 'limit': limit, 'skip': skip},
    );
    return EventsPage.fromJson(response.data!);
  }

  /// `GET /api/events/:eventId/markets` (`docs/backend-api.md` §2). Response is
  /// `{ eventId, markets: [...] }`; a `404` (unknown event / nothing priced)
  /// arrives here as a [DioException].
  Future<List<Market>> eventMarkets(String eventId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/events/$eventId/markets',
    );
    final list = response.data!['markets'] as List<dynamic>;
    return list
        .map((e) => Market.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  /// `POST /api/booking-codes` (`docs/backend-api.md` §1). Response is
  /// `{ bookingCode }` — the endpoint already reads the code back and checks
  /// it upstream, but returns only the string, so that is all this returns.
  Future<String> create(List<String> outcomeIds) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/booking-codes',
      data: {'outcomeIds': outcomeIds},
    );
    return response.data!['bookingCode'] as String;
  }
}

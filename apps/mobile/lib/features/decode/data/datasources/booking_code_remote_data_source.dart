import 'package:dio/dio.dart';

import '../../../../models/popular_codes_page.dart';
import '../../../../models/slip.dart';

/// The only file in this feature that imports `dio` or knows an endpoint
/// path (`docs/mobile.md` §6) — raw JSON in, a model's `fromJson` out. A
/// route or payload-shape change in `apps/api` changes this file and
/// nothing else.
class BookingCodeRemoteDataSource {
  BookingCodeRemoteDataSource(this._dio);
  final Dio _dio;

  /// `POST /api/booking-codes/resolve` (`docs/backend-api.md` §1). Throws
  /// the raw [DioException] on anything but `200` — mapping that into a
  /// [Failure] is `BookingCodeRepositoryImpl`'s job, not this one's.
  Future<Slip> resolve(String code) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/booking-codes/resolve',
      data: {'code': code},
    );
    return Slip.fromJson(response.data!);
  }

  /// `GET /api/booking-codes/popular` (`docs/backend-api.md` §1).
  Future<PopularCodesPage> popular({int limit = 6, int skip = 0}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/booking-codes/popular',
      queryParameters: {'limit': limit, 'skip': skip},
    );
    return PopularCodesPage.fromJson(response.data!);
  }
}

import 'package:dio/dio.dart';

import '../../../../models/convert_result.dart';
import '../../../../models/slip.dart';

/// The only file in this feature that imports `dio` or names an endpoint path
/// (`docs/mobile.md` §6). Convert is a two-step flow client-side: `resolve` to
/// show the user the slip and its dead legs, then `convert` to reissue it.
/// The path duplication with the Decode feature's data source is the tax
/// feature-first charges for not letting one feature import another's layers
/// (`docs/mobile.md` §9).
class ConvertRemoteDataSource {
  ConvertRemoteDataSource(this._dio);
  final Dio _dio;

  /// `POST /api/booking-codes/resolve` (`docs/backend-api.md` §1).
  Future<Slip> resolve(String code) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/booking-codes/resolve',
      data: {'code': code},
    );
    return Slip.fromJson(response.data!);
  }

  /// `POST /api/booking-codes/convert` (`docs/backend-api.md` §1). The server
  /// composes `resolve → filter → encode`; the client sends only the legs it
  /// wants gone on top of the dead ones it drops automatically.
  Future<ConvertResult> convert(
    String code,
    List<String> dropOutcomeIds,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/booking-codes/convert',
      data: {'code': code, 'dropOutcomeIds': dropOutcomeIds},
    );
    return ConvertResult.fromJson(response.data!);
  }
}

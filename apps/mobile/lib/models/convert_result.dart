import 'package:freezed_annotation/freezed_annotation.dart';

import 'selection.dart';

part 'convert_result.freezed.dart';
part 'convert_result.g.dart';

/// `POST /api/booking-codes/convert`'s response (`docs/backend-api.md` §1).
///
/// The contract types this as `Slip & { previousBookingCode, previousTotalOdds,
/// droppedCount }` — an intersection Dart can't express, so the `Slip` fields
/// are inlined here rather than nested. `selections`, `totalOdds` and
/// `bookingCode` describe the **new** code; the `previous*` fields are the
/// before side of the diff. Both `expiresAt` and `usageCount` are always null,
/// same as every other `Slip` outside `/popular`.
@freezed
abstract class ConvertResult with _$ConvertResult {
  const factory ConvertResult({
    required String bookingCode,
    required double totalOdds,
    required String? expiresAt,
    required int? usageCount,
    required List<Selection> selections,
    required String previousBookingCode,
    required double previousTotalOdds,
    required int droppedCount,
  }) = _ConvertResult;

  factory ConvertResult.fromJson(Map<String, dynamic> json) =>
      _$ConvertResultFromJson(json);
}

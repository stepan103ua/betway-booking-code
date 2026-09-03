import 'package:freezed_annotation/freezed_annotation.dart';

import 'selection.dart';

part 'slip.freezed.dart';
part 'slip.g.dart';

/// A booking code and everything inside it. Mirrors `docs/backend-api.md`
/// §0's `Slip` field for field.
///
/// `expiresAt` and `usageCount` are nullable because `resolve` always
/// returns them `null` — `FindBookABet` reports what a slip holds, not how
/// long it lives or how many people have loaded it (`docs/backend-api.md`
/// §1). A UI branch that expects either to be populated from a decoded slip
/// is building for data this endpoint cannot produce.
@freezed
abstract class Slip with _$Slip {
  const factory Slip({
    required String bookingCode,
    required double totalOdds,
    required String? expiresAt,
    required int? usageCount,
    required List<Selection> selections,
  }) = _Slip;

  factory Slip.fromJson(Map<String, dynamic> json) => _$SlipFromJson(json);
}

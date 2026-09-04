// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Slip _$SlipFromJson(Map<String, dynamic> json) => _Slip(
  bookingCode: json['bookingCode'] as String,
  totalOdds: (json['totalOdds'] as num).toDouble(),
  expiresAt: json['expiresAt'] as String?,
  usageCount: (json['usageCount'] as num?)?.toInt(),
  selections: (json['selections'] as List<dynamic>)
      .map((e) => Selection.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SlipToJson(_Slip instance) => <String, dynamic>{
  'bookingCode': instance.bookingCode,
  'totalOdds': instance.totalOdds,
  'expiresAt': instance.expiresAt,
  'usageCount': instance.usageCount,
  'selections': instance.selections,
};

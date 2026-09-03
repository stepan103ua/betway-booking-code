// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'convert_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ConvertResult _$ConvertResultFromJson(Map<String, dynamic> json) =>
    _ConvertResult(
      bookingCode: json['bookingCode'] as String,
      totalOdds: (json['totalOdds'] as num).toDouble(),
      expiresAt: json['expiresAt'] as String?,
      usageCount: (json['usageCount'] as num?)?.toInt(),
      selections: (json['selections'] as List<dynamic>)
          .map((e) => Selection.fromJson(e as Map<String, dynamic>))
          .toList(),
      previousBookingCode: json['previousBookingCode'] as String,
      previousTotalOdds: (json['previousTotalOdds'] as num).toDouble(),
      droppedCount: (json['droppedCount'] as num).toInt(),
    );

Map<String, dynamic> _$ConvertResultToJson(_ConvertResult instance) =>
    <String, dynamic>{
      'bookingCode': instance.bookingCode,
      'totalOdds': instance.totalOdds,
      'expiresAt': instance.expiresAt,
      'usageCount': instance.usageCount,
      'selections': instance.selections,
      'previousBookingCode': instance.previousBookingCode,
      'previousTotalOdds': instance.previousTotalOdds,
      'droppedCount': instance.droppedCount,
    };

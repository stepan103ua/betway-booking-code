// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'popular_codes_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PopularCodesPage _$PopularCodesPageFromJson(Map<String, dynamic> json) =>
    _PopularCodesPage(
      codes: (json['codes'] as List<dynamic>)
          .map((e) => Slip.fromJson(e as Map<String, dynamic>))
          .toList(),
      skip: (json['skip'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      hasMore: json['hasMore'] as bool,
    );

Map<String, dynamic> _$PopularCodesPageToJson(_PopularCodesPage instance) =>
    <String, dynamic>{
      'codes': instance.codes,
      'skip': instance.skip,
      'limit': instance.limit,
      'total': instance.total,
      'hasMore': instance.hasMore,
    };

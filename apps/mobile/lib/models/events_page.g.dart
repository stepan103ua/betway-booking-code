// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'events_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EventsPage _$EventsPageFromJson(Map<String, dynamic> json) => _EventsPage(
  events: (json['events'] as List<dynamic>)
      .map((e) => Fixture.fromJson(e as Map<String, dynamic>))
      .toList(),
  skip: (json['skip'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
  hasMore: json['hasMore'] as bool,
);

Map<String, dynamic> _$EventsPageToJson(_EventsPage instance) =>
    <String, dynamic>{
      'events': instance.events,
      'skip': instance.skip,
      'limit': instance.limit,
      'hasMore': instance.hasMore,
    };

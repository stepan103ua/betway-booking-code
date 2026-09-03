// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Selection _$SelectionFromJson(Map<String, dynamic> json) => _Selection(
  outcomeId: json['outcomeId'] as String,
  marketName: json['marketName'] as String,
  outcomeName: json['outcomeName'] as String,
  eventName: json['eventName'] as String,
  league: json['league'] as String,
  kickoffAt: json['kickoffAt'] as String,
  odds: (json['odds'] as num).toDouble(),
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$SelectionToJson(_Selection instance) =>
    <String, dynamic>{
      'outcomeId': instance.outcomeId,
      'marketName': instance.marketName,
      'outcomeName': instance.outcomeName,
      'eventName': instance.eventName,
      'league': instance.league,
      'kickoffAt': instance.kickoffAt,
      'odds': instance.odds,
      'isActive': instance.isActive,
    };

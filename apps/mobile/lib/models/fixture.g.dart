// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fixture.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Fixture _$FixtureFromJson(Map<String, dynamic> json) => _Fixture(
  eventId: json['eventId'] as String,
  name: json['name'] as String,
  league: json['league'] as String,
  kickoffAt: json['kickoffAt'] as String,
  markets: (json['markets'] as List<dynamic>)
      .map((e) => Market.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$FixtureToJson(_Fixture instance) => <String, dynamic>{
  'eventId': instance.eventId,
  'name': instance.name,
  'league': instance.league,
  'kickoffAt': instance.kickoffAt,
  'markets': instance.markets,
};

_Market _$MarketFromJson(Map<String, dynamic> json) => _Market(
  marketId: json['marketId'] as String,
  name: json['name'] as String,
  type: json['type'] as String,
  outcomes: (json['outcomes'] as List<dynamic>)
      .map((e) => MarketOutcome.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MarketToJson(_Market instance) => <String, dynamic>{
  'marketId': instance.marketId,
  'name': instance.name,
  'type': instance.type,
  'outcomes': instance.outcomes,
};

_MarketOutcome _$MarketOutcomeFromJson(Map<String, dynamic> json) =>
    _MarketOutcome(
      outcomeId: json['outcomeId'] as String,
      label: json['label'] as String,
      odds: (json['odds'] as num).toDouble(),
    );

Map<String, dynamic> _$MarketOutcomeToJson(_MarketOutcome instance) =>
    <String, dynamic>{
      'outcomeId': instance.outcomeId,
      'label': instance.label,
      'odds': instance.odds,
    };

import 'package:freezed_annotation/freezed_annotation.dart';

part 'fixture.freezed.dart';
part 'fixture.g.dart';

/// An upcoming event with its markets inline. Mirrors `packages/contracts`'
/// `Fixture` / `Market` / `MarketOutcome` field for field (`docs/backend-api.md`
/// §0) — the same rule `lib/models/slip.dart` follows, since nothing in Dart
/// checks these against the API the way `packages/contracts` does for the web.
///
/// `markets` carries exactly one entry (the 1X2 market) from `GET /api/events`
/// and the full set from `GET /api/events/:eventId/markets` — a list rather
/// than a keyed object because a market's name is data, not schema, and one
/// event can carry the same market type twice (`docs/backend-api.md` §0).
@freezed
abstract class Fixture with _$Fixture {
  const factory Fixture({
    required String eventId,
    required String name,
    required String league,
    required String kickoffAt,
    required List<Market> markets,
  }) = _Fixture;

  factory Fixture.fromJson(Map<String, dynamic> json) =>
      _$FixtureFromJson(json);
}

@freezed
abstract class Market with _$Market {
  const factory Market({
    required String marketId,

    /// Display-ready and fully qualified: `"1X2"`, `"Total (6.5)"`.
    required String name,

    /// Stable machine key — branch on this, never on `name` or the numeric
    /// part of an id. Not unique within an event (`docs/backend-api.md` §0).
    required String type,
    required List<MarketOutcome> outcomes,
  }) = _Market;

  factory Market.fromJson(Map<String, dynamic> json) => _$MarketFromJson(json);
}

@freezed
abstract class MarketOutcome with _$MarketOutcome {
  const factory MarketOutcome({
    required String outcomeId,

    /// What upstream calls this outcome: a team name, `"Draw"`, `"Over"`.
    required String label,

    /// Decimal odds — typed `double`, not inferred, for the same reason
    /// `Selection.odds` is (`lib/models/selection.dart`): `jsonDecode` gives
    /// `int` for a whole-number price and only a declared `double` makes the
    /// generated `fromJson` coerce it.
    required double odds,
  }) = _MarketOutcome;

  factory MarketOutcome.fromJson(Map<String, dynamic> json) =>
      _$MarketOutcomeFromJson(json);
}

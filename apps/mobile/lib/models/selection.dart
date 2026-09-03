import 'package:freezed_annotation/freezed_annotation.dart';

part 'selection.freezed.dart';
part 'selection.g.dart';

/// One leg of a `Slip`. Mirrors `docs/backend-api.md` §0 field for field —
/// name, type and nullability all have to match, because nothing in this
/// language checks it against the API the way `packages/contracts` checks
/// it for `apps/web`.
///
/// `odds` is typed `double` on purpose, not left to type inference: without
/// it `json_serializable` would trust whatever `num` subtype the JSON
/// happens to decode to, and `jsonDecode` gives `int` for a whole-number
/// price (a real possibility — `1.0`, `2.0`). Declaring `double` makes the
/// generated `fromJson` call `(json['odds'] as num).toDouble()`, which
/// accepts either.
@freezed
abstract class Selection with _$Selection {
  const factory Selection({
    required String outcomeId,
    required String marketName,
    required String outcomeName,
    required String eventName,
    required String league,
    required String kickoffAt,
    required double odds,
    required bool isActive,
  }) = _Selection;

  factory Selection.fromJson(Map<String, dynamic> json) =>
      _$SelectionFromJson(json);
}

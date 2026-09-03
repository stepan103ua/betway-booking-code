import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/failure.dart';
import '../../../../models/convert_result.dart';
import '../../../../models/selection.dart';
import '../../../../models/slip.dart';

part 'convert_state.freezed.dart';

/// Three phases: enter a code, pick what to drop, see the new code.
///
/// [ConvertReady] is a form like `CreateReady` — `converting`, `convertError`
/// and `result` are overlapping facts about one loaded slip, not separate
/// screens. `result != null` flips the UI to the after view; `original` stays
/// alongside it because the diff needs the before side.
///
/// The user's `dropOutcomeIds` holds only **live** legs they chose to drop.
/// Dead legs (`isActive: false`) are dropped by the server regardless and are
/// shown separately — putting them in the set would just duplicate what the
/// backend already does.
@freezed
sealed class ConvertState with _$ConvertState {
  const factory ConvertState.initial({Failure? codeError}) = ConvertInitial;

  const factory ConvertState.resolving() = ConvertResolving;

  const factory ConvertState.ready({
    required Slip original,
    @Default(<String>{}) Set<String> dropOutcomeIds,
    @Default(false) bool converting,
    Failure? convertError,
    ConvertResult? result,
  }) = ConvertReady;
}

extension ConvertReadyX on ConvertReady {
  /// Legs the code can no longer bet — always dropped, not toggleable.
  Iterable<Selection> get deadLegs =>
      original.selections.where((s) => !s.isActive);

  /// Legs that would end up in the new code: live, and not in the drop set.
  List<Selection> get keptLegs => original.selections
      .where((s) => s.isActive && !dropOutcomeIds.contains(s.outcomeId))
      .toList();

  /// Everything that won't survive — dead legs plus the user's drops.
  int get droppedCount => original.selections.length - keptLegs.length;

  /// Product of the kept legs' current odds. A preview only — the real total
  /// is set when `/convert` re-encodes, and prices drift in between
  /// (`docs/betway-api.md` §3).
  double get previewOdds =>
      keptLegs.fold(1, (running, leg) => running * leg.odds);

  /// At least one leg has to survive — the server answers `empty_slip`
  /// otherwise, and there is no honest code for "nothing left".
  bool get canConvert => keptLegs.isNotEmpty;

  bool isDropped(String outcomeId) => dropOutcomeIds.contains(outcomeId);
}

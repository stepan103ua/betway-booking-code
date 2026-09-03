import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/failure.dart';
import '../../../../models/sport.dart';
import '../model/draft_pick.dart';

part 'create_state.freezed.dart';

/// Two phases the picker moves through: fetching the sport list once, then a
/// long-lived [CreateReady] the user builds a slip in. `sealed` keeps
/// `create_screen.dart`'s `switch` exhaustive.
///
/// [CreateReady] is a form, not a sequence of sub-states, so it is one record
/// rather than a union — `generating`, `generateError` and `createdCode` are
/// overlapping facts about the same draft, not mutually exclusive screens.
/// `createdCode != null` is the only thing that flips the UI to the success
/// view, and `picks` is kept alongside it so that view can recap what was
/// picked (`POST /api/booking-codes` returns only the code).
@freezed
sealed class CreateState with _$CreateState {
  const factory CreateState.loadingSports() = CreateLoadingSports;

  const factory CreateState.sportsError(Failure failure) = CreateSportsError;

  const factory CreateState.ready({
    required List<Sport> sports,
    required Sport selectedSport,
    @Default(<DraftPick>[]) List<DraftPick> picks,
    @Default(false) bool generating,
    Failure? generateError,
    String? createdCode,
  }) = CreateReady;
}

/// The cap `POST /api/booking-codes` enforces server-side (`docs/backend-api.md`
/// §1). Held here too so the picker can stop adding at 20 rather than letting
/// the 21st leg round-trip only to come back as `too_many_outcomes`.
const int kMaxDraftPicks = 20;

extension CreateReadyX on CreateReady {
  bool get isFull => picks.length >= kMaxDraftPicks;

  /// Product of every leg's odds — the same computation the backend does for
  /// `Slip.totalOdds`. `1.0` for an empty draft.
  double get totalOdds => picks.fold(1, (running, pick) => running * pick.odds);
}

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/failure.dart';
import '../../../../models/sport.dart';
import '../../domain/repositories/create_repository.dart';
import '../model/draft_pick.dart';
import 'create_state.dart';

/// Owns the sport list, the selected sport, the draft slip, and the generate
/// call. `Cubit`, not `Bloc`, deliberately — `docs/mobile.md` §4 floats `Bloc`
/// for this picker, but methods emitting states keep it consistent with
/// `SlipCubit`/`PopularCodesCubit` and the app carries no event hierarchy
/// anywhere else. The fixture list and the per-event market list are separate
/// cubits (`EventsCubit`, `EventMarketsCubit`); each of the three has one job.
class CreateCubit extends Cubit<CreateState> {
  CreateCubit(this._repository) : super(const CreateState.loadingSports());
  final CreateRepository _repository;

  Future<void> load() async {
    emit(const CreateState.loadingSports());
    try {
      final sports = await _repository.sports();
      if (sports.isEmpty) {
        emit(
          const CreateState.sportsError(
            UnknownFailure('No sports are available right now.'),
          ),
        );
        return;
      }
      emit(CreateState.ready(sports: sports, selectedSport: sports.first));
    } on Failure catch (f) {
      emit(CreateState.sportsError(f));
    }
  }

  void selectSport(Sport sport) {
    final s = state;
    if (s is! CreateReady || s.selectedSport.id == sport.id) return;
    // Picks and any result belong to the sport they were made under — a fresh
    // sport starts a fresh slip.
    emit(CreateState.ready(sports: s.sports, selectedSport: sport));
  }

  /// Add the leg if it is new and there is room, remove it if it is already
  /// in the draft. A remove always succeeds, even at the cap.
  void toggleOutcome(DraftPick pick) {
    final s = state;
    if (s is! CreateReady || s.createdCode != null) return;

    final without = s.picks
        .where((p) => p.outcomeId != pick.outcomeId)
        .toList();
    final wasThere = without.length != s.picks.length;

    if (wasThere) {
      emit(s.copyWith(picks: without, generateError: null));
      return;
    }
    if (s.isFull) return; // UI shows the cap hint; ignore the add
    // One pick per match: a booking code is a plain accumulator, so two legs on
    // one event conflict (`docs/betway-api.md` §3). The picker disables the
    // other outcomes in an event that already has a leg; this guards the case
    // the UI misses.
    if (s.picks.any((p) => p.eventId == pick.eventId)) return;
    emit(s.copyWith(picks: [...s.picks, pick], generateError: null));
  }

  void clearDraft() {
    final s = state;
    if (s is! CreateReady) return;
    emit(s.copyWith(picks: const [], generateError: null));
  }

  Future<void> generate() async {
    final s = state;
    if (s is! CreateReady || s.picks.isEmpty || s.generating) return;

    emit(s.copyWith(generating: true, generateError: null));
    try {
      final code = await _repository.create(
        s.picks.map((p) => p.outcomeId).toList(growable: false),
      );
      // Re-read the latest state: nothing else mutates it during the await,
      // but reading `s` keeps this honest if that ever changes.
      final now = state;
      if (now is CreateReady) {
        emit(now.copyWith(generating: false, createdCode: code));
      }
    } on Failure catch (f) {
      final now = state;
      if (now is CreateReady) {
        emit(now.copyWith(generating: false, generateError: f));
      }
    }
  }

  /// Back to an empty draft on the same sport — the "Start over" action on the
  /// success view.
  void startOver() {
    final s = state;
    if (s is! CreateReady) return;
    emit(CreateState.ready(sports: s.sports, selectedSport: s.selectedSport));
  }
}

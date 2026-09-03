import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/failure.dart';
import '../../domain/repositories/convert_repository.dart';
import 'convert_state.dart';

/// Owns the loaded slip, the set of live legs to drop, and the convert call.
/// `Cubit`, consistent with the rest of the app (`docs/mobile.md` §4) — Convert
/// has a few triggers (resolve, toggle a drop, convert) but no transition fires
/// from more than one place, so an `Event` hierarchy would not earn its keep.
class ConvertCubit extends Cubit<ConvertState> {
  ConvertCubit(this._repository) : super(const ConvertState.initial());
  final ConvertRepository _repository;

  Future<void> resolve(String code) async {
    emit(const ConvertState.resolving());
    try {
      emit(ConvertState.ready(original: await _repository.resolve(code)));
    } on Failure catch (f) {
      // Back to the input with the failure attached — the same shape Decode
      // uses. Nothing is loaded yet, so there is no context to preserve.
      emit(ConvertState.initial(codeError: f));
    }
  }

  /// Toggle a **live** leg in or out of the drop set.
  void toggleDrop(String outcomeId) {
    final s = state;
    if (s is! ConvertReady || s.result != null) return;

    final next = {...s.dropOutcomeIds};
    if (!next.remove(outcomeId)) next.add(outcomeId);
    emit(s.copyWith(dropOutcomeIds: next, convertError: null));
  }

  Future<void> convert() async {
    final s = state;
    if (s is! ConvertReady || !s.canConvert || s.converting) return;

    emit(s.copyWith(converting: true, convertError: null));
    try {
      final result = await _repository.convert(
        s.original.bookingCode,
        s.dropOutcomeIds.toList(growable: false),
      );
      final now = state;
      if (now is ConvertReady) {
        emit(now.copyWith(converting: false, result: result));
      }
    } on Failure catch (f) {
      final now = state;
      if (now is ConvertReady) {
        emit(now.copyWith(converting: false, convertError: f));
      }
    }
  }

  /// Back to an empty code input — the "Convert another" action, and the
  /// "Clear" on a code error.
  void reset() => emit(const ConvertState.initial());
}

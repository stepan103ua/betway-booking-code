import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/failure.dart';
import '../../domain/repositories/booking_code_repository.dart';
import 'slip_state.dart';

/// One trigger — "code submitted" — so `Cubit` over `Bloc` per
/// `docs/mobile.md` §4: a `Bloc` here would mean a one-member `Event`
/// hierarchy for a single event.
///
/// Depends on [BookingCodeRepository], the interface, never
/// `BookingCodeRepositoryImpl` — that's what makes testing this with a fake
/// repository possible without a mocked `dio` anywhere near it.
class SlipCubit extends Cubit<SlipState> {
  SlipCubit(this._repository) : super(const SlipState.initial());
  final BookingCodeRepository _repository;

  Future<void> resolve(String code) async {
    emit(const SlipState.loading());
    try {
      final slip = await _repository.resolve(code);
      // The Decode tab can be swapped out (and this Cubit closed) while the
      // request is in flight — a real move on a slow connection. `emit` after
      // `close()` throws, so bail before every post-`await` emit.
      if (isClosed) return;
      emit(SlipState.loaded(slip));
    } on Failure catch (f) {
      if (isClosed) return;
      emit(SlipState.error(f));
    }
  }

  /// Back to [SlipState.initial] — the "Clear" action on an error, and
  /// what a fresh code paste should land on rather than re-showing the
  /// previous result while the next `resolve` is in flight.
  void reset() => emit(const SlipState.initial());
}

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/failure.dart';
import '../../domain/repositories/booking_code_repository.dart';
import 'popular_codes_state.dart';

/// Backs the Decode screen's "try a code" list — real live codes from
/// `GET /api/booking-codes/popular`, not a hand-picked example list.
/// `load()` runs once, from the `BlocProvider` that creates this (see
/// `decode_screen.dart`); there's no user action that would trigger a
/// second call today.
class PopularCodesCubit extends Cubit<PopularCodesState> {
  PopularCodesCubit(this._repository)
    : super(const PopularCodesState.loading());
  final BookingCodeRepository _repository;

  Future<void> load() async {
    emit(const PopularCodesState.loading());
    try {
      final page = await _repository.popular(limit: 3);
      emit(PopularCodesState.loaded(page.codes));
    } on Failure catch (f) {
      emit(PopularCodesState.error(f));
    }
  }
}

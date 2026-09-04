import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/failure.dart';
import '../../../../models/slip.dart';
import '../../domain/repositories/booking_code_repository.dart';
import 'popular_codes_state.dart';

/// Backs the Decode screen's "try a code" list — real live codes from
/// `GET /api/booking-codes/popular`, not a hand-picked example list.
/// `load()` runs once, from the `BlocProvider` that creates this (see
/// `decode_screen.dart`); `loadMore()` appends the next page behind the
/// list's "Load more" control. Same pattern as `EventsCubit`.
class PopularCodesCubit extends Cubit<PopularCodesState> {
  PopularCodesCubit(this._repository)
    : super(const PopularCodesState.loading());
  final BookingCodeRepository _repository;

  static const _pageLimit = 6;

  Future<void> load() async {
    emit(const PopularCodesState.loading());
    try {
      final page = await _repository.popular(limit: _pageLimit, skip: 0);
      if (isClosed) return; // tab swapped out mid-request; `emit` would throw
      emit(
        PopularCodesState.loaded(
          codes: page.codes,
          total: page.total,
          hasMore: page.hasMore,
          nextSkip: page.skip + page.limit,
        ),
      );
    } on Failure catch (f) {
      if (isClosed) return;
      emit(PopularCodesState.error(f));
    }
  }

  Future<void> loadMore() async {
    final s = state;
    if (s is! PopularCodesLoaded || !s.hasMore || s.loadingMore) return;

    emit(s.copyWith(loadingMore: true, loadMoreError: null));
    try {
      final page = await _repository.popular(
        limit: _pageLimit,
        skip: s.nextSkip,
      );
      if (isClosed) return;
      emit(
        PopularCodesState.loaded(
          codes: _merge(s.codes, page.codes),
          total: page.total,
          hasMore: page.hasMore,
          nextSkip: page.skip + page.limit,
        ),
      );
    } on Failure catch (f) {
      if (isClosed) return;
      // Keep the list already on screen; stop the spinner and say why nothing
      // new appeared, so the control isn't a dead end on a flaky connection.
      emit(s.copyWith(loadingMore: false, loadMoreError: f));
    }
  }

  /// Append, skipping any code already shown — the catalogue reorders between
  /// requests, so a page can repeat a slip that a "load more" already added.
  static List<Slip> _merge(List<Slip> current, List<Slip> next) {
    final seen = {for (final s in current) s.bookingCode};
    return [...current, ...next.where((s) => seen.add(s.bookingCode))];
  }
}

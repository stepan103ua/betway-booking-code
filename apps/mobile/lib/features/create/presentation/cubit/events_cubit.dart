import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/failure.dart';
import '../../domain/repositories/create_repository.dart';
import 'events_state.dart';

/// The upcoming-fixtures list for one sport. Separate from [CreateCubit]
/// because it has its own trigger set (initial load, load-more) and its own
/// failure surface — a page fetch can fail without the whole Create screen
/// being unusable.
class EventsCubit extends Cubit<EventsState> {
  EventsCubit(this._repository) : super(const EventsState.loading());
  final CreateRepository _repository;

  static const _pageLimit = 20;

  String? _sportId;

  Future<void> load(String sportId) async {
    _sportId = sportId;
    emit(const EventsState.loading());
    try {
      final page = await _repository.events(
        sport: sportId,
        limit: _pageLimit,
        skip: 0,
      );
      if (isClosed) return; // Create tab left mid-request
      emit(
        EventsState.loaded(
          events: page.events,
          hasMore: page.hasMore,
          nextSkip: page.skip + page.limit,
        ),
      );
    } on Failure catch (f) {
      if (isClosed) return;
      emit(EventsState.error(f));
    }
  }

  Future<void> loadMore() async {
    final s = state;
    final sportId = _sportId;
    if (s is! EventsLoaded || !s.hasMore || s.loadingMore || sportId == null) {
      return;
    }

    emit(s.copyWith(loadingMore: true, loadMoreError: null));
    try {
      final page = await _repository.events(
        sport: sportId,
        limit: _pageLimit,
        skip: s.nextSkip,
      );
      if (isClosed) return; // Create tab left mid-request
      emit(
        EventsState.loaded(
          events: [...s.events, ...page.events],
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
}

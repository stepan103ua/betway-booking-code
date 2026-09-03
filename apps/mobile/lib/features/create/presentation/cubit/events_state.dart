import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/failure.dart';
import '../../../../models/fixture.dart';

part 'events_state.freezed.dart';

/// The paginated fixture list for the selected sport. Same three-state shape
/// as the app's other list cubits, plus a `loadingMore` flag on [EventsLoaded]
/// so "load more" spins without replacing the list already on screen.
///
/// A failed *initial* load is [EventsError] — the whole list is unusable. A
/// failed *load-more* keeps [EventsLoaded] (the list already on screen stays)
/// and surfaces `loadMoreError` next to the control, so the user sees why
/// nothing new appeared rather than a spinner that just stops.
///
/// Paging is driven by `hasMore` (upstream's own end-of-list flag), never by
/// `events.length` — this feed reports no total and a page can come back short
/// while more remain (`docs/backend-api.md` §2).
@freezed
sealed class EventsState with _$EventsState {
  const factory EventsState.loading() = EventsLoading;

  const factory EventsState.loaded({
    required List<Fixture> events,
    required bool hasMore,
    required int nextSkip,
    @Default(false) bool loadingMore,
    Failure? loadMoreError,
  }) = EventsLoaded;

  const factory EventsState.error(Failure failure) = EventsError;
}

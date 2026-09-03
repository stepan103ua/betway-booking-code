import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/failure.dart';
import '../../../../models/fixture.dart';

part 'events_state.freezed.dart';

/// The paginated fixture list for the selected sport. Same three-state shape
/// as the app's other list cubits, plus a `loadingMore` flag on [EventsLoaded]
/// so "load more" spins without replacing the list already on screen.
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
  }) = EventsLoaded;

  const factory EventsState.error(Failure failure) = EventsError;
}

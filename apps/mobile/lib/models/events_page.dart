import 'package:freezed_annotation/freezed_annotation.dart';

import 'fixture.dart';

part 'events_page.freezed.dart';
part 'events_page.g.dart';

/// `GET /api/events`'s response (`docs/backend-api.md` §2). Mirrors
/// `packages/contracts`' `EventsPage`.
///
/// This feed reports **no total** — unlike `/api/booking-codes/popular`, which
/// carries one. `hasMore` is upstream's own end-of-list flag, so the Create
/// screen pages on `hasMore`, never on `events.length` (a page can come back
/// short — every market suspended — while more pages remain).
@freezed
abstract class EventsPage with _$EventsPage {
  const factory EventsPage({
    required List<Fixture> events,
    required int skip,
    required int limit,
    required bool hasMore,
  }) = _EventsPage;

  factory EventsPage.fromJson(Map<String, dynamic> json) =>
      _$EventsPageFromJson(json);
}

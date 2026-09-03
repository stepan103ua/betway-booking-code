import 'package:booking_code/core/failure.dart';
import 'package:booking_code/features/create/domain/repositories/create_repository.dart';
import 'package:booking_code/features/create/presentation/cubit/events_cubit.dart';
import 'package:booking_code/features/create/presentation/cubit/events_state.dart';
import 'package:booking_code/models/events_page.dart';
import 'package:booking_code/models/fixture.dart';
import 'package:booking_code/models/sport.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCreateRepository implements CreateRepository {
  _FakeCreateRepository(this._pages);
  final List<EventsPage> _pages;
  int _call = 0;
  Object? error;

  @override
  Future<EventsPage> events({
    required String sport,
    int limit = 20,
    int skip = 0,
  }) async {
    if (error != null) throw error!;
    return _pages[_call++];
  }

  @override
  Future<List<Sport>> sports() => throw UnimplementedError();
  @override
  Future<List<Market>> eventMarkets(String eventId) =>
      throw UnimplementedError();
  @override
  Future<String> create(List<String> outcomeIds) => throw UnimplementedError();
}

Fixture _event(String id) => Fixture(
  eventId: id,
  name: 'Event $id',
  league: 'League',
  kickoffAt: '2026-09-03T18:00:00Z',
  markets: const [],
);

EventsPage _page(
  List<String> ids, {
  required int skip,
  required bool hasMore,
}) => EventsPage(
  events: ids.map(_event).toList(),
  skip: skip,
  limit: 20,
  hasMore: hasMore,
);

void main() {
  blocTest<EventsCubit, EventsState>(
    'load emits [loading, loaded] and carries hasMore',
    build: () => EventsCubit(
      _FakeCreateRepository([
        _page(['1', '2'], skip: 0, hasMore: true),
      ]),
    ),
    act: (cubit) => cubit.load('soccer'),
    expect: () => [
      const EventsState.loading(),
      isA<EventsLoaded>()
          .having((s) => s.events.length, 'events', 2)
          .having((s) => s.hasMore, 'hasMore', true)
          .having((s) => s.nextSkip, 'nextSkip', 20),
    ],
  );

  blocTest<EventsCubit, EventsState>(
    'loadMore appends the next page',
    build: () => EventsCubit(
      _FakeCreateRepository([
        _page(['1', '2'], skip: 0, hasMore: true),
        _page(['3'], skip: 20, hasMore: false),
      ]),
    ),
    act: (cubit) async {
      await cubit.load('soccer');
      await cubit.loadMore();
    },
    expect: () => [
      const EventsState.loading(),
      isA<EventsLoaded>().having((s) => s.events.length, 'events', 2),
      isA<EventsLoaded>().having((s) => s.loadingMore, 'loadingMore', true),
      isA<EventsLoaded>()
          .having((s) => s.events.length, 'events', 3)
          .having((s) => s.hasMore, 'hasMore', false),
    ],
  );

  blocTest<EventsCubit, EventsState>(
    'load emits [loading, error] when the repository throws',
    build: () => EventsCubit(
      _FakeCreateRepository(const [])..error = const NetworkFailure(),
    ),
    act: (cubit) => cubit.load('soccer'),
    expect: () => [
      const EventsState.loading(),
      const EventsState.error(NetworkFailure()),
    ],
  );
}

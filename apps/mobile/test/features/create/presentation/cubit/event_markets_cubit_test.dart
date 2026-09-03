import 'package:booking_code/core/failure.dart';
import 'package:booking_code/features/create/domain/repositories/create_repository.dart';
import 'package:booking_code/features/create/presentation/cubit/event_markets_cubit.dart';
import 'package:booking_code/features/create/presentation/cubit/event_markets_state.dart';
import 'package:booking_code/models/events_page.dart';
import 'package:booking_code/models/fixture.dart';
import 'package:booking_code/models/sport.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCreateRepository implements CreateRepository {
  List<Market>? result;
  Object? error;

  @override
  Future<List<Market>> eventMarkets(String eventId) async {
    if (error != null) throw error!;
    return result!;
  }

  @override
  Future<List<Sport>> sports() => throw UnimplementedError();
  @override
  Future<EventsPage> events({
    required String sport,
    int limit = 20,
    int skip = 0,
  }) => throw UnimplementedError();
  @override
  Future<String> create(List<String> outcomeIds) => throw UnimplementedError();
}

void main() {
  const market = Market(
    marketId: 'm1',
    name: '1X2',
    type: 'win-draw-win',
    outcomes: [
      MarketOutcome(outcomeId: 'o1', label: 'Home', odds: 2),
      MarketOutcome(outcomeId: 'o2', label: 'Draw', odds: 3),
      MarketOutcome(outcomeId: 'o3', label: 'Away', odds: 2.5),
    ],
  );

  blocTest<EventMarketsCubit, EventMarketsState>(
    'load emits [loading, loaded]',
    build: () =>
        EventMarketsCubit(_FakeCreateRepository()..result = const [market]),
    act: (cubit) => cubit.load('e1'),
    expect: () => [
      const EventMarketsState.loading(),
      const EventMarketsState.loaded([market]),
    ],
  );

  blocTest<EventMarketsCubit, EventMarketsState>(
    'a NotFoundFailure becomes the empty state, not an error',
    build: () => EventMarketsCubit(
      _FakeCreateRepository()..error = const NotFoundFailure('none'),
    ),
    act: (cubit) => cubit.load('e1'),
    expect: () => [
      const EventMarketsState.loading(),
      const EventMarketsState.empty(),
    ],
  );

  blocTest<EventMarketsCubit, EventMarketsState>(
    'any other Failure becomes the error state',
    build: () => EventMarketsCubit(
      _FakeCreateRepository()..error = const NetworkFailure(),
    ),
    act: (cubit) => cubit.load('e1'),
    expect: () => [
      const EventMarketsState.loading(),
      const EventMarketsState.error(NetworkFailure()),
    ],
  );
}

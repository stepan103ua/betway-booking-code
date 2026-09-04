import 'package:booking_code/core/failure.dart';
import 'package:booking_code/features/create/domain/repositories/create_repository.dart';
import 'package:booking_code/features/create/presentation/cubit/create_cubit.dart';
import 'package:booking_code/features/create/presentation/cubit/create_state.dart';
import 'package:booking_code/features/create/presentation/model/draft_pick.dart';
import 'package:booking_code/models/events_page.dart';
import 'package:booking_code/models/fixture.dart';
import 'package:booking_code/models/sport.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

/// A fake, not a mock — the cubit only ever sees the domain interface, same
/// reasoning as `slip_cubit_test.dart`.
class _FakeCreateRepository implements CreateRepository {
  List<Sport> sportsResult = const [Sport(id: 'soccer', name: 'Soccer')];
  Object? sportsError;
  String createResult = 'BW6E45553D';
  Object? createError;

  @override
  Future<List<Sport>> sports() async {
    if (sportsError != null) throw sportsError!;
    return sportsResult;
  }

  @override
  Future<String> create(List<String> outcomeIds) async {
    if (createError != null) throw createError!;
    return createResult;
  }

  @override
  Future<EventsPage> events({
    required String sport,
    int limit = 20,
    int skip = 0,
  }) async => const EventsPage(events: [], skip: 0, limit: 20, hasMore: false);

  @override
  Future<List<Market>> eventMarkets(String eventId) async => const [];
}

void main() {
  const soccer = Sport(id: 'soccer', name: 'Soccer');
  const sports = [soccer];

  const pick1 = DraftPick(
    outcomeId: 'o1',
    outcomeLabel: 'Home',
    marketName: '1X2',
    eventId: 'e1',
    eventName: 'A vs. B',
    league: 'League',
    kickoffAt: '2026-09-03T18:00:00Z',
    odds: 2,
  );
  const pick2 = DraftPick(
    outcomeId: 'o2',
    outcomeLabel: 'Home',
    marketName: '1X2',
    eventId: 'e2',
    eventName: 'C vs. D',
    league: 'League',
    kickoffAt: '2026-09-03T18:00:00Z',
    odds: 1.5,
  );

  // Same event as pick1, different outcome — a booking-code conflict.
  const pick1Conflict = DraftPick(
    outcomeId: 'o1b',
    outcomeLabel: 'Over',
    marketName: 'Total (2.5)',
    eventId: 'e1',
    eventName: 'A vs. B',
    league: 'League',
    kickoffAt: '2026-09-03T18:00:00Z',
    odds: 1.8,
  );

  CreateState ready({
    List<DraftPick> picks = const [],
    String? createdCode,
    Failure? generateError,
  }) => CreateState.ready(
    sports: sports,
    selectedSport: soccer,
    picks: picks,
    createdCode: createdCode,
    generateError: generateError,
  );

  blocTest<CreateCubit, CreateState>(
    'load emits [loadingSports, ready] with the first sport selected',
    build: () => CreateCubit(_FakeCreateRepository()),
    act: (cubit) => cubit.load(),
    expect: () => [
      const CreateState.loadingSports(),
      isA<CreateReady>()
          .having((s) => s.selectedSport.id, 'selectedSport', 'soccer')
          .having((s) => s.picks, 'picks', isEmpty),
    ],
  );

  blocTest<CreateCubit, CreateState>(
    'load emits sportsError when the sport list is empty',
    build: () => CreateCubit(_FakeCreateRepository()..sportsResult = const []),
    act: (cubit) => cubit.load(),
    expect: () => [const CreateState.loadingSports(), isA<CreateSportsError>()],
  );

  blocTest<CreateCubit, CreateState>(
    'load emits sportsError when the repository throws',
    build: () => CreateCubit(
      _FakeCreateRepository()..sportsError = const NetworkFailure(),
    ),
    act: (cubit) => cubit.load(),
    expect: () => [
      const CreateState.loadingSports(),
      const CreateState.sportsError(NetworkFailure()),
    ],
  );

  blocTest<CreateCubit, CreateState>(
    'toggleOutcome adds a leg and recomputes the total',
    build: () => CreateCubit(_FakeCreateRepository()),
    seed: ready,
    act: (cubit) => cubit
      ..toggleOutcome(pick1)
      ..toggleOutcome(pick2),
    expect: () => [
      isA<CreateReady>().having((s) => s.picks.length, 'picks', 1),
      isA<CreateReady>()
          .having((s) => s.picks.length, 'picks', 2)
          .having((s) => s.totalOdds, 'totalOdds', closeTo(3.0, 1e-9)),
    ],
  );

  blocTest<CreateCubit, CreateState>(
    'toggleOutcome ignores a second pick from an event already in the draft',
    build: () => CreateCubit(_FakeCreateRepository()),
    seed: () => ready(picks: const [pick1]),
    act: (cubit) => cubit.toggleOutcome(pick1Conflict),
    expect: () => const <CreateState>[],
  );

  blocTest<CreateCubit, CreateState>(
    'toggleOutcome on an already-picked outcome removes it',
    build: () => CreateCubit(_FakeCreateRepository()),
    seed: () => ready(picks: const [pick1]),
    act: (cubit) => cubit.toggleOutcome(pick1),
    expect: () => [isA<CreateReady>().having((s) => s.picks, 'picks', isEmpty)],
  );

  blocTest<CreateCubit, CreateState>(
    'generate emits [generating, created] on success',
    build: () => CreateCubit(_FakeCreateRepository()),
    seed: () => ready(picks: const [pick1]),
    act: (cubit) => cubit.generate(),
    expect: () => [
      isA<CreateReady>().having((s) => s.generating, 'generating', true),
      isA<CreateReady>()
          .having((s) => s.generating, 'generating', false)
          .having((s) => s.createdCode, 'createdCode', 'BW6E45553D'),
    ],
  );

  blocTest<CreateCubit, CreateState>(
    'generate surfaces a Failure as generateError',
    build: () => CreateCubit(
      _FakeCreateRepository()
        ..createError = const OutcomesUnavailableFailure('Gone.'),
    ),
    seed: () => ready(picks: const [pick1]),
    act: (cubit) => cubit.generate(),
    expect: () => [
      isA<CreateReady>().having((s) => s.generating, 'generating', true),
      isA<CreateReady>()
          .having((s) => s.generating, 'generating', false)
          .having(
            (s) => s.generateError,
            'generateError',
            isA<OutcomesUnavailableFailure>(),
          ),
    ],
  );

  blocTest<CreateCubit, CreateState>(
    'generate is a no-op with an empty draft',
    build: () => CreateCubit(_FakeCreateRepository()),
    seed: ready,
    act: (cubit) => cubit.generate(),
    expect: () => const <CreateState>[],
  );

  blocTest<CreateCubit, CreateState>(
    'startOver clears the code and the draft',
    build: () => CreateCubit(_FakeCreateRepository()),
    seed: () => ready(picks: const [pick1], createdCode: 'BW6E45553D'),
    act: (cubit) => cubit.startOver(),
    expect: () => [
      isA<CreateReady>()
          .having((s) => s.createdCode, 'createdCode', isNull)
          .having((s) => s.picks, 'picks', isEmpty),
    ],
  );
}

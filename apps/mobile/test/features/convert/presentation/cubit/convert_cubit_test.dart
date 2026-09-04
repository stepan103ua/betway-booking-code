import 'package:booking_code/core/failure.dart';
import 'package:booking_code/features/convert/domain/repositories/convert_repository.dart';
import 'package:booking_code/features/convert/presentation/cubit/convert_cubit.dart';
import 'package:booking_code/features/convert/presentation/cubit/convert_state.dart';
import 'package:booking_code/models/convert_result.dart';
import 'package:booking_code/models/selection.dart';
import 'package:booking_code/models/slip.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

/// A fake, not a mock — the cubit only sees the domain interface, same as the
/// other feature cubit tests.
class _FakeConvertRepository implements ConvertRepository {
  Slip? resolveResult;
  Object? resolveError;
  ConvertResult? convertResult;
  Object? convertError;

  @override
  Future<Slip> resolve(String code) async {
    if (resolveError != null) throw resolveError!;
    return resolveResult!;
  }

  @override
  Future<ConvertResult> convert(
    String code,
    List<String> dropOutcomeIds,
  ) async {
    if (convertError != null) throw convertError!;
    return convertResult!;
  }
}

Selection _leg(String id, {bool active = true, String event = 'e1'}) =>
    Selection(
      outcomeId: id,
      eventId: event,
      marketName: '1X2',
      outcomeName: 'Home',
      eventName: 'A vs. B',
      league: 'League',
      kickoffAt: '2026-09-03T18:00:00Z',
      odds: 2,
      isActive: active,
    );

Slip _slip(List<Selection> selections) => Slip(
  bookingCode: 'BW6E19810C',
  totalOdds: 4,
  expiresAt: null,
  usageCount: null,
  selections: selections,
);

void main() {
  final twoLive = _slip([_leg('a', event: 'e1'), _leg('b', event: 'e2')]);
  final oneLiveOneDead = _slip([
    _leg('a', event: 'e1'),
    _leg('b', active: false, event: 'e2'),
  ]);
  final allDead = _slip([_leg('a', active: false)]);

  const result = ConvertResult(
    bookingCode: 'BW6E9A1123',
    totalOdds: 2,
    expiresAt: null,
    usageCount: null,
    selections: [],
    previousBookingCode: 'BW6E19810C',
    previousTotalOdds: 4,
    droppedCount: 1,
  );

  ConvertState ready(Slip original, {Set<String>? drop, ConvertResult? res}) =>
      ConvertState.ready(
        original: original,
        dropOutcomeIds: drop ?? const {},
        result: res,
      );

  blocTest<ConvertCubit, ConvertState>(
    'resolve emits [resolving, ready] on success',
    build: () =>
        ConvertCubit(_FakeConvertRepository()..resolveResult = twoLive),
    act: (cubit) => cubit.resolve('BW6E19810C'),
    expect: () => [
      const ConvertState.resolving(),
      isA<ConvertReady>().having((s) => s.original, 'original', twoLive),
    ],
  );

  blocTest<ConvertCubit, ConvertState>(
    'resolve emits [resolving, initial(codeError)] on a Failure',
    build: () => ConvertCubit(
      _FakeConvertRepository()..resolveError = const InvalidCodeFailure(),
    ),
    act: (cubit) => cubit.resolve('BWDEADBEEF'),
    expect: () => [
      const ConvertState.resolving(),
      const ConvertState.initial(codeError: InvalidCodeFailure()),
    ],
  );

  blocTest<ConvertCubit, ConvertState>(
    'toggleDrop adds then removes a live leg',
    build: () => ConvertCubit(_FakeConvertRepository()),
    seed: () => ready(twoLive),
    act: (cubit) => cubit
      ..toggleDrop('a')
      ..toggleDrop('a'),
    expect: () => [
      isA<ConvertReady>().having((s) => s.dropOutcomeIds, 'drop', {'a'}),
      isA<ConvertReady>().having((s) => s.dropOutcomeIds, 'drop', isEmpty),
    ],
  );

  blocTest<ConvertCubit, ConvertState>(
    'convert emits [converting, ready(result)] on success',
    build: () => ConvertCubit(_FakeConvertRepository()..convertResult = result),
    seed: () => ready(oneLiveOneDead),
    act: (cubit) => cubit.convert(),
    expect: () => [
      isA<ConvertReady>().having((s) => s.converting, 'converting', true),
      isA<ConvertReady>()
          .having((s) => s.converting, 'converting', false)
          .having((s) => s.result, 'result', result),
    ],
  );

  blocTest<ConvertCubit, ConvertState>(
    'convert surfaces a Failure as convertError',
    build: () => ConvertCubit(
      _FakeConvertRepository()..convertError = const EmptySlipFailure('none'),
    ),
    seed: () => ready(twoLive),
    act: (cubit) => cubit.convert(),
    expect: () => [
      isA<ConvertReady>().having((s) => s.converting, 'converting', true),
      isA<ConvertReady>()
          .having((s) => s.converting, 'converting', false)
          .having((s) => s.convertError, 'error', isA<EmptySlipFailure>()),
    ],
  );

  blocTest<ConvertCubit, ConvertState>(
    'convert is a no-op when no leg would survive',
    build: () => ConvertCubit(_FakeConvertRepository()..convertResult = result),
    seed: () => ready(allDead),
    act: (cubit) => cubit.convert(),
    expect: () => const <ConvertState>[],
  );

  blocTest<ConvertCubit, ConvertState>(
    'reset returns to the empty input',
    build: () => ConvertCubit(_FakeConvertRepository()),
    seed: () => ready(twoLive, res: result),
    act: (cubit) => cubit.reset(),
    expect: () => [const ConvertState.initial()],
  );

  test('ConvertReadyX derives kept legs, dropped count and preview odds', () {
    final s = ready(oneLiveOneDead, drop: const {}) as ConvertReady;
    expect(s.keptLegs.map((l) => l.outcomeId), ['a']);
    expect(s.droppedCount, 1); // the dead leg
    expect(s.previewOdds, 2.0);
    expect(s.canConvert, isTrue);

    final noneKept = ready(allDead) as ConvertReady;
    expect(noneKept.canConvert, isFalse);
  });
}

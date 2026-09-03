import 'dart:async';

import 'package:booking_code/core/failure.dart';
import 'package:booking_code/features/decode/domain/repositories/booking_code_repository.dart';
import 'package:booking_code/features/decode/presentation/cubit/slip_cubit.dart';
import 'package:booking_code/features/decode/presentation/cubit/slip_state.dart';
import 'package:booking_code/models/popular_codes_page.dart';
import 'package:booking_code/models/selection.dart';
import 'package:booking_code/models/slip.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

/// A fake, not a mock — `docs/mobile.md` §8 tests `SlipCubit` "against a
/// fake `BookingCodeRepository` (the interface)", the same seam
/// `BookingCodeProvider` plays server-side. No `dio`, no mocktail needed
/// here; the Cubit only ever sees this interface.
class _FakeRepository implements BookingCodeRepository {
  _FakeRepository.returning(this._slip) : _failure = null;
  _FakeRepository.throwing(this._failure) : _slip = null;

  final Slip? _slip;
  final Failure? _failure;

  @override
  Future<Slip> resolve(String code) async {
    if (_failure != null) throw _failure;
    return _slip!;
  }

  @override
  Future<PopularCodesPage> popular({int limit = 6, int skip = 0}) =>
      throw UnimplementedError('SlipCubit never calls popular()');
}

/// Resolves only after [release] is called — long enough for a test to close
/// the Cubit while the request is still in flight.
class _GatedRepository implements BookingCodeRepository {
  _GatedRepository(this._slip);
  final Slip _slip;
  final _gate = Completer<void>();

  void release() => _gate.complete();

  @override
  Future<Slip> resolve(String code) async {
    await _gate.future;
    return _slip;
  }

  @override
  Future<PopularCodesPage> popular({int limit = 6, int skip = 0}) =>
      throw UnimplementedError();
}

void main() {
  const slip = Slip(
    bookingCode: 'BW6E19810C',
    totalOdds: 1.26,
    expiresAt: null,
    usageCount: null,
    selections: [
      Selection(
        outcomeId: '1',
        eventId: '10',
        marketName: '1X2',
        outcomeName: 'Home',
        eventName: 'A vs. B',
        league: 'League',
        kickoffAt: '2026-09-03T18:00:00Z',
        odds: 1.26,
        isActive: true,
      ),
    ],
  );

  blocTest<SlipCubit, SlipState>(
    'emits [loading, loaded] on a successful resolve',
    build: () => SlipCubit(_FakeRepository.returning(slip)),
    act: (cubit) => cubit.resolve('BW6E19810C'),
    expect: () => [const SlipState.loading(), SlipState.loaded(slip)],
  );

  blocTest<SlipCubit, SlipState>(
    'emits [loading, error] when the repository throws InvalidCodeFailure',
    build: () =>
        SlipCubit(_FakeRepository.throwing(const InvalidCodeFailure())),
    act: (cubit) => cubit.resolve('BWDEADBEEF'),
    expect: () => [
      const SlipState.loading(),
      const SlipState.error(InvalidCodeFailure()),
    ],
  );

  test('resolve does not emit (or throw) after the Cubit is closed', () async {
    final repo = _GatedRepository(slip);
    final cubit = SlipCubit(repo);
    final states = <SlipState>[];
    final sub = cubit.stream.listen(states.add);

    final pending = cubit.resolve('BW6E19810C'); // emits loading, then awaits
    await cubit.close(); // user leaves the Decode tab
    repo.release(); // response finally lands
    await pending; // must complete without a StateError

    expect(states, [const SlipState.loading()]); // no post-close loaded emit
    await sub.cancel();
  });

  blocTest<SlipCubit, SlipState>(
    'reset() returns to initial from any state',
    build: () => SlipCubit(_FakeRepository.returning(slip)),
    act: (cubit) async {
      await cubit.resolve('BW6E19810C');
      cubit.reset();
    },
    expect: () => [
      const SlipState.loading(),
      SlipState.loaded(slip),
      const SlipState.initial(),
    ],
  );
}

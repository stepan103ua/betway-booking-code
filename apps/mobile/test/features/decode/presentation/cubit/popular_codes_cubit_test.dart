import 'package:booking_code/core/failure.dart';
import 'package:booking_code/features/decode/domain/repositories/booking_code_repository.dart';
import 'package:booking_code/features/decode/presentation/cubit/popular_codes_cubit.dart';
import 'package:booking_code/features/decode/presentation/cubit/popular_codes_state.dart';
import 'package:booking_code/models/popular_codes_page.dart';
import 'package:booking_code/models/selection.dart';
import 'package:booking_code/models/slip.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

/// A fake, not a mock — same reasoning as `slip_cubit_test.dart`: the Cubit
/// only ever sees the domain interface, so a fake of it is enough.
class _FakeRepository implements BookingCodeRepository {
  _FakeRepository.returning(this._page) : _failure = null;
  _FakeRepository.throwing(this._failure) : _page = null;

  final PopularCodesPage? _page;
  final Failure? _failure;

  @override
  Future<PopularCodesPage> popular({int limit = 6, int skip = 0}) async {
    if (_failure != null) throw _failure;
    return _page!;
  }

  @override
  Future<Slip> resolve(String code) =>
      throw UnimplementedError('PopularCodesCubit never calls resolve()');
}

void main() {
  const slip = Slip(
    bookingCode: 'BW6E5B94E1',
    totalOdds: 74.12,
    expiresAt: '2026-09-04T09:26:42.970Z',
    usageCount: 9227,
    selections: [
      Selection(
        outcomeId: '1',
        marketName: '1X2',
        outcomeName: 'Home',
        eventName: 'A vs. B',
        league: 'League',
        kickoffAt: '2026-09-03T18:00:00Z',
        odds: 1.5,
        isActive: true,
      ),
    ],
  );
  const page = PopularCodesPage(
    codes: [slip],
    skip: 0,
    limit: 3,
    total: 120,
    hasMore: true,
  );

  blocTest<PopularCodesCubit, PopularCodesState>(
    'emits [loading, loaded] on a successful load',
    build: () => PopularCodesCubit(_FakeRepository.returning(page)),
    act: (cubit) => cubit.load(),
    expect: () => [
      const PopularCodesState.loading(),
      const PopularCodesState.loaded([slip]),
    ],
  );

  blocTest<PopularCodesCubit, PopularCodesState>(
    'emits [loading, error] when the repository throws',
    build: () =>
        PopularCodesCubit(_FakeRepository.throwing(const NetworkFailure())),
    act: (cubit) => cubit.load(),
    expect: () => [
      const PopularCodesState.loading(),
      const PopularCodesState.error(NetworkFailure()),
    ],
  );
}

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
/// only ever sees the domain interface, so a fake of it is enough. Returns a
/// page per call so a test can drive load → loadMore.
class _FakeRepository implements BookingCodeRepository {
  _FakeRepository(this._pages);

  final List<PopularCodesPage> _pages;
  int _call = 0;
  Failure? error;

  /// When set, `popular()` throws [error] on this 0-based call and succeeds
  /// otherwise — lets a test fail only the load-more fetch.
  int? errorOnCall;

  @override
  Future<PopularCodesPage> popular({int limit = 6, int skip = 0}) async {
    final call = _call++;
    if (error != null && (errorOnCall == null || errorOnCall == call)) {
      throw error!;
    }
    return _pages[call];
  }

  @override
  Future<Slip> resolve(String code) =>
      throw UnimplementedError('PopularCodesCubit never calls resolve()');
}

Slip _slip(String code) => Slip(
  bookingCode: code,
  totalOdds: 12.0,
  expiresAt: null,
  usageCount: null,
  selections: const [
    Selection(
      outcomeId: '1',
      eventId: '10',
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

PopularCodesPage _page(
  List<String> codes, {
  required int skip,
  required bool hasMore,
}) => PopularCodesPage(
  codes: codes.map(_slip).toList(),
  skip: skip,
  limit: 6,
  total: 120,
  hasMore: hasMore,
);

void main() {
  blocTest<PopularCodesCubit, PopularCodesState>(
    'load emits [loading, loaded] and carries total/hasMore/nextSkip',
    build: () => PopularCodesCubit(
      _FakeRepository([
        _page(['BW00000001'], skip: 0, hasMore: true),
      ]),
    ),
    act: (cubit) => cubit.load(),
    expect: () => [
      const PopularCodesState.loading(),
      isA<PopularCodesLoaded>()
          .having((s) => s.codes.length, 'codes', 1)
          .having((s) => s.total, 'total', 120)
          .having((s) => s.hasMore, 'hasMore', true)
          .having((s) => s.nextSkip, 'nextSkip', 6),
    ],
  );

  blocTest<PopularCodesCubit, PopularCodesState>(
    'loadMore appends the next page, skipping a repeated code',
    build: () => PopularCodesCubit(
      _FakeRepository([
        _page(['BW00000001', 'BW00000002'], skip: 0, hasMore: true),
        _page(['BW00000002', 'BW00000003'], skip: 6, hasMore: false),
      ]),
    ),
    act: (cubit) async {
      await cubit.load();
      await cubit.loadMore();
    },
    expect: () => [
      const PopularCodesState.loading(),
      isA<PopularCodesLoaded>().having((s) => s.codes.length, 'codes', 2),
      isA<PopularCodesLoaded>().having(
        (s) => s.loadingMore,
        'loadingMore',
        true,
      ),
      isA<PopularCodesLoaded>()
          .having((s) => s.codes.length, 'deduped', 3)
          .having((s) => s.hasMore, 'hasMore', false),
    ],
  );

  blocTest<PopularCodesCubit, PopularCodesState>(
    'load emits [loading, error] when the repository throws',
    build: () => PopularCodesCubit(
      _FakeRepository(const [])..error = const NetworkFailure(),
    ),
    act: (cubit) => cubit.load(),
    expect: () => [
      const PopularCodesState.loading(),
      const PopularCodesState.error(NetworkFailure()),
    ],
  );

  blocTest<PopularCodesCubit, PopularCodesState>(
    'a failed loadMore keeps the list and surfaces loadMoreError',
    build: () => PopularCodesCubit(
      _FakeRepository([
          _page(['BW00000001', 'BW00000002'], skip: 0, hasMore: true),
        ])
        ..error = const NetworkFailure()
        ..errorOnCall = 1,
    ),
    act: (cubit) async {
      await cubit.load();
      await cubit.loadMore();
    },
    expect: () => [
      const PopularCodesState.loading(),
      isA<PopularCodesLoaded>().having((s) => s.codes.length, 'codes', 2),
      isA<PopularCodesLoaded>().having(
        (s) => s.loadingMore,
        'loadingMore',
        true,
      ),
      isA<PopularCodesLoaded>()
          .having((s) => s.codes.length, 'kept', 2)
          .having((s) => s.loadingMore, 'loadingMore', false)
          .having(
            (s) => s.loadMoreError,
            'loadMoreError',
            isA<NetworkFailure>(),
          )
          .having((s) => s.hasMore, 'hasMore', true),
    ],
  );
}

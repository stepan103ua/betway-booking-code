import 'package:booking_code/core/failure.dart';
import 'package:booking_code/features/decode/data/datasources/booking_code_remote_data_source.dart';
import 'package:booking_code/features/decode/data/repositories/booking_code_repository_impl.dart';
import 'package:booking_code/models/popular_codes_page.dart';
import 'package:booking_code/models/selection.dart';
import 'package:booking_code/models/slip.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemoteDataSource extends Mock
    implements BookingCodeRemoteDataSource {}

void main() {
  late _MockRemoteDataSource remote;
  late BookingCodeRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/'));
  });

  setUp(() {
    remote = _MockRemoteDataSource();
    repository = BookingCodeRepositoryImpl(remote);
  });

  const slip = Slip(
    bookingCode: 'BW6E19810C',
    totalOdds: 1.26,
    expiresAt: null,
    usageCount: null,
    selections: [
      Selection(
        outcomeId: '1',
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

  DioException dioError({int? statusCode, Object? data}) {
    final options = RequestOptions(path: '/api/booking-codes/resolve');
    return DioException(
      requestOptions: options,
      response: statusCode == null
          ? null
          : Response(
              requestOptions: options,
              statusCode: statusCode,
              data: data,
            ),
      type: statusCode == null
          ? DioExceptionType.connectionError
          : DioExceptionType.badResponse,
    );
  }

  test('returns the Slip the data source resolves', () async {
    when(() => remote.resolve('BW6E19810C')).thenAnswer((_) async => slip);

    final result = await repository.resolve('BW6E19810C');

    expect(result, slip);
  });

  test('maps a 404 to InvalidCodeFailure', () async {
    when(
      () => remote.resolve('BWDEADBEEF'),
    ).thenThrow(dioError(statusCode: 404));

    expect(
      () => repository.resolve('BWDEADBEEF'),
      throwsA(isA<InvalidCodeFailure>()),
    );
  });

  test('maps no response to NetworkFailure', () async {
    when(() => remote.resolve('BW6E19810C')).thenThrow(dioError());

    expect(
      () => repository.resolve('BW6E19810C'),
      throwsA(isA<NetworkFailure>()),
    );
  });

  test(
    'maps any other status to UnknownFailure, using the server message',
    () async {
      when(() => remote.resolve('BW6E19810C')).thenThrow(
        dioError(
          statusCode: 502,
          data: {
            'error': 'upstream_error',
            'message': 'Betway is unreachable.',
          },
        ),
      );

      try {
        await repository.resolve('BW6E19810C');
        fail('expected UnknownFailure');
      } on UnknownFailure catch (f) {
        expect(f.message, 'Betway is unreachable.');
      }
    },
  );

  test('falls back to a generic message when the body has none', () async {
    when(
      () => remote.resolve('BW6E19810C'),
    ).thenThrow(dioError(statusCode: 500, data: 'not json'));

    try {
      await repository.resolve('BW6E19810C');
      fail('expected UnknownFailure');
    } on UnknownFailure catch (f) {
      expect(f.message, isNotEmpty);
    }
  });

  const page = PopularCodesPage(
    codes: [slip],
    skip: 0,
    limit: 3,
    total: 120,
    hasMore: true,
  );

  test('popular returns the page the data source resolves', () async {
    when(() => remote.popular(limit: 3, skip: 0)).thenAnswer((_) async => page);

    final result = await repository.popular(limit: 3, skip: 0);

    expect(result, page);
  });

  test('popular maps no response to NetworkFailure', () async {
    when(() => remote.popular(limit: 6, skip: 0)).thenThrow(dioError());

    expect(() => repository.popular(), throwsA(isA<NetworkFailure>()));
  });

  test('popular maps a 404 to UnknownFailure, not InvalidCodeFailure — that '
      'reading is specific to resolve()', () async {
    when(
      () => remote.popular(limit: 6, skip: 0),
    ).thenThrow(dioError(statusCode: 404));

    expect(() => repository.popular(), throwsA(isA<UnknownFailure>()));
  });
}

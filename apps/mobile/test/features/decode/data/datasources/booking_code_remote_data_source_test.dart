import 'dart:convert';

import 'package:booking_code/features/decode/data/datasources/booking_code_remote_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockHttpClientAdapter extends Mock implements HttpClientAdapter {}

void main() {
  late _MockHttpClientAdapter adapter;
  late Dio dio;
  late BookingCodeRemoteDataSource dataSource;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/'));
  });

  setUp(() {
    adapter = _MockHttpClientAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
    dataSource = BookingCodeRemoteDataSource(dio);
  });

  ResponseBody jsonResponse(Map<String, dynamic> body, int statusCode) {
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  test(
    'posts to /api/booking-codes/resolve with the code in the body',
    () async {
      when(() => adapter.fetch(any(), any(), any())).thenAnswer(
        (_) async => jsonResponse({
          'bookingCode': 'BW6E19810C',
          'totalOdds': 1.26,
          'expiresAt': null,
          'usageCount': null,
          'selections': <Map<String, dynamic>>[],
        }, 200),
      );

      await dataSource.resolve('BW6E19810C');

      final captured = verify(
        () => adapter.fetch(captureAny(), any(), any()),
      ).captured;
      final options = captured.single as RequestOptions;
      expect(options.method, 'POST');
      expect(options.path, '/api/booking-codes/resolve');
      expect(options.data, {'code': 'BW6E19810C'});
    },
  );

  test('parses a 200 response into a Slip', () async {
    when(() => adapter.fetch(any(), any(), any())).thenAnswer(
      (_) async => jsonResponse({
        'bookingCode': 'BW6E19810C',
        'totalOdds': 2.76,
        'expiresAt': null,
        'usageCount': null,
        'selections': [
          {
            'outcomeId': '7325887411',
            'eventId': '73258874',
            'marketName': '1X2',
            'outcomeName': 'Mamelodi Sundowns',
            'eventName': 'Mamelodi Sundowns vs. Milford FC',
            'league': 'Premier League',
            'kickoffAt': '2026-09-03T18:00:00Z',
            'odds': 1.26,
            'isActive': true,
          },
        ],
      }, 200),
    );

    final slip = await dataSource.resolve('BW6E19810C');

    expect(slip.bookingCode, 'BW6E19810C');
    expect(slip.totalOdds, 2.76);
    expect(slip.selections, hasLength(1));
    expect(slip.selections.single.odds, 1.26);
  });

  test('a whole-number odds value still parses as a double', () async {
    // jsonDecode gives `int` for a bare `2`, not `double` — the trap
    // `json_serializable`'s generated `(json['odds'] as num).toDouble()`
    // exists to avoid (see lib/models/selection.dart's doc comment).
    when(() => adapter.fetch(any(), any(), any())).thenAnswer(
      (_) async => jsonResponse({
        'bookingCode': 'BW6E19810C',
        'totalOdds': 2,
        'expiresAt': null,
        'usageCount': null,
        'selections': [
          {
            'outcomeId': '1',
            'eventId': '10',
            'marketName': '1X2',
            'outcomeName': 'Home',
            'eventName': 'A vs. B',
            'league': 'League',
            'kickoffAt': '2026-09-03T18:00:00Z',
            'odds': 2,
            'isActive': true,
          },
        ],
      }, 200),
    );

    final slip = await dataSource.resolve('BW6E19810C');

    expect(slip.totalOdds, 2.0);
    expect(slip.selections.single.odds, 2.0);
  });

  test('a non-2xx response surfaces as a DioException', () async {
    when(() => adapter.fetch(any(), any(), any())).thenAnswer(
      (_) async => jsonResponse({
        'error': 'invalid_code',
        'message': 'No slip found for this code.',
      }, 404),
    );

    expect(
      () => dataSource.resolve('BWDEADBEEF'),
      throwsA(isA<DioException>()),
    );
  });

  test(
    'gets /api/booking-codes/popular with limit and skip as query params',
    () async {
      when(() => adapter.fetch(any(), any(), any())).thenAnswer(
        (_) async => jsonResponse({
          'codes': <Map<String, dynamic>>[],
          'skip': 0,
          'limit': 3,
          'total': 120,
          'hasMore': true,
        }, 200),
      );

      await dataSource.popular(limit: 3, skip: 0);

      final options =
          verify(
                () => adapter.fetch(captureAny(), any(), any()),
              ).captured.single
              as RequestOptions;
      expect(options.method, 'GET');
      expect(options.path, '/api/booking-codes/popular');
      expect(options.queryParameters, {'limit': 3, 'skip': 0});
    },
  );

  test(
    'parses a popular-codes page, including non-null expiresAt/usageCount',
    () async {
      when(() => adapter.fetch(any(), any(), any())).thenAnswer(
        (_) async => jsonResponse({
          'codes': [
            {
              'bookingCode': 'BW6E5B94E1',
              'totalOdds': 74.12,
              'expiresAt': '2026-09-04T09:26:42.970Z',
              'usageCount': 9227,
              'selections': <Map<String, dynamic>>[],
            },
          ],
          'skip': 0,
          'limit': 6,
          'total': 120,
          'hasMore': true,
        }, 200),
      );

      final page = await dataSource.popular();

      expect(page.codes, hasLength(1));
      expect(page.codes.single.expiresAt, '2026-09-04T09:26:42.970Z');
      expect(page.codes.single.usageCount, 9227);
      expect(page.hasMore, isTrue);
      expect(page.total, 120);
    },
  );
}

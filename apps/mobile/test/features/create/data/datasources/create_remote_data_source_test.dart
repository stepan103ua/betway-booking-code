import 'dart:convert';

import 'package:booking_code/features/create/data/datasources/create_remote_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockHttpClientAdapter extends Mock implements HttpClientAdapter {}

void main() {
  late _MockHttpClientAdapter adapter;
  late Dio dio;
  late CreateRemoteDataSource dataSource;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/'));
  });

  setUp(() {
    adapter = _MockHttpClientAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
    dataSource = CreateRemoteDataSource(dio);
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

  RequestOptions lastRequest() {
    return verify(
          () => adapter.fetch(captureAny(), any(), any()),
        ).captured.single
        as RequestOptions;
  }

  test('sports() gets /api/sports and unwraps the list', () async {
    when(() => adapter.fetch(any(), any(), any())).thenAnswer(
      (_) async => jsonResponse({
        'sports': [
          {'id': 'soccer', 'name': 'Soccer'},
        ],
      }, 200),
    );

    final sports = await dataSource.sports();

    final options = lastRequest();
    expect(options.method, 'GET');
    expect(options.path, '/api/sports');
    expect(sports.single.id, 'soccer');
    expect(sports.single.name, 'Soccer');
  });

  test('events() sends sport, limit and skip as query params', () async {
    when(() => adapter.fetch(any(), any(), any())).thenAnswer(
      (_) async => jsonResponse({
        'events': <Map<String, dynamic>>[],
        'skip': 20,
        'limit': 20,
        'hasMore': false,
      }, 200),
    );

    await dataSource.events(sport: 'soccer', limit: 20, skip: 20);

    final options = lastRequest();
    expect(options.method, 'GET');
    expect(options.path, '/api/events');
    expect(options.queryParameters, {
      'sport': 'soccer',
      'limit': 20,
      'skip': 20,
    });
  });

  test('events() parses a page of fixtures with inline markets', () async {
    when(() => adapter.fetch(any(), any(), any())).thenAnswer(
      (_) async => jsonResponse({
        'events': [
          {
            'eventId': '74232940',
            'name': 'Liverpool vs. Real Madrid',
            'league': 'eAdriatic League',
            'kickoffAt': '2026-09-02T20:00:00Z',
            'markets': [
              {
                'marketId': '742329401',
                'name': '1X2',
                'type': 'win-draw-win',
                'outcomes': [
                  {
                    'outcomeId': '7423294011',
                    'label': 'Liverpool',
                    'odds': 2.27,
                  },
                  {'outcomeId': '7423294012', 'label': 'Draw', 'odds': 3},
                  {
                    'outcomeId': '7423294013',
                    'label': 'Real Madrid',
                    'odds': 2.43,
                  },
                ],
              },
            ],
          },
        ],
        'skip': 0,
        'limit': 20,
        'hasMore': true,
      }, 200),
    );

    final page = await dataSource.events(sport: 'soccer');

    expect(page.hasMore, isTrue);
    expect(page.events.single.markets.single.outcomes, hasLength(3));
    // jsonDecode gives `int` for a bare `3` — the model's `double` field is
    // what makes this a `double` (see lib/models/fixture.dart).
    expect(page.events.single.markets.single.outcomes[1].odds, 3.0);
  });

  test('eventMarkets() gets the nested path and unwraps {markets}', () async {
    when(() => adapter.fetch(any(), any(), any())).thenAnswer(
      (_) async => jsonResponse({
        'eventId': '74263200',
        'markets': [
          {
            'marketId': '7426320018total=6.5~',
            'name': 'Total (6.5)',
            'type': 'handicap-goals-over',
            'outcomes': [
              {
                'outcomeId': '7426320018total=6.5~12',
                'label': 'Over',
                'odds': 1.93,
              },
              {
                'outcomeId': '7426320018total=6.5~13',
                'label': 'Under',
                'odds': 1.69,
              },
            ],
          },
        ],
      }, 200),
    );

    final markets = await dataSource.eventMarkets('74263200');

    final options = lastRequest();
    expect(options.method, 'GET');
    expect(options.path, '/api/events/74263200/markets');
    expect(markets.single.name, 'Total (6.5)');
    expect(markets.single.outcomes, hasLength(2));
  });

  test('create() posts outcomeIds and returns the bookingCode', () async {
    when(
      () => adapter.fetch(any(), any(), any()),
    ).thenAnswer((_) async => jsonResponse({'bookingCode': 'BW6E45553D'}, 200));

    final code = await dataSource.create(['7423294011', '7423294012']);

    final options = lastRequest();
    expect(options.method, 'POST');
    expect(options.path, '/api/booking-codes');
    expect(options.data, {
      'outcomeIds': ['7423294011', '7423294012'],
    });
    expect(code, 'BW6E45553D');
  });

  test('a non-2xx response surfaces as a DioException', () async {
    when(() => adapter.fetch(any(), any(), any())).thenAnswer(
      (_) async => jsonResponse({
        'error': 'outcomes_unavailable',
        'message': 'Those selections are no longer available.',
      }, 400),
    );

    expect(
      () => dataSource.create(['0000000000']),
      throwsA(isA<DioException>()),
    );
  });
}

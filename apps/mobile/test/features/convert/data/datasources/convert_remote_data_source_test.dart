import 'dart:convert';

import 'package:booking_code/features/convert/data/datasources/convert_remote_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockHttpClientAdapter extends Mock implements HttpClientAdapter {}

Map<String, dynamic> _selection({
  String outcomeId = '1',
  String eventId = '10',
}) => {
  'outcomeId': outcomeId,
  'eventId': eventId,
  'marketName': '1X2',
  'outcomeName': 'Home',
  'eventName': 'A vs. B',
  'league': 'League',
  'kickoffAt': '2026-09-03T18:00:00Z',
  'odds': 1.5,
  'isActive': true,
};

void main() {
  late _MockHttpClientAdapter adapter;
  late Dio dio;
  late ConvertRemoteDataSource dataSource;

  setUpAll(() => registerFallbackValue(RequestOptions(path: '/')));

  setUp(() {
    adapter = _MockHttpClientAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
    dataSource = ConvertRemoteDataSource(dio);
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

  RequestOptions lastRequest() =>
      verify(() => adapter.fetch(captureAny(), any(), any())).captured.single
          as RequestOptions;

  test('resolve posts the code to /api/booking-codes/resolve', () async {
    when(() => adapter.fetch(any(), any(), any())).thenAnswer(
      (_) async => jsonResponse({
        'bookingCode': 'BW6E19810C',
        'totalOdds': 1.5,
        'expiresAt': null,
        'usageCount': null,
        'selections': [_selection()],
      }, 200),
    );

    await dataSource.resolve('BW6E19810C');

    final options = lastRequest();
    expect(options.method, 'POST');
    expect(options.path, '/api/booking-codes/resolve');
    expect(options.data, {'code': 'BW6E19810C'});
  });

  test('convert posts code and dropOutcomeIds, parses ConvertResult', () async {
    when(() => adapter.fetch(any(), any(), any())).thenAnswer(
      (_) async => jsonResponse({
        'bookingCode': 'BW6E9A1123',
        'previousBookingCode': 'BW6E19810C',
        'totalOdds': 2.19,
        'previousTotalOdds': 2.76,
        'expiresAt': null,
        'usageCount': null,
        'selections': [_selection(outcomeId: '2', eventId: '20')],
        'droppedCount': 1,
      }, 200),
    );

    final result = await dataSource.convert('BW6E19810C', ['1']);

    final options = lastRequest();
    expect(options.method, 'POST');
    expect(options.path, '/api/booking-codes/convert');
    expect(options.data, {
      'code': 'BW6E19810C',
      'dropOutcomeIds': ['1'],
    });
    expect(result.bookingCode, 'BW6E9A1123');
    expect(result.previousBookingCode, 'BW6E19810C');
    expect(result.previousTotalOdds, 2.76);
    expect(result.droppedCount, 1);
    expect(result.selections.single.outcomeId, '2');
  });

  test('a whole-number previousTotalOdds still parses as a double', () async {
    when(() => adapter.fetch(any(), any(), any())).thenAnswer(
      (_) async => jsonResponse({
        'bookingCode': 'BW6E9A1123',
        'previousBookingCode': 'BW6E19810C',
        'totalOdds': 2,
        'previousTotalOdds': 3,
        'expiresAt': null,
        'usageCount': null,
        'selections': [_selection()],
        'droppedCount': 0,
      }, 200),
    );

    final result = await dataSource.convert('BW6E19810C', const []);

    expect(result.totalOdds, 2.0);
    expect(result.previousTotalOdds, 3.0);
  });

  test('a non-2xx response surfaces as a DioException', () async {
    when(() => adapter.fetch(any(), any(), any())).thenAnswer(
      (_) async => jsonResponse({
        'error': 'empty_slip',
        'message': 'Dropping those leaves nothing to convert.',
      }, 400),
    );

    expect(
      () => dataSource.convert('BW6E19810C', ['1']),
      throwsA(isA<DioException>()),
    );
  });
}

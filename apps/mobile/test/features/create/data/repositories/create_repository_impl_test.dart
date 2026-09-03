import 'package:booking_code/core/failure.dart';
import 'package:booking_code/features/create/data/datasources/create_remote_data_source.dart';
import 'package:booking_code/features/create/data/repositories/create_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemoteDataSource extends Mock implements CreateRemoteDataSource {}

void main() {
  late _MockRemoteDataSource remote;
  late CreateRepositoryImpl repository;

  setUp(() {
    remote = _MockRemoteDataSource();
    repository = CreateRepositoryImpl(remote);
  });

  DioException dioError({int? statusCode, Object? data}) {
    final options = RequestOptions(path: '/api/booking-codes');
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

  group('create', () {
    test('returns the code the data source resolves', () async {
      when(() => remote.create(any())).thenAnswer((_) async => 'BW6E45553D');

      expect(await repository.create(['1', '2']), 'BW6E45553D');
    });

    test('maps 400 outcomes_unavailable, keeping the server message', () async {
      when(() => remote.create(any())).thenThrow(
        dioError(
          statusCode: 400,
          data: {
            'error': 'outcomes_unavailable',
            'message': 'Those selections are no longer available.',
          },
        ),
      );

      try {
        await repository.create(['1']);
        fail('expected OutcomesUnavailableFailure');
      } on OutcomesUnavailableFailure catch (f) {
        expect(f.message, 'Those selections are no longer available.');
      }
    });

    test('maps 400 too_many_outcomes', () async {
      when(() => remote.create(any())).thenThrow(
        dioError(
          statusCode: 400,
          data: {
            'error': 'too_many_outcomes',
            'message': 'A slip can hold at most 20 selections.',
          },
        ),
      );

      expect(
        () => repository.create(['1']),
        throwsA(isA<TooManyOutcomesFailure>()),
      );
    });

    test('maps 400 invalid_request to UnknownFailure', () async {
      when(() => remote.create(any())).thenThrow(
        dioError(
          statusCode: 400,
          data: {'error': 'invalid_request', 'message': 'Bad request.'},
        ),
      );

      expect(() => repository.create(['1']), throwsA(isA<UnknownFailure>()));
    });

    test('maps no response to NetworkFailure', () async {
      when(() => remote.create(any())).thenThrow(dioError());

      expect(() => repository.create(['1']), throwsA(isA<NetworkFailure>()));
    });
  });

  group('eventMarkets', () {
    test('maps 404 to NotFoundFailure', () async {
      when(() => remote.eventMarkets('9')).thenThrow(
        dioError(
          statusCode: 404,
          data: {
            'error': 'not_found',
            'message': 'No markets found for this event.',
          },
        ),
      );

      try {
        await repository.eventMarkets('9');
        fail('expected NotFoundFailure');
      } on NotFoundFailure catch (f) {
        expect(f.message, 'No markets found for this event.');
      }
    });

    test('maps other errors through the shared mapper', () async {
      when(() => remote.eventMarkets('9')).thenThrow(dioError(statusCode: 502));

      expect(
        () => repository.eventMarkets('9'),
        throwsA(isA<UnknownFailure>()),
      );
    });
  });

  test('sports/events map no response to NetworkFailure', () async {
    when(() => remote.sports()).thenThrow(dioError());
    when(
      () => remote.events(
        sport: any(named: 'sport'),
        limit: any(named: 'limit'),
        skip: any(named: 'skip'),
      ),
    ).thenThrow(dioError());

    expect(() => repository.sports(), throwsA(isA<NetworkFailure>()));
    expect(
      () => repository.events(sport: 'soccer'),
      throwsA(isA<NetworkFailure>()),
    );
  });
}

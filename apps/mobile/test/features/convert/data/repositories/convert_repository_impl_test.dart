import 'package:booking_code/core/failure.dart';
import 'package:booking_code/features/convert/data/datasources/convert_remote_data_source.dart';
import 'package:booking_code/features/convert/data/repositories/convert_repository_impl.dart';
import 'package:booking_code/models/convert_result.dart';
import 'package:booking_code/models/selection.dart';
import 'package:booking_code/models/slip.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemoteDataSource extends Mock implements ConvertRemoteDataSource {}

void main() {
  late _MockRemoteDataSource remote;
  late ConvertRepositoryImpl repository;

  setUp(() {
    remote = _MockRemoteDataSource();
    repository = ConvertRepositoryImpl(remote);
  });

  DioException dioError({int? statusCode, Object? data}) {
    final options = RequestOptions(path: '/api/booking-codes/convert');
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

  const slip = Slip(
    bookingCode: 'BW6E19810C',
    totalOdds: 1.5,
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
        odds: 1.5,
        isActive: true,
      ),
    ],
  );

  const result = ConvertResult(
    bookingCode: 'BW6E9A1123',
    totalOdds: 1.5,
    expiresAt: null,
    usageCount: null,
    selections: [],
    previousBookingCode: 'BW6E19810C',
    previousTotalOdds: 2.0,
    droppedCount: 1,
  );

  group('resolve', () {
    test('returns the slip the data source resolves', () async {
      when(() => remote.resolve('BW6E19810C')).thenAnswer((_) async => slip);
      expect(await repository.resolve('BW6E19810C'), slip);
    });

    test('maps a 404 to InvalidCodeFailure', () async {
      when(() => remote.resolve(any())).thenThrow(dioError(statusCode: 404));
      expect(
        () => repository.resolve('BWDEADBEEF'),
        throwsA(isA<InvalidCodeFailure>()),
      );
    });
  });

  group('convert', () {
    test('returns the ConvertResult the data source resolves', () async {
      when(() => remote.convert(any(), any())).thenAnswer((_) async => result);
      expect(await repository.convert('BW6E19810C', const []), result);
    });

    test('maps a 404 to InvalidCodeFailure', () async {
      when(
        () => remote.convert(any(), any()),
      ).thenThrow(dioError(statusCode: 404));
      expect(
        () => repository.convert('BWDEADBEEF', const []),
        throwsA(isA<InvalidCodeFailure>()),
      );
    });

    test('maps 400 empty_slip, keeping the server message', () async {
      when(() => remote.convert(any(), any())).thenThrow(
        dioError(
          statusCode: 400,
          data: {
            'error': 'empty_slip',
            'message': 'Dropping those leaves nothing to convert.',
          },
        ),
      );
      try {
        await repository.convert('BW6E19810C', const ['1']);
        fail('expected EmptySlipFailure');
      } on EmptySlipFailure catch (f) {
        expect(f.message, 'Dropping those leaves nothing to convert.');
      }
    });

    test('maps 400 outcomes_unavailable', () async {
      when(() => remote.convert(any(), any())).thenThrow(
        dioError(
          statusCode: 400,
          data: {'error': 'outcomes_unavailable', 'message': 'Went off.'},
        ),
      );
      expect(
        () => repository.convert('BW6E19810C', const []),
        throwsA(isA<OutcomesUnavailableFailure>()),
      );
    });

    test('maps 400 conflicting_selections', () async {
      when(() => remote.convert(any(), any())).thenThrow(
        dioError(
          statusCode: 400,
          data: {'error': 'conflicting_selections', 'message': 'Same match.'},
        ),
      );
      expect(
        () => repository.convert('BW6E19810C', const []),
        throwsA(isA<ConflictingSelectionsFailure>()),
      );
    });

    test('maps no response to NetworkFailure', () async {
      when(() => remote.convert(any(), any())).thenThrow(dioError());
      expect(
        () => repository.convert('BW6E19810C', const []),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('maps an unrecognised 400 to UnknownFailure', () async {
      when(() => remote.convert(any(), any())).thenThrow(
        dioError(
          statusCode: 400,
          data: {'error': 'invalid_request', 'message': 'Bad.'},
        ),
      );
      expect(
        () => repository.convert('BW6E19810C', const []),
        throwsA(isA<UnknownFailure>()),
      );
    });
  });
}

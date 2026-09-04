import '../../../../core/failure.dart';
import '../../../../models/events_page.dart';
import '../../../../models/fixture.dart';
import '../../../../models/sport.dart';

/// The contract the Create cubits depend on — no imports from `data/` or
/// `presentation/`, per `docs/mobile.md` §3. `CreateRepositoryImpl` is the
/// only implementation; the interface is the seam a fake plugs into in the
/// cubit tests, with no `dio` anywhere near them.
///
/// Every method throws a [Failure] (`core/failure.dart`) on anything but a
/// successful result — never a raw `DioException`.
abstract class CreateRepository {
  /// `GET /api/sports`.
  Future<List<Sport>> sports();

  /// `GET /api/events` — one page of upcoming fixtures for a sport.
  Future<EventsPage> events({required String sport, int limit, int skip});

  /// `GET /api/events/:eventId/markets` — the full market list for one event.
  /// Throws [NotFoundFailure] when the event is unknown or has no priced
  /// markets (upstream `404`).
  Future<List<Market>> eventMarkets(String eventId);

  /// `POST /api/booking-codes` — encode a set of outcomes into a new code.
  /// Throws [TooManyOutcomesFailure] / [OutcomesUnavailableFailure] for the
  /// two actionable `400`s, [NetworkFailure] with no response, else
  /// [UnknownFailure].
  Future<String> create(List<String> outcomeIds);
}

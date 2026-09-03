import '../../../../core/failure.dart';
import '../../../../models/popular_codes_page.dart';
import '../../../../models/slip.dart';

/// The contract `SlipCubit` and `PopularCodesCubit` depend on — no imports
/// from `data/` or `presentation/`, per `docs/mobile.md` §3.
/// `BookingCodeRepositoryImpl` is the only implementation today; the
/// interface is what makes a fake one possible in a Cubit's tests without
/// touching `dio`.
abstract class BookingCodeRepository {
  /// Throws a [Failure] (`core/failure.dart`) on anything but a decoded
  /// slip — never a raw [DioException], never a null result standing in
  /// for "not found".
  Future<Slip> resolve(String code);

  /// `GET /api/booking-codes/popular` — feeds the Decode screen's "try a
  /// code" list. `limit`/`skip` mirror the endpoint's own bounds
  /// (`docs/backend-api.md` §1: `limit` capped at 20, `skip` at 1000).
  Future<PopularCodesPage> popular({int limit = 6, int skip = 0});
}

import '../../../../core/failure.dart';
import '../../../../models/slip.dart';

/// The contract `SlipCubit` depends on — no imports from `data/` or
/// `presentation/`, per `docs/mobile.md` §3. `BookingCodeRepositoryImpl` is
/// the only implementation today; the interface is what makes a fake one
/// possible in `SlipCubit`'s tests without touching `dio`.
abstract class BookingCodeRepository {
  /// Throws a [Failure] (`core/failure.dart`) on anything but a decoded
  /// slip — never a raw [DioException], never a null result standing in
  /// for "not found".
  Future<Slip> resolve(String code);
}

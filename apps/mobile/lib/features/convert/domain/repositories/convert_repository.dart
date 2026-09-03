import '../../../../core/failure.dart';
import '../../../../models/convert_result.dart';
import '../../../../models/slip.dart';

/// The contract `ConvertCubit` depends on — no imports from `data/` or
/// `presentation/` (`docs/mobile.md` §3). Both methods throw a [Failure] on
/// anything but a success, never a raw `DioException`.
abstract class ConvertRepository {
  /// `POST /api/booking-codes/resolve` — throws [InvalidCodeFailure] on `404`.
  Future<Slip> resolve(String code);

  /// `POST /api/booking-codes/convert`. Throws [InvalidCodeFailure] (`404`),
  /// [EmptySlipFailure] (`empty_slip`), [OutcomesUnavailableFailure]
  /// (`outcomes_unavailable`), [ConflictingSelectionsFailure]
  /// (`conflicting_selections`), [NetworkFailure] with no response, else
  /// [UnknownFailure].
  Future<ConvertResult> convert(String code, List<String> dropOutcomeIds);
}

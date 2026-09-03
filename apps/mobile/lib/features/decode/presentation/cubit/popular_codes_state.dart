import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/failure.dart';
import '../../../../models/slip.dart';

part 'popular_codes_state.freezed.dart';

/// Same three-state shape as [SlipState] (`docs/mobile.md` §4) — loading,
/// loaded, or error — for a second, unrelated trigger: this Cubit fetches
/// once on screen load, `SlipCubit` resolves on submit. Kept separate
/// rather than folded into `SlipState` because they track different
/// things: this is "what can I show to try", that is "what did the user
/// ask to decode" — conflating them would make one Cubit's state depend on
/// two independent requests finishing.
@freezed
sealed class PopularCodesState with _$PopularCodesState {
  const factory PopularCodesState.loading() = PopularCodesLoading;
  const factory PopularCodesState.loaded(List<Slip> codes) = PopularCodesLoaded;
  const factory PopularCodesState.error(Failure failure) = PopularCodesError;
}

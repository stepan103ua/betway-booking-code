import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/failure.dart';
import '../../../../models/slip.dart';

part 'slip_state.freezed.dart';

/// `docs/mobile.md` §4, verbatim. `sealed` makes `decode_screen.dart`'s
/// `switch` over this exhaustive at compile time — a fifth state added here
/// without a matching UI branch is a build error, not a silently blank
/// screen.
@freezed
sealed class SlipState with _$SlipState {
  const factory SlipState.initial() = SlipInitial;
  const factory SlipState.loading() = SlipLoading;
  const factory SlipState.loaded(Slip slip) = SlipLoaded;
  const factory SlipState.error(Failure failure) = SlipError;
}

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/failure.dart';
import '../../../../models/slip.dart';

part 'popular_codes_state.freezed.dart';

/// Same shape as [EventsState] (`docs/mobile.md` §4) — loading, loaded (with a
/// `loadingMore` flag so "load more" spins without clearing the list), or
/// error — for a trigger set of its own: this Cubit fetches on screen load and
/// on "load more", `SlipCubit` resolves on submit. Kept separate rather than
/// folded into `SlipState` because they track different things: this is "what
/// can I show to try", that is "what did the user ask to decode".
///
/// Paging is driven by `hasMore` (upstream's own end-of-list flag), never by
/// `codes.length` — the catalogue drops expired codes, so a page can come back
/// short while more remain (`docs/backend-api.md` §1).
@freezed
sealed class PopularCodesState with _$PopularCodesState {
  const factory PopularCodesState.loading() = PopularCodesLoading;

  const factory PopularCodesState.loaded({
    required List<Slip> codes,
    required int total,
    required bool hasMore,
    required int nextSkip,
    @Default(false) bool loadingMore,
    Failure? loadMoreError,
  }) = PopularCodesLoaded;

  const factory PopularCodesState.error(Failure failure) = PopularCodesError;
}

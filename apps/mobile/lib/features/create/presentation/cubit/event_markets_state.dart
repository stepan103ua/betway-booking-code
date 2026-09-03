import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/failure.dart';
import '../../../../models/fixture.dart';

part 'event_markets_state.freezed.dart';

/// The full market list for one event, loaded on demand when the "More
/// markets" sheet opens. [EventMarketsEmpty] is its own state rather than a
/// `loaded([])` because the backend turns "unknown event / nothing priced"
/// into a `404`, which reads as "there is nothing here", not "the list
/// happens to be empty".
@freezed
sealed class EventMarketsState with _$EventMarketsState {
  const factory EventMarketsState.loading() = EventMarketsLoading;

  const factory EventMarketsState.loaded(List<Market> markets) =
      EventMarketsLoaded;

  const factory EventMarketsState.empty() = EventMarketsEmpty;

  const factory EventMarketsState.error(Failure failure) = EventMarketsError;
}

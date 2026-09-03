import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/failure.dart';
import '../../domain/repositories/create_repository.dart';
import 'event_markets_state.dart';

/// Backs the "More markets" bottom sheet — one instance per sheet, created
/// when it opens and disposed with it, so a stale market list never lingers
/// on the next event.
class EventMarketsCubit extends Cubit<EventMarketsState> {
  EventMarketsCubit(this._repository)
    : super(const EventMarketsState.loading());
  final CreateRepository _repository;

  Future<void> load(String eventId) async {
    emit(const EventMarketsState.loading());
    try {
      emit(EventMarketsState.loaded(await _repository.eventMarkets(eventId)));
    } on NotFoundFailure {
      emit(const EventMarketsState.empty());
    } on Failure catch (f) {
      emit(EventMarketsState.error(f));
    }
  }
}

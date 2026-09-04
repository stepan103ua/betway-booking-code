import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../models/fixture.dart';
import '../../../../models/selection.dart';

part 'draft_pick.freezed.dart';

/// One leg the user has added while building a slip, before any code exists.
///
/// This is the UI-only shape `docs/mobile.md` §3 said to hold off on "until
/// Create needs one that isn't what the API returns" — it is exactly that: an
/// aggregate of event + market + outcome that no single endpoint hands back.
/// It lives here in `presentation/`, not `lib/models/`, because `lib/models/`
/// mirrors `docs/backend-api.md` §0 DTOs and this deliberately does not.
@freezed
abstract class DraftPick with _$DraftPick {
  const DraftPick._();

  const factory DraftPick({
    required String outcomeId,
    required String outcomeLabel,
    required String marketName,
    required String eventId,
    required String eventName,
    required String league,
    required String kickoffAt,
    required double odds,
  }) = _DraftPick;

  factory DraftPick.from({
    required Fixture event,
    required Market market,
    required MarketOutcome outcome,
  }) {
    return DraftPick(
      outcomeId: outcome.outcomeId,
      outcomeLabel: outcome.label,
      marketName: market.name,
      eventId: event.eventId,
      eventName: event.name,
      league: event.league,
      kickoffAt: event.kickoffAt,
      odds: outcome.odds,
    );
  }

  /// Renders through the shared [SelectionRow] — always `isActive: true`,
  /// since a pick the user just made cannot be a dead leg yet (the server's
  /// verification is what surfaces one that died, as `outcomes_unavailable`).
  Selection toSelection() {
    return Selection(
      outcomeId: outcomeId,
      eventId: eventId,
      marketName: marketName,
      outcomeName: outcomeLabel,
      eventName: eventName,
      league: league,
      kickoffAt: kickoffAt,
      odds: odds,
      isActive: true,
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../design/tokens/app_colors.dart';
import '../../../../design/tokens/app_typography.dart';
import '../../../../design/widgets/app_button.dart';
import '../../../../design/widgets/app_card.dart';
import '../../../../models/fixture.dart';
import '../../../../widgets/slip/slip_format.dart';
import '../model/draft_pick.dart';
import 'outcome_chip.dart';

/// One fixture in the browse list: name, league and kickoff, the inline 1X2
/// market as three tappable chips, and a way into the full market sheet.
///
/// `GET /api/events` always returns exactly the 1X2 market inline
/// (`docs/backend-api.md` §2), so `event.markets.first` is safe here — but the
/// guard covers a feed that ever changes that.
class EventTile extends StatelessWidget {
  const EventTile({
    super.key,
    required this.event,
    required this.selectedOutcomeIds,
    required this.onToggle,
    required this.onMoreMarkets,
    required this.draftFull,
    required this.eventHasPick,
  });

  final Fixture event;
  final Set<String> selectedOutcomeIds;
  final ValueChanged<DraftPick> onToggle;
  final VoidCallback onMoreMarkets;

  /// Draft is at the 20-leg cap — unselected chips go disabled so the limit is
  /// visible rather than a silently ignored tap.
  final bool draftFull;

  /// This match already has a leg in the draft. A booking code can't hold two
  /// selections on one event, so every other outcome here goes disabled until
  /// that leg is removed (`docs/betway-api.md` §3).
  final bool eventHasPick;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final market = event.markets.isNotEmpty ? event.markets.first : null;
    // 1X2 has a conventional 1 / X / 2 shorthand; nothing in the outcome
    // labels themselves carries it, and the full names are too long for three
    // columns. Any other shape falls back to real labels.
    final isWdw =
        market != null &&
        market.type == 'win-draw-win' &&
        market.outcomes.length == 3;
    const wdwLabels = ['1', 'X', '2'];

    return AppCard(
      padding: AppCardPadding.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            event.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyStrong.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            '${event.league}  ·  ${formatKickoff(event.kickoffAt)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.meta.copyWith(color: colors.textMuted),
          ),
          if (market != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                for (var i = 0; i < market.outcomes.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: OutcomeChip(
                      label: isWdw ? wdwLabels[i] : market.outcomes[i].label,
                      odds: market.outcomes[i].odds,
                      selected: selectedOutcomeIds.contains(
                        market.outcomes[i].outcomeId,
                      ),
                      disabled: draftFull || eventHasPick,
                      expand: true,
                      onTap: () => onToggle(
                        DraftPick.from(
                          event: event,
                          market: market,
                          outcome: market.outcomes[i],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
          if (eventHasPick) ...[
            const SizedBox(height: 8),
            Text(
              'One pick per match — remove it in your slip to choose another.',
              style: AppTypography.meta.copyWith(color: colors.textMuted),
            ),
          ],
          const SizedBox(height: 10),
          AppButton(
            label: 'More markets',
            variant: AppButtonVariant.ghost,
            size: AppButtonSize.sm,
            icon: 'list',
            onPressed: onMoreMarkets,
          ),
        ],
      ),
    );
  }
}

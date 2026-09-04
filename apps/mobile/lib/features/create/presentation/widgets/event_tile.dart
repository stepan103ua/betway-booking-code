import 'package:flutter/material.dart';

import '../../../../design/tokens/app_colors.dart';
import '../../../../design/tokens/app_typography.dart';
import '../../../../design/widgets/app_button.dart';
import '../../../../design/widgets/app_card.dart';
import '../../../../models/fixture.dart';
import '../../../../widgets/slip/slip_format.dart';
import '../model/draft_pick.dart';
import 'outcome_chip.dart';

/// One fixture in the browse list: name, league and kickoff, a market row, and
/// a way into the full market sheet.
///
/// `GET /api/events` returns exactly the 1X2 market inline
/// (`docs/backend-api.md` §2). When this event's draft leg is on that market,
/// the 1X2 row shows it selected. When the leg was picked from "More markets"
/// (a total, a handicap), the inline row can't represent it — so the tile
/// shows that pick as its own chip instead, and the list always reflects
/// what's in the slip.
class EventTile extends StatelessWidget {
  const EventTile({
    super.key,
    required this.event,
    required this.pick,
    required this.onToggle,
    required this.onMoreMarkets,
    required this.draftFull,
  });

  final Fixture event;

  /// This event's leg in the draft, or `null`. A booking code can't hold two
  /// selections on one event (`docs/betway-api.md` §3), so there is at most one.
  final DraftPick? pick;

  final ValueChanged<DraftPick> onToggle;
  final VoidCallback onMoreMarkets;

  /// Draft is at the 20-leg cap — unselected chips go disabled so the limit is
  /// visible rather than a silently ignored tap.
  final bool draftFull;

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

    final pickOnInline =
        pick != null &&
        market != null &&
        market.outcomes.any((o) => o.outcomeId == pick!.outcomeId);
    final pickElsewhere = pick != null && !pickOnInline;

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
          if (pickElsewhere) ...[
            const SizedBox(height: 12),
            Text(
              pick!.marketName,
              style: AppTypography.meta.copyWith(color: colors.textMuted),
            ),
            const SizedBox(height: 6),
            OutcomeChip(
              label: pick!.outcomeLabel,
              odds: pick!.odds,
              selected: true,
              expand: true,
              onTap: () => onToggle(pick!),
            ),
          ] else if (market != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                for (var i = 0; i < market.outcomes.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: OutcomeChip(
                      label: isWdw ? wdwLabels[i] : market.outcomes[i].label,
                      odds: market.outcomes[i].odds,
                      selected: pick?.outcomeId == market.outcomes[i].outcomeId,
                      disabled: draftFull || pick != null,
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
          if (pickOnInline) ...[
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

import 'package:flutter/material.dart';

import '../../../../core/failure.dart';
import '../../../../design/tokens/app_colors.dart';
import '../../../../design/tokens/app_typography.dart';
import '../../../../design/widgets/app_alert.dart';
import '../../../../design/widgets/app_button.dart';
import '../../../../design/widgets/app_card.dart';
import '../../../../widgets/slip/selection_row.dart';
import '../cubit/create_state.dart';
import '../model/draft_pick.dart';

/// The slip being built: the legs picked so far, a running total, and the
/// generate action. Rendered above the fixture list so a new pick and the
/// "Generate" button are both in reach without scrolling.
class DraftTray extends StatelessWidget {
  const DraftTray({
    super.key,
    required this.state,
    required this.onRemove,
    required this.onClear,
    required this.onGenerate,
    required this.onRefreshEvents,
  });

  final CreateReady state;
  final ValueChanged<DraftPick> onRemove;
  final VoidCallback onClear;
  final VoidCallback onGenerate;

  /// Called from the `outcomes_unavailable` alert — reloads the fixture list
  /// so the user can re-pick against fresh odds.
  final VoidCallback onRefreshEvents;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final picks = state.picks;
    final error = state.generateError;

    return AppCard(
      padding: AppCardPadding.none,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'YOUR SLIP',
                        style: AppTypography.label.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${picks.length} ${picks.length == 1 ? 'leg' : 'legs'}',
                        style: AppTypography.meta.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'TOTAL ODDS',
                      style: AppTypography.label.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.totalOdds.toStringAsFixed(2),
                      style: AppTypography.oddsHero.copyWith(
                        color: colors.oddsText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            color: colors.surfaceRow,
            child: Column(
              children: [
                for (var i = 0; i < picks.length; i++)
                  SelectionRow(
                    selection: picks[i].toSelection(),
                    index: i + 1,
                    onRemove: () => onRemove(picks[i]),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (error != null) ...[
                  _GenerateError(
                    error: error,
                    onRefreshEvents: onRefreshEvents,
                  ),
                  const SizedBox(height: 12),
                ],
                if (state.isFull) ...[
                  Text(
                    'Maximum $kMaxDraftPicks legs — remove one to add another.',
                    style: AppTypography.meta.copyWith(color: colors.textMuted),
                  ),
                  const SizedBox(height: 10),
                ],
                Row(
                  children: [
                    AppButton(
                      label: 'Clear',
                      variant: AppButtonVariant.ghost,
                      size: AppButtonSize.md,
                      icon: 'rotate-ccw',
                      onPressed: state.generating ? null : onClear,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppButton(
                        label: 'Generate code',
                        variant: AppButtonVariant.primary,
                        icon: 'wand-sparkles',
                        fullWidth: true,
                        loading: state.generating,
                        onPressed: onGenerate,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GenerateError extends StatelessWidget {
  const _GenerateError({required this.error, required this.onRefreshEvents});
  final Failure error;
  final VoidCallback onRefreshEvents;

  @override
  Widget build(BuildContext context) {
    if (error is OutcomesUnavailableFailure) {
      return AppAlert(
        tone: AppAlertTone.warn,
        title: 'Some selections went off',
        body: error.message,
        action: AppButton(
          label: 'Refresh fixtures',
          variant: AppButtonVariant.secondary,
          size: AppButtonSize.sm,
          icon: 'rotate-ccw',
          onPressed: onRefreshEvents,
        ),
      );
    }
    // TooManyOutcomesFailure (shouldn't reach — capped client-side),
    // NetworkFailure, UnknownFailure: state the message, offer nothing
    // beyond retrying the button above.
    return AppAlert(
      tone: AppAlertTone.danger,
      title: "Couldn't generate a code",
      body: error.message,
    );
  }
}

import 'package:flutter/material.dart';

import '../../design/app_icons.dart';
import '../../design/tokens/app_colors.dart';
import '../../design/tokens/app_spacing.dart';
import '../../design/tokens/app_typography.dart';
import '../../design/widgets/app_badge.dart';
import '../../models/selection.dart';
import 'slip_format.dart';

/// One leg of a slip. Compact enough for 16 rows on a 390px screen —
/// three lines, constant baseline pattern, per the design system's
/// "spacing & rhythm" rule.
///
/// Takes the domain [Selection] directly rather than a separate UI-only
/// shape — `docs/mobile.md` §3 declines a view model distinct from the API
/// model until there's a real divergence to justify it, and formatting a
/// kickoff time or a generic dead-leg reason inline here is exactly the
/// kind of pure, stateless display logic a presentational widget is allowed
/// to own.
class SelectionRow extends StatelessWidget {
  const SelectionRow({
    super.key,
    required this.selection,
    this.index,
    this.showDivider = true,
    this.onRemove,
  });

  final Selection selection;
  final int? index;
  final bool showDivider;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = selection;
    final dead = !s.isActive;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.slipRowPadY,
        horizontal: AppSpacing.slipRowPadX,
      ),
      decoration: BoxDecoration(
        color: dead ? colors.stateStaleSurface : Colors.transparent,
        border: showDivider
            ? Border(top: BorderSide(color: colors.borderSubtle))
            : null,
      ),
      child: Opacity(
        opacity: dead ? 0.72 : 1,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index != null) ...[
              SizedBox(
                width: 18,
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '$index',
                    textAlign: TextAlign.right,
                    style: AppTypography.code.copyWith(
                      fontSize: 11,
                      height: 1.4,
                      color: colors.textDisabled,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    s.eventName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyStrong.copyWith(
                      letterSpacing: -0.015 * 14,
                      color: dead ? colors.stateStaleText : colors.textPrimary,
                      decoration: dead
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: colors.textDisabled,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      AppBadge(
                        label: s.marketName,
                        tone: dead ? AppBadgeTone.stale : AppBadgeTone.neutral,
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 170),
                        child: Text(
                          s.outcomeName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: AppTypography.meta.copyWith(
                            fontWeight: FontWeight.w600,
                            color: dead
                                ? colors.stateStaleText
                                : colors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          s.league,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: AppTypography.meta.copyWith(
                            color: colors.textMuted,
                          ),
                        ),
                      ),
                      Text(
                        '  ·  ',
                        style: AppTypography.meta.copyWith(
                          color: colors.textDisabled,
                        ),
                      ),
                      Text(
                        formatKickoff(s.kickoffAt),
                        style: AppTypography.meta.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  if (dead) ...[
                    const SizedBox(height: 5),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIcon('ban', size: 12, color: colors.dangerText),
                        const SizedBox(width: 5),
                        Text(
                          deadLegReason,
                          style: AppTypography.meta.copyWith(
                            color: colors.dangerText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Row(
                children: [
                  Text(
                    s.odds.toStringAsFixed(2),
                    style: AppTypography.odds.copyWith(
                      color: dead ? colors.textDisabled : colors.oddsText,
                      decoration: dead
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  if (onRemove != null) ...[
                    const SizedBox(width: 8),
                    Semantics(
                      button: true,
                      label: 'Remove ${s.outcomeName}',
                      child: GestureDetector(
                        onTap: onRemove,
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: Center(
                            child: AppIcon(
                              'x',
                              size: 14,
                              color: colors.textDisabled,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

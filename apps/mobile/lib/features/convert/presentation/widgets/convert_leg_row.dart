import 'package:flutter/material.dart';

import '../../../../design/app_icons.dart';
import '../../../../design/tokens/app_colors.dart';
import '../../../../design/tokens/app_motion.dart';
import '../../../../design/tokens/app_radius.dart';
import '../../../../design/tokens/app_spacing.dart';
import '../../../../design/tokens/app_typography.dart';
import '../../../../design/widgets/app_badge.dart';
import '../../../../models/selection.dart';
import '../../../../widgets/slip/slip_format.dart';

/// One leg in the Convert list: a keep/drop toggle, the selection, its odds.
///
/// Styled to match `SelectionRow` (`widgets/slip/`) rather than reusing it —
/// that widget's whole model of "struck through" is `!isActive`, and Convert
/// needs a third state: a *live* leg the user chose to drop. Built directly on
/// [Selection], the same rule `SelectionRow` follows.
class ConvertLegRow extends StatelessWidget {
  const ConvertLegRow({
    super.key,
    required this.selection,
    required this.dropped,
    this.onToggle,
  });

  final Selection selection;

  /// Not in the new code — the user unchecked a live leg, or it's dead.
  final bool dropped;

  /// `null` for dead legs: they are always dropped, there is nothing to toggle.
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = selection;
    final dead = !s.isActive;
    final muted = dropped || dead;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.slipRowPadY,
        horizontal: AppSpacing.slipRowPadX,
      ),
      decoration: BoxDecoration(
        color: muted ? colors.stateStaleSurface : Colors.transparent,
        border: Border(top: BorderSide(color: colors.borderSubtle)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: _DropToggle(
              kept: !dropped,
              enabled: onToggle != null,
              onTap: onToggle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Opacity(
              opacity: muted ? 0.72 : 1,
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
                      color: muted ? colors.stateStaleText : colors.textPrimary,
                      decoration: muted
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
                        tone: muted ? AppBadgeTone.stale : AppBadgeTone.neutral,
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 170),
                        child: Text(
                          s.outcomeName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: AppTypography.meta.copyWith(
                            fontWeight: FontWeight.w600,
                            color: muted
                                ? colors.stateStaleText
                                : colors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${s.league}  ·  ${formatKickoff(s.kickoffAt)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.meta.copyWith(color: colors.textMuted),
                  ),
                  if (dead) ...[
                    const SizedBox(height: 5),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIcon('ban', size: 12, color: colors.dangerText),
                        const SizedBox(width: 5),
                        Text(
                          '$deadLegReason — dropped automatically',
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
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              s.odds.toStringAsFixed(2),
              style: AppTypography.odds.copyWith(
                color: muted ? colors.textDisabled : colors.oddsText,
                decoration: muted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A small keep/drop square. Kept = accent fill + check; dropped = empty
/// outline. Disabled (dead legs) reads as a permanently-dropped state.
class _DropToggle extends StatelessWidget {
  const _DropToggle({required this.kept, required this.enabled, this.onTap});

  final bool kept;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      checked: kept,
      label: kept ? 'Keep this leg' : 'Dropped',
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: GestureDetector(
          onTap: enabled ? onTap : null,
          behavior: HitTestBehavior.opaque,
          // 20pt square, but a 44pt tap target around it — the design
          // system's non-negotiable minimum for anything tappable.
          child: SizedBox(
            width: 28,
            height: 40,
            child: Align(
              alignment: Alignment.topCenter,
              child: AnimatedContainer(
                duration: AppMotion.fast,
                curve: AppMotion.easeOut,
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: kept ? colors.accentSolid : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  border: Border.all(
                    color: kept ? colors.accentSolid : colors.borderStrong,
                  ),
                ),
                alignment: Alignment.center,
                child: kept
                    ? AppIcon('check', size: 13, color: colors.textOnAccent)
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

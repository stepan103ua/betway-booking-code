import 'package:flutter/material.dart';

import '../../../../design/app_icons.dart';
import '../../../../design/tokens/app_colors.dart';
import '../../../../design/tokens/app_motion.dart';
import '../../../../design/tokens/app_radius.dart';
import '../../../../design/tokens/app_typography.dart';

/// One tappable outcome — a label and its odds — used both in an event tile's
/// inline 1X2 row and in the "All markets" sheet. Selected legs carry the
/// accent border/fill; the odds stay in the mono odds face either way, the
/// same treatment `SelectionRow` gives them.
class OutcomeChip extends StatelessWidget {
  const OutcomeChip({
    super.key,
    required this.label,
    required this.odds,
    required this.selected,
    required this.onTap,
    this.disabled = false,
    this.expand = false,
  });

  final String label;
  final double odds;
  final bool selected;
  final bool disabled;

  /// `true` in the inline 1X2 row (three equal columns); `false` in the sheet,
  /// where chips wrap to their content.
  final bool expand;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final off = disabled && !selected;

    final chip = AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? colors.accentQuiet : colors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: selected ? colors.accentSolid : colors.borderStrong,
        ),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: expand
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.meta.copyWith(
                fontWeight: FontWeight.w600,
                color: selected ? colors.accentText : colors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            odds.toStringAsFixed(2),
            style: AppTypography.odds.copyWith(
              fontSize: 12,
              color: selected ? colors.accentText : colors.oddsText,
            ),
          ),
          if (selected) ...[
            const SizedBox(width: 6),
            AppIcon('check', size: 12, color: colors.accentText),
          ],
        ],
      ),
    );

    return Semantics(
      button: true,
      selected: selected,
      label: '$label at ${odds.toStringAsFixed(2)}',
      child: Opacity(
        opacity: off ? 0.4 : 1,
        child: GestureDetector(
          onTap: off ? null : onTap,
          child: expand ? chip : IntrinsicWidth(child: chip),
        ),
      ),
    );
  }
}

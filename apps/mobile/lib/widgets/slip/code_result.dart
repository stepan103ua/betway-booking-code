import 'package:flutter/material.dart';

import '../../design/app_icons.dart';
import '../../design/tokens/app_colors.dart';
import '../../design/tokens/app_radius.dart';
import '../../design/tokens/app_typography.dart';
import '../../design/widgets/app_badge.dart';
import '../../design/widgets/app_button.dart';
import '../../design/widgets/app_card.dart';
import '../../design/widgets/dashed_border.dart';

/// Post-generation panel: the new code with copy / share / open-in-Betway.
/// "Code ready" — then the code, and copy/share. That is the whole
/// celebration (design system readme, on tone).
///
/// Not called from anywhere right now — Create and Convert, the two
/// screens that would show a freshly generated code, are placeholders until
/// each has a real `data/` layer (`docs/mobile.md` §2–§7). Left in place
/// rather than deleted: it's a ported design-system component, already
/// correct, and it's the first thing either screen's real version reaches
/// for.
class CodeResult extends StatelessWidget {
  const CodeResult({
    super.key,
    required this.code,
    required this.totalOdds,
    required this.selectionCount,
    this.expiresIn,
    this.onCopy,
    this.onShare,
    this.onOpenInBetway,
    this.copied = false,
  });

  final String code;
  final double totalOdds;
  final int selectionCount;
  final String? expiresIn;
  final VoidCallback? onCopy;
  final VoidCallback? onShare;
  final VoidCallback? onOpenInBetway;
  final bool copied;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      padding: AppCardPadding.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon('check', size: 14, color: colors.accentText),
              const SizedBox(width: 8),
              Text(
                'CODE READY',
                style: AppTypography.label.copyWith(color: colors.accentText),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DashedRoundedBorder(
            color: colors.borderDashed,
            radius: AppRadius.md,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: colors.surfaceSunken,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      code,
                      style: AppTypography.codeHero.copyWith(
                        color: colors.codeText,
                      ),
                    ),
                  ),
                  AppButton(
                    label: copied ? 'Copied' : 'Copy',
                    variant: copied
                        ? AppButtonVariant.primary
                        : AppButtonVariant.secondary,
                    size: AppButtonSize.sm,
                    icon: copied ? 'check' : 'copy',
                    onPressed: onCopy,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppBadge(
                label: totalOdds.toStringAsFixed(2),
                tone: AppBadgeTone.accent,
                mono: true,
              ),
              Text(
                '$selectionCount selections',
                style: AppTypography.meta.copyWith(color: colors.textMuted),
              ),
              if (expiresIn != null) ...[
                Text(
                  '·',
                  style: AppTypography.meta.copyWith(
                    color: colors.textDisabled,
                  ),
                ),
                Text(
                  expiresIn!,
                  style: AppTypography.meta.copyWith(color: colors.textMuted),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Load in Betway',
                  variant: AppButtonVariant.primary,
                  icon: 'external-link',
                  onPressed: onOpenInBetway,
                ),
              ),
              const SizedBox(width: 8),
              AppButton(
                label: 'Share',
                variant: AppButtonVariant.secondary,
                icon: 'share-2',
                onPressed: onShare,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

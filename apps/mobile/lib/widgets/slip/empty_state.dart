import 'package:flutter/material.dart';

import '../../design/app_icons.dart';
import '../../design/tokens/app_colors.dart';
import '../../design/tokens/app_radius.dart';
import '../../design/tokens/app_typography.dart';
import '../../design/widgets/dashed_border.dart';

/// Quiet placeholder for "no slip yet" / "no selections yet".
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.icon = 'scan-line',
    required this.title,
    this.body,
    this.action,
  });

  final String icon;
  final String title;
  final String? body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DashedRoundedBorder(
      color: colors.borderDashed,
      radius: AppRadius.lg,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(icon, size: 22, color: colors.textDisabled),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.h3.copyWith(
                letterSpacing: -0.015 * 16,
                color: colors.textPrimary,
              ),
            ),
            if (body != null) ...[
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Text(
                  body!,
                  textAlign: TextAlign.center,
                  style: AppTypography.meta.copyWith(
                    color: colors.textMuted,
                    height: 1.55,
                  ),
                ),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}

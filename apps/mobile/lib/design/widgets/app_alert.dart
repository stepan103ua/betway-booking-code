import 'package:flutter/material.dart';

import '../app_icons.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';

enum AppAlertTone { danger, warn, info, success }

/// Inline explanatory message. Always says what to do next, never just what
/// failed — see the design system readme's "Errors name the fix" rule; the
/// copy passed into [body] should already follow it.
class AppAlert extends StatelessWidget {
  const AppAlert({
    super.key,
    this.title,
    this.body,
    this.tone = AppAlertTone.info,
    this.icon,
    this.action,
  });

  final String? title;
  final String? body;
  final AppAlertTone tone;
  final String? icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (fg, bg, border, defaultIcon) = switch (tone) {
      AppAlertTone.danger => (
        colors.dangerText,
        colors.dangerQuiet,
        colors.dangerSolid,
        'triangle-alert',
      ),
      AppAlertTone.warn => (
        colors.warnText,
        colors.warnQuiet,
        colors.warnSolid,
        'clock',
      ),
      AppAlertTone.info => (
        colors.infoText,
        colors.infoQuiet,
        colors.infoText,
        'info',
      ),
      AppAlertTone.success => (
        colors.accentText,
        colors.accentQuiet,
        colors.accentSolid,
        'check',
      ),
    };

    return Semantics(
      liveRegion: tone == AppAlertTone.danger,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: AppIcon(icon ?? defaultIcon, size: 16, color: fg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: AppTypography.bodyStrong.copyWith(
                        color: fg,
                        letterSpacing: -0.015 * 14,
                      ),
                    ),
                  if (body != null) ...[
                    if (title != null) const SizedBox(height: 4),
                    Text(
                      body!,
                      style: AppTypography.meta.copyWith(
                        color: colors.textSecondary,
                        height: 1.55,
                      ),
                    ),
                  ],
                  if (action != null) ...[const SizedBox(height: 6), action!],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

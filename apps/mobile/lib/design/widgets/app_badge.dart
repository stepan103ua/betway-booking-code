import 'package:flutter/material.dart';

import '../app_icons.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';

enum AppBadgeTone { neutral, accent, danger, warn, info, stale }

enum AppBadgeVariant { quiet, solid, outline }

enum AppBadgeSize { sm, md }

/// Small status pill: market names, slip status, counters.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.tone = AppBadgeTone.neutral,
    this.variant = AppBadgeVariant.quiet,
    this.size = AppBadgeSize.sm,
    this.icon,
    this.mono = false,
  });

  final String label;
  final AppBadgeTone tone;
  final AppBadgeVariant variant;
  final AppBadgeSize size;
  final String? icon;
  final bool mono;

  (Color, Color) _tone(AppColors colors) {
    final solid = variant == AppBadgeVariant.solid;
    return switch (tone) {
      AppBadgeTone.neutral => (
        solid ? colors.textSecondary : colors.surfaceHover,
        solid ? colors.textOnAccent : colors.textSecondary,
      ),
      AppBadgeTone.accent => (
        solid ? colors.accentSolid : colors.accentQuiet,
        solid ? colors.textOnAccent : colors.accentText,
      ),
      AppBadgeTone.danger => (
        solid ? colors.dangerSolid : colors.dangerQuiet,
        solid ? colors.textOnAccent : colors.dangerText,
      ),
      AppBadgeTone.warn => (
        solid ? colors.warnSolid : colors.warnQuiet,
        solid ? colors.textOnAccent : colors.warnText,
      ),
      AppBadgeTone.info => (
        solid ? colors.infoText : colors.infoQuiet,
        solid ? colors.textOnAccent : colors.infoText,
      ),
      AppBadgeTone.stale => (
        solid ? colors.textDisabled : colors.stateStaleSurface,
        solid ? colors.textOnAccent : colors.stateStaleText,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final outline = variant == AppBadgeVariant.outline;
    final (bg, fg) = _tone(colors);
    final small = size == AppBadgeSize.sm;
    final font = mono ? AppTypography.code : AppTypography.bodyStrong;

    return Container(
      height: small ? 20 : 26,
      padding: EdgeInsets.symmetric(horizontal: small ? 7 : 10),
      decoration: BoxDecoration(
        color: outline ? Colors.transparent : bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: outline ? Border.all(color: colors.borderStrong) : null,
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            AppIcon(
              icon!,
              size: small ? 11 : 13,
              color: outline ? colors.textSecondary : fg,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: font.copyWith(
              fontSize: small ? (mono ? 11 : 11) : 12,
              color: outline ? colors.textSecondary : fg,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

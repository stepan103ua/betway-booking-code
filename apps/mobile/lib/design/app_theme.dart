import 'package:flutter/material.dart';

import 'tokens/app_colors.dart';
import 'tokens/app_radius.dart';
import 'tokens/app_typography.dart';

/// Builds the two [ThemeData]s the app switches between. Dark is the
/// product default (`docs/mobile.md` doesn't pick a default; the design
/// system does, explicitly — "Dark is the default").
abstract final class AppTheme {
  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);
  static ThemeData light() => _build(AppColors.light, Brightness.light);

  static ThemeData _build(AppColors colors, Brightness brightness) {
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: colors.surfaceApp,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      // Flat surfaces throughout — the design system separates layers with a
      // 1px hairline plus a step in surface lightness, not Material shadow.
      // The `card` package widget (`AppCard`) draws its own hairline instead
      // of reaching for `CardTheme`'s elevation.
      textTheme: TextTheme(
        bodyMedium: AppTypography.body.copyWith(color: colors.textPrimary),
      ),
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.accentSolid,
        onPrimary: colors.textOnAccent,
        secondary: colors.accentSolid,
        onSecondary: colors.textOnAccent,
        error: colors.dangerSolid,
        onError: colors.textOnAccent,
        surface: colors.surfaceCard,
        onSurface: colors.textPrimary,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.accentSolid,
        selectionColor: colors.accentQuiet,
        selectionHandleColor: colors.accentSolid,
      ),
      focusColor: colors.focusRing,
      dividerColor: colors.borderSubtle,
      extensions: [colors],
    );
  }
}

/// Shared corner shapes, so `RoundedRectangleBorder(...)` isn't retyped at
/// every call site.
abstract final class AppShapes {
  static BorderRadius get card => BorderRadius.circular(AppRadius.lg);
  static BorderRadius get control => BorderRadius.circular(AppRadius.md);
  static BorderRadius get tile => BorderRadius.circular(AppRadius.sm);
  static BorderRadius get sheetTop =>
      const BorderRadius.vertical(top: Radius.circular(AppRadius.xl));
}

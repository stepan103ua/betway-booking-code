import 'package:flutter/material.dart';

/// Semantic color tokens, ported 1:1 from `tokens/colors.css` in the Booking Code
/// Studio design system. Dark is the product default; [light] flips every alias the
/// same way `[data-theme="light"]` does in the source CSS — the ink/paper/lime/red/
/// amber/blue base values never change, only which alias points at which one.
///
/// Registered as a [ThemeExtension] so every widget reads it via
/// `Theme.of(context).extension<AppColors>()!` (or the `context.colors` getter
/// below) instead of importing this file's constants directly — the same seam
/// `ThemeData.colorScheme` would play if Material's own roles fit this brand.
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.surfaceApp,
    required this.surfaceCard,
    required this.surfaceRaised,
    required this.surfaceRow,
    required this.surfaceSunken,
    required this.surfaceInput,
    required this.surfaceHover,
    required this.surfacePress,
    required this.surfaceSkeleton,
    required this.borderSubtle,
    required this.borderStrong,
    required this.borderInput,
    required this.borderDashed,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textDisabled,
    required this.textOnAccent,
    required this.accentSolid,
    required this.accentHover,
    required this.accentPress,
    required this.accentQuiet,
    required this.accentText,
    required this.oddsText,
    required this.codeText,
    required this.stateStaleText,
    required this.stateStaleSurface,
    required this.dangerSolid,
    required this.dangerText,
    required this.dangerQuiet,
    required this.warnSolid,
    required this.warnText,
    required this.warnQuiet,
    required this.infoText,
    required this.infoQuiet,
    required this.focusRing,
    required this.overlayScrim,
  });

  final Color surfaceApp;
  final Color surfaceCard;
  final Color surfaceRaised;
  final Color surfaceRow;
  final Color surfaceSunken;
  final Color surfaceInput;
  final Color surfaceHover;
  final Color surfacePress;
  final Color surfaceSkeleton;

  final Color borderSubtle;
  final Color borderStrong;
  final Color borderInput;
  final Color borderDashed;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textDisabled;
  final Color textOnAccent;

  final Color accentSolid;
  final Color accentHover;
  final Color accentPress;
  final Color accentQuiet;
  final Color accentText;

  final Color oddsText;
  final Color codeText;

  final Color stateStaleText;
  final Color stateStaleSurface;

  final Color dangerSolid;
  final Color dangerText;
  final Color dangerQuiet;
  final Color warnSolid;
  final Color warnText;
  final Color warnQuiet;
  final Color infoText;
  final Color infoQuiet;

  final Color focusRing;
  final Color overlayScrim;

  // ---- base palette (colors.css :root) ----
  static const _ink950 = Color(0xFF08090A);
  static const _ink900 = Color(0xFF0E0F11);
  static const _ink850 = Color(0xFF151719);
  static const _ink800 = Color(0xFF1B1D20);
  static const _ink750 = Color(0xFF22252A);
  static const _ink700 = Color(0xFF2A2E34);

  static const _paper0 = Color(0xFFFFFFFF);
  static const _paper50 = Color(0xFFF7F7F4);
  static const _paper100 = Color(0xFFEFEFEA);

  static const _fg1 = Color(0xFFF4F5F6);
  static const _fg2 = Color(0xFFA8ADB4);
  static const _fg3 = Color(0xFF71777E);
  static const _fg4 = Color(0xFF4B5057);
  static const _fgInverse1 = Color(0xFF0E0F11);

  static const lime400 = Color(0xFFE2FF7A);
  static const lime500 = Color(0xFFCFF54A);
  static const lime600 = Color(0xFFB7DE2E);
  static const lime700 = Color(0xFF93B420);
  static const _limeTint = Color(0x1ACFF54A); // #CFF54A1A
  static const _limeTintLight = Color(0x33CFF54A); // #CFF54A33

  static const red500 = Color(0xFFFF6152);
  static const red600 = Color(0xFFE2412F);
  static const _redTint = Color(0x1FFF6152); // #FF61521F
  static const _redTintLight = Color(0x1AFF6152); // #FF61521A
  static const amber500 = Color(0xFFFFB84D);
  static const _amberTint = Color(0x1FFFB84D); // #FFB84D1F
  static const _amberTintLight = Color(0x2EFFB84D); // #FFB84D2E
  static const blue500 = Color(0xFF6EA8FF);
  static const _blueTint = Color(0x1F6EA8FF); // #6EA8FF1F

  /// Dark theme — the product default. Values match `colors.css :root`.
  static const dark = AppColors(
    surfaceApp: _ink950,
    surfaceCard: _ink850,
    surfaceRaised: _ink800,
    surfaceRow: _ink900,
    surfaceSunken: Color(0xFF000000),
    surfaceInput: _ink850,
    surfaceHover: _ink750,
    surfacePress: _ink700,
    surfaceSkeleton: _ink750,
    borderSubtle: Color(0x14FFFFFF),
    borderStrong: Color(0x29FFFFFF),
    borderInput: Color(0x1FFFFFFF),
    borderDashed: Color(0x33FFFFFF),
    textPrimary: _fg1,
    textSecondary: _fg2,
    textMuted: _fg3,
    textDisabled: _fg4,
    textOnAccent: _ink950,
    accentSolid: lime500,
    accentHover: lime400,
    accentPress: lime600,
    accentQuiet: _limeTint,
    accentText: lime500,
    oddsText: lime500,
    codeText: _fg1,
    stateStaleText: _fg3,
    stateStaleSurface: Color(0x08FFFFFF),
    dangerSolid: red500,
    dangerText: red500,
    dangerQuiet: _redTint,
    warnSolid: amber500,
    warnText: amber500,
    warnQuiet: _amberTint,
    infoText: blue500,
    infoQuiet: _blueTint,
    focusRing: lime500,
    overlayScrim: Color(0xA6000000),
  );

  /// Light theme — a paper ramp, same lime, darkened where it needs to sit on white.
  static const light = AppColors(
    surfaceApp: _paper50,
    surfaceCard: _paper0,
    surfaceRaised: _paper0,
    surfaceRow: _paper0,
    surfaceSunken: _paper100,
    surfaceInput: _paper0,
    surfaceHover: _paper100,
    surfacePress: Color(0xFFE2E2DC), // paper-200
    surfaceSkeleton: _paper100,
    borderSubtle: Color(0x140E0F11),
    borderStrong: Color(0x290E0F11),
    borderInput: Color(0x240E0F11),
    borderDashed: Color(0x330E0F11),
    textPrimary: _fgInverse1,
    textSecondary: Color(0xFF5A5F66),
    textMuted: Color(0xFF82878E),
    textDisabled: Color(0xFFAEB2B8),
    textOnAccent: _ink950,
    accentSolid: lime500,
    accentHover: lime400,
    accentPress: lime600,
    accentQuiet: _limeTintLight,
    accentText: lime700,
    oddsText: lime700,
    codeText: _fgInverse1,
    stateStaleText: Color(0xFF82878E),
    stateStaleSurface: Color(0x080E0F11),
    dangerSolid: red500,
    dangerText: red600,
    dangerQuiet: _redTintLight,
    warnSolid: amber500,
    warnText: Color(0xFF8A6410),
    warnQuiet: _amberTintLight,
    infoText: Color(0xFF2F6BD1),
    infoQuiet: _blueTint,
    focusRing: lime500,
    overlayScrim: Color(0x590E0F11),
  );

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color m(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      surfaceApp: m(surfaceApp, other.surfaceApp),
      surfaceCard: m(surfaceCard, other.surfaceCard),
      surfaceRaised: m(surfaceRaised, other.surfaceRaised),
      surfaceRow: m(surfaceRow, other.surfaceRow),
      surfaceSunken: m(surfaceSunken, other.surfaceSunken),
      surfaceInput: m(surfaceInput, other.surfaceInput),
      surfaceHover: m(surfaceHover, other.surfaceHover),
      surfacePress: m(surfacePress, other.surfacePress),
      surfaceSkeleton: m(surfaceSkeleton, other.surfaceSkeleton),
      borderSubtle: m(borderSubtle, other.borderSubtle),
      borderStrong: m(borderStrong, other.borderStrong),
      borderInput: m(borderInput, other.borderInput),
      borderDashed: m(borderDashed, other.borderDashed),
      textPrimary: m(textPrimary, other.textPrimary),
      textSecondary: m(textSecondary, other.textSecondary),
      textMuted: m(textMuted, other.textMuted),
      textDisabled: m(textDisabled, other.textDisabled),
      textOnAccent: m(textOnAccent, other.textOnAccent),
      accentSolid: m(accentSolid, other.accentSolid),
      accentHover: m(accentHover, other.accentHover),
      accentPress: m(accentPress, other.accentPress),
      accentQuiet: m(accentQuiet, other.accentQuiet),
      accentText: m(accentText, other.accentText),
      oddsText: m(oddsText, other.oddsText),
      codeText: m(codeText, other.codeText),
      stateStaleText: m(stateStaleText, other.stateStaleText),
      stateStaleSurface: m(stateStaleSurface, other.stateStaleSurface),
      dangerSolid: m(dangerSolid, other.dangerSolid),
      dangerText: m(dangerText, other.dangerText),
      dangerQuiet: m(dangerQuiet, other.dangerQuiet),
      warnSolid: m(warnSolid, other.warnSolid),
      warnText: m(warnText, other.warnText),
      warnQuiet: m(warnQuiet, other.warnQuiet),
      infoText: m(infoText, other.infoText),
      infoQuiet: m(infoQuiet, other.infoQuiet),
      focusRing: m(focusRing, other.focusRing),
      overlayScrim: m(overlayScrim, other.overlayScrim),
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Composed type roles from `tokens/typography.css`. Each `TextStyle` mirrors
/// one `--type-*` custom property — size, weight, line-height, family and
/// tracking — but never color: the CSS keeps `font:` and `color:` as separate
/// declarations, and this does the same, so a widget applies
/// `AppTypography.body.copyWith(color: colors.textPrimary)` rather than baking
/// one fixed color into a role two different screens tint differently (the
/// `odds` role is `oddsText` on a live leg and `textDisabled`, struck through,
/// on a dead one — same `TextStyle`, different color at the call site).
///
/// Font substitution: no binaries were supplied with the design system, so —
/// same as the web build's `tokens/fonts.css` — Archivo and JetBrains Mono
/// come from Google Fonts (`google_fonts` package) rather than bundled
/// `@font-face`/asset files. Swap this file for local `FontLoader` calls if
/// real binaries ever arrive.
abstract final class AppTypography {
  static TextStyle get display => GoogleFonts.archivo(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.05,
    letterSpacing: -0.03 * 40,
  );

  static TextStyle get h1 => GoogleFonts.archivo(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.015 * 24,
  );

  static TextStyle get h2 => GoogleFonts.archivo(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static TextStyle get h3 => GoogleFonts.archivo(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static TextStyle get body => GoogleFonts.archivo(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static TextStyle get bodyStrong => GoogleFonts.archivo(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.015 * 14,
  );

  static TextStyle get meta => GoogleFonts.archivo(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  /// Uppercase micro-label. `textTransform: uppercase` has no CSS equivalent
  /// property in Flutter — callers wrap the string in `.toUpperCase()`.
  static TextStyle get label => GoogleFonts.archivo(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.08 * 11,
  );

  static TextStyle get odds => GoogleFonts.jetBrainsMono(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1,
    letterSpacing: 0.06 * 16,
  );

  static TextStyle get oddsHero => GoogleFonts.jetBrainsMono(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1,
    letterSpacing: 0.06 * 32,
  );

  static TextStyle get code => GoogleFonts.jetBrainsMono(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.06 * 14,
  );

  static TextStyle get codeHero => GoogleFonts.jetBrainsMono(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: 0.06 * 24,
  );
}

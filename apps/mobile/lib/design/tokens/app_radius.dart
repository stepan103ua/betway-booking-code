/// Corner radii. Every one is uniform on all four corners on purpose — the
/// ported design system's own constraint was "no squircles, no per-corner
/// tricks", specifically because Flutter's `BorderRadius` has to express
/// the identical shape. `sheetTop` is the one exception: a bottom sheet
/// rounds only its top two corners.
///
/// Rounder than `tokens/radius.css`'s source values (4/6/10/14/20/28) by
/// deliberate choice for this app — a flat request to make the UI feel
/// less square, not a value ported from anywhere. Change the numbers here
/// and every card, button, input and sheet picks it up; nothing below this
/// file should hardcode a radius.
abstract final class AppRadius {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 18;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;
  static const double pill = 999;

  static const double borderWidth = 1;
  static const double borderWidthThick = 2;
}

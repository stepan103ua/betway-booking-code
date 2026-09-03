import 'package:flutter/animation.dart';

/// Timings from `tokens/motion.css`. One curve for almost everything —
/// `easeOut` — plus a slower cubic for the sheet. No bounce, no spring: the
/// design system is explicit that this product doesn't call attention to
/// itself in motion.
abstract final class AppMotion {
  static const Duration instant = Duration(milliseconds: 80);
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration base = Duration(milliseconds: 180);
  static const Duration slow = Duration(milliseconds: 240);
  static const Duration sheet = Duration(milliseconds: 280);
  static const Duration skeleton = Duration(milliseconds: 1400);

  static const Curve easeOut = Cubic(0.2, 0.8, 0.2, 1);
  static const Curve easeInOut = Cubic(0.4, 0, 0.2, 1);
}

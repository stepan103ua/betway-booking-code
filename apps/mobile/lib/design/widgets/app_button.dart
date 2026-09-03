import 'package:flutter/material.dart';

import '../app_icons.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_motion.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

enum AppButtonSize { sm, md, lg }

/// The one button. One `primary` per screen — it and the odds are the only
/// lime pixels on the page (design system readme, "one-accent rule").
///
/// Deliberately not `ElevatedButton`/`OutlinedButton`: Material's defaults
/// bring elevation and a ripple that this flat, near-monochrome surface
/// doesn't want, so this builds the exact border/fill/press states from
/// tokens instead of overriding a `ButtonStyle` back to nothing.
///
/// Pill by default — every button in the app takes the fully-rounded shape
/// unless a call site opts out with `pill: false`. Nothing currently does;
/// the flag stays for a future control that specifically needs the
/// size-based radius instead (a toolbar button sitting flush against a
/// square card edge, say).
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    this.variant = AppButtonVariant.secondary,
    this.size = AppButtonSize.md,
    this.fullWidth = false,
    this.disabled = false,
    this.loading = false,
    this.icon,
    this.iconRight,
    this.pill = true,
    this.onPressed,
  });

  final String label;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool fullWidth;
  final bool disabled;
  final bool loading;
  final String? icon;
  final String? iconRight;
  final bool pill;
  final VoidCallback? onPressed;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final off = widget.disabled || widget.loading;

    final (
      double height,
      double padX,
      TextStyle font,
      double iconSize,
      double gap,
      double radius,
    ) = switch (widget.size) {
      AppButtonSize.sm => (
        32.0,
        12.0,
        AppTypography.body.copyWith(fontSize: 12),
        14.0,
        6.0,
        AppRadius.sm,
      ),
      AppButtonSize.md => (
        40.0,
        16.0,
        AppTypography.body.copyWith(fontSize: 14),
        16.0,
        8.0,
        AppRadius.md,
      ),
      AppButtonSize.lg => (
        48.0,
        20.0,
        AppTypography.body.copyWith(fontSize: 16),
        18.0,
        8.0,
        AppRadius.md,
      ),
    };

    final (
      Color background,
      Color foreground,
      Color? border,
    ) = switch (widget.variant) {
      AppButtonVariant.primary => (
        _pressed ? colors.accentPress : colors.accentSolid,
        colors.textOnAccent,
        null,
      ),
      AppButtonVariant.secondary => (
        _pressed ? colors.surfacePress : colors.surfaceRaised,
        colors.textPrimary,
        colors.borderStrong,
      ),
      AppButtonVariant.ghost => (
        _pressed ? colors.surfaceHover : Colors.transparent,
        colors.textSecondary,
        null,
      ),
      AppButtonVariant.danger => (
        colors.dangerQuiet,
        colors.dangerText,
        colors.dangerSolid,
      ),
    };

    Widget content = Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.loading)
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: _Spinner(color: foreground, size: iconSize),
          )
        else if (widget.icon != null)
          AppIcon(widget.icon!, size: iconSize, color: foreground),
        if (widget.loading || widget.icon != null) SizedBox(width: gap),
        Flexible(
          child: Text(
            widget.label,
            style: font.copyWith(
              fontWeight: FontWeight.w600,
              color: foreground,
              letterSpacing: -0.015 * font.fontSize!,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (widget.iconRight != null) ...[
          SizedBox(width: gap),
          AppIcon(widget.iconRight!, size: iconSize, color: foreground),
        ],
      ],
    );

    return Opacity(
      opacity: off && !widget.loading ? 0.45 : 1,
      child: GestureDetector(
        onTapDown: off ? null : (_) => setState(() => _pressed = true),
        onTapUp: off ? null : (_) => setState(() => _pressed = false),
        onTapCancel: off ? null : () => setState(() => _pressed = false),
        onTap: off ? null : widget.onPressed,
        child: AnimatedScale(
          scale: _pressed && !off ? 0.985 : 1,
          duration: AppMotion.fast,
          curve: AppMotion.easeOut,
          child: AnimatedContainer(
            duration: AppMotion.fast,
            curve: AppMotion.easeOut,
            height: height,
            constraints: BoxConstraints(minWidth: height),
            width: widget.fullWidth ? double.infinity : null,
            padding: EdgeInsets.symmetric(horizontal: padX),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(
                widget.pill ? AppRadius.pill : radius,
              ),
              border: border != null ? Border.all(color: border) : null,
            ),
            alignment: Alignment.center,
            child: content,
          ),
        ),
      ),
    );
  }
}

class _Spinner extends StatefulWidget {
  const _Spinner({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  State<_Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<_Spinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: AppIcon('loader-circle', size: widget.size, color: widget.color),
    );
  }
}

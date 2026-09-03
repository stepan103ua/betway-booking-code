import 'package:flutter/material.dart';

import '../app_icons.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_motion.dart';

enum AppIconButtonVariant { ghost, solid, accent }

enum AppIconButtonSize { sm, md, lg }

/// Circular, icon-only tap target — back, close, copy, share. `label` is
/// required, not optional: every instance of this in the source system
/// carries an `aria-label`, and Flutter's [Semantics.label] is the same
/// contract, so there is no way to construct one without it.
class AppIconButton extends StatefulWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.label,
    this.size = AppIconButtonSize.md,
    this.variant = AppIconButtonVariant.ghost,
    this.disabled = false,
    this.onPressed,
  });

  final String icon;
  final String label;
  final AppIconButtonSize size;
  final AppIconButtonVariant variant;
  final bool disabled;
  final VoidCallback? onPressed;

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (double box, double iconSize) = switch (widget.size) {
      AppIconButtonSize.sm => (32.0, 16.0),
      AppIconButtonSize.md => (40.0, 18.0),
      AppIconButtonSize.lg => (44.0, 20.0),
    };

    var background = switch (widget.variant) {
      AppIconButtonVariant.solid => colors.surfaceRaised,
      AppIconButtonVariant.accent => colors.accentSolid,
      AppIconButtonVariant.ghost => colors.surfaceHover,
    };
    var foreground = switch (widget.variant) {
      AppIconButtonVariant.solid => colors.textPrimary,
      AppIconButtonVariant.accent => colors.textOnAccent,
      AppIconButtonVariant.ghost => colors.textSecondary,
    };
    final border = widget.variant == AppIconButtonVariant.solid
        ? colors.borderStrong
        : null;

    if (_pressed && !widget.disabled) {
      background = widget.variant == AppIconButtonVariant.accent
          ? colors.accentHover
          : colors.surfacePress;
      if (widget.variant != AppIconButtonVariant.accent) {
        foreground = colors.textPrimary;
      }
    }

    return Semantics(
      button: true,
      label: widget.label,
      child: Opacity(
        opacity: widget.disabled ? 0.45 : 1,
        child: GestureDetector(
          onTapDown: widget.disabled
              ? null
              : (_) => setState(() => _pressed = true),
          onTapUp: widget.disabled
              ? null
              : (_) => setState(() => _pressed = false),
          onTapCancel: widget.disabled
              ? null
              : () => setState(() => _pressed = false),
          onTap: widget.disabled ? null : widget.onPressed,
          child: AnimatedContainer(
            duration: AppMotion.fast,
            curve: AppMotion.easeOut,
            width: box,
            height: box,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
              border: border != null ? Border.all(color: border) : null,
            ),
            alignment: Alignment.center,
            child: AppIcon(widget.icon, size: iconSize, color: foreground),
          ),
        ),
      ),
    );
  }
}

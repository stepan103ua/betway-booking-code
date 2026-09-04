import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_motion.dart';
import '../tokens/app_radius.dart';

enum AppCardTone { card, raised, sunken, outline }

enum AppCardPadding { none, sm, md, lg }

/// Bordered surface. Dark theme separates layers with a 1px hairline plus a
/// step in surface lightness — never a shadow.
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.tone = AppCardTone.card,
    this.padding = AppCardPadding.md,
    this.radius = AppRadius.lg,
    this.interactive = false,
    this.onTap,
    this.clipBehavior = Clip.none,
  });

  final Widget child;
  final AppCardTone tone;
  final AppCardPadding padding;
  final double radius;
  final bool interactive;
  final VoidCallback? onTap;
  final Clip clipBehavior;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _pressed = false;

  double get _pad => switch (widget.padding) {
    AppCardPadding.none => 0,
    AppCardPadding.sm => 12,
    AppCardPadding.md => 16,
    AppCardPadding.lg => 20,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final baseBg = switch (widget.tone) {
      AppCardTone.raised => colors.surfaceRaised,
      AppCardTone.sunken => colors.surfaceSunken,
      _ => colors.surfaceCard,
    };
    final border = widget.tone == AppCardTone.outline
        ? colors.borderStrong
        : colors.borderSubtle;

    final card = AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.easeOut,
      clipBehavior: widget.clipBehavior,
      padding: EdgeInsets.all(_pad),
      decoration: BoxDecoration(
        color: _pressed && widget.interactive ? colors.surfaceHover : baseBg,
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(color: border),
      ),
      child: widget.child,
    );

    if (!widget.interactive && widget.onTap == null) return card;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: card,
    );
  }
}

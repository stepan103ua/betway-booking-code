import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_motion.dart';
import '../tokens/app_radius.dart';

/// Shape-of-the-content placeholder. This product never shows a spinner for
/// slip loading — `docs/mobile.md`'s `SlipState.loading` renders this, not a
/// `CircularProgressIndicator`.
class AppSkeleton extends StatefulWidget {
  const AppSkeleton({
    super.key,
    this.width,
    this.height = 12,
    this.radius = AppRadius.sm,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.skeleton,
  )..repeat(reverse: true);
  late final Animation<double> _opacity = Tween<double>(
    begin: 0.55,
    end: 1,
  ).animate(CurvedAnimation(parent: _controller, curve: AppMotion.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, _) => Opacity(
        opacity: _opacity.value,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: colors.surfaceSkeleton,
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        ),
      ),
    );
  }
}

/// Stacked skeleton bars, the last one narrower — mirrors `Skeleton.jsx`'s
/// `lines` prop (the multi-line paragraph placeholder).
class AppSkeletonLines extends StatelessWidget {
  const AppSkeletonLines({
    super.key,
    this.lines = 2,
    this.height = 12,
    this.gap = 8,
  });

  final int lines;
  final double height;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < lines; i++) ...[
          if (i > 0) SizedBox(height: gap),
          FractionallySizedBox(
            widthFactor: i == lines - 1 ? 0.62 : 1,
            alignment: Alignment.centerLeft,
            child: AppSkeleton(height: height),
          ),
        ],
      ],
    );
  }
}

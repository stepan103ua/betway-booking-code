import 'package:flutter/material.dart';

import '../tokens/app_motion.dart';

/// Expand / collapse a block of variable-height content, animating both ways.
///
/// The content is always laid out at its natural height inside an
/// `Align(heightFactor:)` — so `AnimatedSize` only ever sees two *deterministic*
/// sizes to tween between (0 and the real height), never a size that settles
/// over a frame or two. That's the failure mode of the obvious
/// `AnimatedSize(child: open ? content : SizedBox())`: the freshly built
/// content isn't pixel-stable on its first layout, `AnimatedSize` flags it
/// unstable and snaps open. `ClipRect` hides the overflow while collapsed.
class AppExpandable extends StatelessWidget {
  const AppExpandable({
    super.key,
    required this.expanded,
    required this.child,
    this.duration = const Duration(milliseconds: 260),
  });

  final bool expanded;
  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return AnimatedSize(
      duration: reduceMotion ? Duration.zero : duration,
      curve: AppMotion.easeOut,
      alignment: Alignment.topCenter,
      child: ClipRect(
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: expanded ? 1.0 : 0.0,
          child: child,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../tokens/app_motion.dart';

/// The Flutter side of the web's `--animate-rise` / `--animate-pop` pair.
///
/// `AppReveal` plays a one-shot fade + 6px upward slide when its subtree first
/// mounts; replaying it on a state change is a `key` bump at the call site, the
/// same trick the web uses (`<div key={phase}>`). `AppPop` is the smaller
/// emphasis move — a check mark or an odds figure scaling into place.
///
/// Both collapse to a plain passthrough when the platform "reduce motion"
/// switch is on (`MediaQuery.disableAnimations`), matching the web's
/// `prefers-reduced-motion` guard.
class AppReveal extends StatefulWidget {
  const AppReveal({
    super.key,
    required this.child,
    this.duration = AppMotion.rise,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration duration;

  /// Stagger for a list: pass `index * 30ms` or similar. Kept small — the
  /// design system's motion is not meant to be watched.
  final Duration delay;

  @override
  State<AppReveal> createState() => _AppRevealState();
}

class _AppRevealState extends State<AppReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _curved = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.easeOut,
  );

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      _controller.value = 1;
    } else if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curved,
      builder: (context, child) => Opacity(
        opacity: _curved.value.clamp(0, 1),
        child: Transform.translate(
          offset: Offset(0, (1 - _curved.value) * AppMotion.riseOffset),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

/// A one-shot scale from 0.6 → 1 — the web's `--animate-pop`. Used for a
/// control's check mark appearing. Bump the `key` to replay.
class AppPop extends StatefulWidget {
  const AppPop({super.key, required this.child});

  final Widget child;

  @override
  State<AppPop> createState() => _AppPopState();
}

class _AppPopState extends State<AppPop> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.pop,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      _controller.value = 1;
    } else if (_controller.status == AnimationStatus.dismissed) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.6,
        end: 1,
      ).animate(CurvedAnimation(parent: _controller, curve: AppMotion.easeOut)),
      child: widget.child,
    );
  }
}

/// A press dip — scales the child to 0.97 while a finger is down, `fast`
/// easing back on release. The web's `active:scale-[0.97]` on chips and tiles;
/// `AppButton` already carries its own copy of this.
class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.97,
    this.enabled = true,
    this.behavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool enabled;
  final HitTestBehavior behavior;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  void _set(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.enabled && widget.onTap != null;
    return GestureDetector(
      behavior: widget.behavior,
      onTap: active ? widget.onTap : null,
      onTapDown: active ? (_) => _set(true) : null,
      onTapUp: active ? (_) => _set(false) : null,
      onTapCancel: active ? () => _set(false) : null,
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1,
        duration: AppMotion.fast,
        curve: AppMotion.easeOut,
        child: widget.child,
      ),
    );
  }
}

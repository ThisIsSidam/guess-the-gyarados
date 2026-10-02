import 'dart:math';

import 'package:flutter/material.dart';
import 'package:guessthegyarados/core/settings/reduced_motion.dart';

/// Shakes [child] side to side whenever [trigger] changes value (it stays
/// still on first build, and while the trigger is unchanged). Wrap anything
/// that should react to a wrong answer or a refusal — pass a bool that flips
/// to true, or a counter that gets bumped.
class Shake extends StatefulWidget {
  const Shake({
    super.key,
    required this.child,
    required this.trigger,
    this.amplitude = 8,
    this.shakes = 3,
    this.duration = const Duration(milliseconds: 420),
  });

  final Widget child;
  final Object? trigger;

  /// Peak sideways travel in logical pixels.
  final double amplitude;

  /// How many full left-right swings.
  final int shakes;
  final Duration duration;

  @override
  State<Shake> createState() => _ShakeState();
}

class _ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);

  @override
  void didUpdateWidget(Shake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger && !ReducedMotion.of(context)) {
      _controller.forward(from: 0);
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
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        // Decaying sine: big swings first, settling to rest.
        final t = _controller.value;
        final dx = sin(t * 2 * pi * widget.shakes) * (1 - t) * widget.amplitude;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
    );
  }
}

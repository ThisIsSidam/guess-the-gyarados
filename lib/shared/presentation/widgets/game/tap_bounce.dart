import 'package:flutter/material.dart';

/// Squash-and-stretch feedback for a tap: the child dips on touch-down and
/// springs back past full size on release. Nothing animates until the player
/// interacts, so it's safe for idle screens.
class TapBounce extends StatefulWidget {
  const TapBounce({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.92,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final String? semanticLabel;

  @override
  State<TapBounce> createState() => _TapBounceState();
}

class _TapBounceState extends State<TapBounce>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
    value: 1,
  );

  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 1.0, end: widget.pressedScale)
          .chain(CurveTween(curve: Curves.easeOut)),
      weight: 1,
    ),
    TweenSequenceItem(
      tween: Tween(begin: widget.pressedScale, end: 1.0)
          .chain(CurveTween(curve: Curves.elasticOut)),
      weight: 5,
    ),
  ]).animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Only the dip is held on touch-down; the rebound plays from the dip on
  // release, so a long press stays squashed instead of bouncing early.
  void _down() =>
      _controller.animateTo(1 / 6, duration: const Duration(milliseconds: 70));

  void _release() => _controller.forward();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: widget.onTap != null,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.onTap == null ? null : (_) => _down(),
        onTapUp: widget.onTap == null
            ? null
            : (_) {
                _release();
                widget.onTap!();
              },
        onTapCancel: widget.onTap == null ? null : _release,
        child: ScaleTransition(scale: _scale, child: widget.child),
      ),
    );
  }
}

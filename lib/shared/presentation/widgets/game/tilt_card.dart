import 'package:flutter/material.dart';

/// Wraps [child] in a perspective transform that tilts on drag/hover,
/// simulating a 3D card (à la a physical trading card catching light) with
/// nothing but [Transform] + [Matrix4] — no extra rendering package needed.
/// Snaps back to flat when the pointer leaves or lifts.
class TiltCard extends StatefulWidget {
  const TiltCard({
    super.key,
    required this.child,
    this.onTap,
    this.maxTilt = 0.35,
    this.perspective = 0.0025,
    this.liftScale = 1.04,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double maxTilt;
  final double perspective;
  final double liftScale;

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard> {
  double _rotX = 0;
  double _rotY = 0;
  double _scale = 1;

  void _updateFromLocal(Offset local, Size size) {
    if (size.width == 0 || size.height == 0) return;
    final px = (local.dx / size.width).clamp(0.0, 1.0) - 0.5;
    final py = (local.dy / size.height).clamp(0.0, 1.0) - 0.5;
    setState(() {
      _rotY = px * widget.maxTilt * 2;
      _rotX = -py * widget.maxTilt * 2;
      _scale = widget.liftScale;
    });
  }

  void _reset() {
    setState(() {
      _rotX = 0;
      _rotY = 0;
      _scale = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onPanDown: (details) {
        final box = context.findRenderObject() as RenderBox;
        _updateFromLocal(box.globalToLocal(details.globalPosition), box.size);
      },
      onPanUpdate: (details) {
        final box = context.findRenderObject() as RenderBox;
        _updateFromLocal(box.globalToLocal(details.globalPosition), box.size);
      },
      onPanEnd: (_) => _reset(),
      onPanCancel: _reset,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        builder: (context, _, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            transformAlignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, widget.perspective)
              ..rotateX(_rotX)
              ..rotateY(_rotY)
              ..scaleByDouble(_scale, _scale, _scale, 1),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// A card that flips 180° around the Y axis to reveal [back] once [flipped]
/// becomes true — used for the "Who's that Pokemon?" silhouette reveal.
class FlipCard extends StatefulWidget {
  const FlipCard({
    super.key,
    required this.front,
    required this.back,
    required this.flipped,
    this.duration = const Duration(milliseconds: 600),
  });

  final Widget front;
  final Widget back;
  final bool flipped;
  final Duration duration;

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: widget.flipped ? 1 : 0,
  );

  @override
  void didUpdateWidget(FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.flipped != oldWidget.flipped) {
      widget.flipped ? _controller.forward() : _controller.reverse();
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
      builder: (context, _) {
        final angle = _controller.value * 3.14159265;
        final isBack = _controller.value > 0.5;
        final displayAngle = isBack ? angle - 3.14159265 : angle;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(displayAngle),
          child: isBack ? widget.back : widget.front,
        );
      },
    );
  }
}

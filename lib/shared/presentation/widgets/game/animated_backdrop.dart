import 'dart:math';
import 'package:flutter/material.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';

/// A slowly drifting diagonal gradient plus a couple of soft glow blobs,
/// used behind most full screens instead of a flat scaffold color so the
/// game world feels alive rather than static.
class AnimatedBackdrop extends StatefulWidget {
  const AnimatedBackdrop({
    super.key,
    this.child,
    this.accentColor = GameColors.primary,
  });

  final Widget? child;
  final Color accentColor;

  @override
  State<AnimatedBackdrop> createState() => _AnimatedBackdropState();
}

class _AnimatedBackdropState extends State<AnimatedBackdrop> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: GameColors.backgroundDeep),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value * 2 * 3.14159265;
            return Stack(
              children: [
                Positioned(
                  left: 40 + 60 * (0.5 + 0.5 * sin(t)),
                  top: -80 + 40 * sin(t * 0.7),
                  child: _glowBlob(widget.accentColor, 220),
                ),
                Positioned(
                  right: -60 + 40 * sin(t * 0.6 + 2),
                  bottom: 40 + 60 * sin(t * 0.5),
                  child: _glowBlob(GameColors.gold, 260),
                ),
              ],
            );
          },
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                GameColors.background.withValues(alpha: 0.35),
                GameColors.background,
              ],
            ),
          ),
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }

  Widget _glowBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.35), color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

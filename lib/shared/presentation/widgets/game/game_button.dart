import 'package:flutter/material.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';

/// A chunky, console-style 3D button: a colored face sits above a darker
/// "depth" shadow with no blur (hard offset), so it reads as a physical
/// button rather than a flat Material one. Pressing it collapses the shadow
/// offset, giving the illusion of the face being pushed down into the base.
class GameButton extends StatefulWidget {
  const GameButton({
    super.key,
    required this.child,
    this.onPressed,
    this.color = GameColors.primary,
    this.depthColor,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
    this.depth = 8,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final Color color;
  final Color? depthColor;
  final double borderRadius;
  final EdgeInsets padding;
  final double depth;

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onPressed == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final depthColor = widget.depthColor ?? Color.lerp(widget.color, Colors.black, 0.45)!;
    final currentDepth = _pressed ? widget.depth * 0.25 : widget.depth;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) {
        _setPressed(false);
        widget.onPressed?.call();
      },
      onTapCancel: () => _setPressed(false),
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        offset: Offset(0, _pressed ? (widget.depth - currentDepth) / 60 : 0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.onPressed == null ? widget.color.withValues(alpha: 0.4) : widget.color,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 2),
            boxShadow: [
              BoxShadow(
                color: depthColor,
                offset: Offset(0, currentDepth),
                blurRadius: 0,
              ),
              BoxShadow(
                color: widget.color.withValues(alpha: 0.35),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(widthFactor: 1, heightFactor: 1, child: widget.child),
        ),
      ),
    );
  }
}

/// Small round icon-badge version of [GameButton], used for HUD icons
/// (profile / achievements / pokedex shortcuts on the home app bar).
class GameIconBadge extends StatefulWidget {
  const GameIconBadge({
    super.key,
    required this.child,
    required this.onPressed,
    this.color = GameColors.surfaceRaised,
    this.size = 52,
  });

  final Widget child;
  final VoidCallback onPressed;
  final Color color;
  final double size;

  @override
  State<GameIconBadge> createState() => _GameIconBadgeState();
}

class _GameIconBadgeState extends State<GameIconBadge> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                offset: Offset(0, _pressed ? 1 : 4),
                blurRadius: _pressed ? 2 : 8,
              ),
            ],
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}

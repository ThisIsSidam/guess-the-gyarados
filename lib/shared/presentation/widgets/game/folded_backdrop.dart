import 'package:flutter/material.dart';

/// The fold layout of a [FoldedBackdrop]. Every layout is the same family as
/// the play page's: broad, slightly slanted horizontal bands plus a small
/// corner triangle, with a neutral fold anchoring the opposite corner. They
/// differ only in slope, direction and band count, so each screen gets its own
/// sheet while the app still reads as one piece of paper.
enum FoldPattern {
  /// Bands falling to the left, medium slope (the play page).
  diagonal,

  /// [diagonal] mirrored: bands falling to the right (the home page).
  rising,

  /// Thin, gentle bands that leave most of the sheet clear (the pokedex).
  shallow,

  /// Tall, steep bands (the caught page).
  steep,

  /// [steep] mirrored (achievements).
  steepRising,

  /// Three stacked bands instead of two (the profile).
  layered,

  /// Two wide, low bands that push the clear area to the top (settings).
  broad,
}

/// A folded-paper backdrop: no glow, no blur, nothing soft — only flat facets
/// with sharply-defined shades. The sheet underneath is a light neutral grey
/// and the accent-tinted facets are kept pastel-light so the page reads light
/// rather than deeply colored. [accentColor] tweens when it changes, so a
/// color-feedback moment (e.g. revealing a Pokemon's type) shifts the paper
/// instead of snapping.
class FoldedBackdrop extends StatelessWidget {
  const FoldedBackdrop({
    super.key,
    required this.accentColor,
    required this.child,
    this.pattern = FoldPattern.diagonal,
  });

  final Color accentColor;
  final FoldPattern pattern;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          TweenAnimationBuilder<Color?>(
            tween: ColorTween(end: accentColor),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            builder: (context, color, _) => CustomPaint(
              painter: _FoldPainter(
                accent: color ?? accentColor,
                pattern: pattern,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _Facet {
  const _Facet(this.points, this.whiten, {this.neutral = false});

  /// Corners in unit coordinates (0..1 of the canvas width/height).
  final List<Offset> points;

  /// How far toward white the accent is blended (0 = pure accent).
  final double whiten;

  /// A grey facet instead of an accent-tinted one; [whiten] is then how much
  /// it darkens (0 = the sheet color).
  final bool neutral;

  _Facet mirrored() => _Facet(
        [for (final p in points) Offset(1 - p.dx, p.dy)],
        whiten,
        neutral: neutral,
      );
}

class _FoldPainter extends CustomPainter {
  _FoldPainter({required this.accent, required this.pattern});

  final Color accent;
  final FoldPattern pattern;

  static const _grey = Color.fromARGB(255, 247, 247, 247);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _grey);

    final creasePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final facet in _facetsFor(pattern)) {
      final path = Path()
        ..addPolygon([
          for (final p in facet.points)
            Offset(p.dx * size.width, p.dy * size.height),
        ], true);
      final color = facet.neutral
          ? Color.lerp(_grey, Colors.black, facet.whiten)!
          : Color.lerp(accent, Colors.white, facet.whiten)!;
      canvas.drawPath(path, Paint()..color = color);
      canvas.drawPath(path, creasePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FoldPainter oldDelegate) =>
      oldDelegate.accent != accent || oldDelegate.pattern != pattern;
}

// Facets are listed back-to-front. Tints are pastel (whiten 0.45–0.75) so the
// page stays light; the neutral corner is the only grey fold.
const _diagonal = [
  _Facet([Offset(0, 0), Offset(1, 0), Offset(1, 0.18), Offset(0, 0.28)], 0.45),
  _Facet([Offset(0, 0), Offset(0.4, 0), Offset(0, 0.16)], 0.6),
  _Facet([Offset(0, 0.28), Offset(1, 0.18), Offset(1, 0.4), Offset(0, 0.6)], 0.7),
  _Facet([Offset(1, 1), Offset(0.62, 1), Offset(1, 0.7)], 0.06, neutral: true),
];

const _shallow = [
  _Facet([Offset(0, 0), Offset(1, 0), Offset(1, 0.1), Offset(0, 0.17)], 0.5),
  _Facet([Offset(0, 0), Offset(0.34, 0), Offset(0, 0.1)], 0.65),
  _Facet([Offset(0, 0.17), Offset(1, 0.1), Offset(1, 0.2), Offset(0, 0.3)], 0.72),
  _Facet([Offset(1, 1), Offset(0.7, 1), Offset(1, 0.82)], 0.06, neutral: true),
];

const _steep = [
  _Facet([Offset(0, 0), Offset(1, 0), Offset(1, 0.08), Offset(0, 0.3)], 0.45),
  _Facet([Offset(0, 0), Offset(0.5, 0), Offset(0, 0.18)], 0.6),
  _Facet([Offset(0, 0.3), Offset(1, 0.08), Offset(1, 0.3), Offset(0, 0.58)], 0.7),
  _Facet([Offset(1, 1), Offset(0.55, 1), Offset(1, 0.62)], 0.06, neutral: true),
];

const _layered = [
  _Facet([Offset(0, 0), Offset(1, 0), Offset(1, 0.14), Offset(0, 0.22)], 0.45),
  _Facet([Offset(0, 0), Offset(0.4, 0), Offset(0, 0.13)], 0.6),
  _Facet([Offset(0, 0.22), Offset(1, 0.14), Offset(1, 0.3), Offset(0, 0.42)], 0.62),
  _Facet([Offset(0, 0.42), Offset(1, 0.3), Offset(1, 0.38), Offset(0, 0.52)], 0.76),
  _Facet([Offset(1, 1), Offset(0.62, 1), Offset(1, 0.74)], 0.06, neutral: true),
];

const _broad = [
  _Facet([Offset(0, 0), Offset(1, 0), Offset(1, 0.12), Offset(0, 0.06)], 0.5),
  _Facet([Offset(1, 0), Offset(0.6, 0), Offset(1, 0.07)], 0.62),
  _Facet([Offset(0, 0.06), Offset(1, 0.12), Offset(1, 0.26), Offset(0, 0.2)], 0.72),
  _Facet([Offset(0, 1), Offset(0.4, 1), Offset(0, 0.78)], 0.06, neutral: true),
];

List<_Facet> _facetsFor(FoldPattern pattern) {
  switch (pattern) {
    case FoldPattern.diagonal:
      return _diagonal;
    case FoldPattern.rising:
      return [for (final f in _diagonal) f.mirrored()];
    case FoldPattern.shallow:
      return _shallow;
    case FoldPattern.steep:
      return _steep;
    case FoldPattern.steepRising:
      return [for (final f in _steep) f.mirrored()];
    case FoldPattern.layered:
      return _layered;
    case FoldPattern.broad:
      return _broad;
  }
}

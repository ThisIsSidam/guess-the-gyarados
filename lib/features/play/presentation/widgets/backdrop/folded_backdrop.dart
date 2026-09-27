import 'package:flutter/material.dart';

/// A folded-paper backdrop: two diagonal fold lines split the screen into
/// three flat bands, each a distinct, sharply-defined shade — no glow, no
/// blur, nothing soft. The bottom band (a light neutral grey) is the
/// largest, the accent-tinted top bands are kept small and pastel-light so
/// the page overall reads light rather than deeply colored, and the
/// current [accentColor] still shows through the top two bands so the
/// reveal's color feedback reads directly off the backdrop itself.
class FoldedBackdrop extends StatelessWidget {
  const FoldedBackdrop(
      {super.key, required this.accentColor, required this.child});

  final Color accentColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: _FoldPainter(accent: accentColor)),
        child,
      ],
    );
  }
}

class _FoldPainter extends CustomPainter {
  _FoldPainter({required this.accent});

  final Color accent;

  static const _grey = Color.fromARGB(255, 247, 247, 247);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Same silhouette as the original fold design — a big diagonal top/bottom
    // split plus two small corner accent triangles — just rebalanced so the
    // grey bottom region dominates and the accent-tinted top regions are
    // small, pastel-light slivers instead of a deep, saturated block.
    final top = [
      Offset(0, 0),
      Offset(w, 0),
      Offset(w, h * 0.18),
      Offset(0, h * 0.28)
    ];
    final topCorner = [Offset(0, 0), Offset(w * 0.4, 0), Offset(0, h * 0.16)];
    final middle = [
      Offset(0, h * 0.28),
      Offset(w, h * 0.18),
      Offset(w, h * 0.4),
      Offset(0, h * 0.6),
    ];
    final bottom = [
      Offset(0, h * 0.6),
      Offset(w, h * 0.4),
      Offset(w, h),
      Offset(0, h)
    ];
    final bottomCorner = [
      Offset(w, h),
      Offset(w * 0.62, h),
      Offset(w, h * 0.7)
    ];

    // Blended much further toward white than before — a light pastel tint
    // of the accent, not the accent at full strength.
    final topColor = Color.lerp(accent, Colors.white, 0.45)!;
    final middleColor = Color.lerp(accent, Colors.white, 0.7)!;
    final bands = [
      _Band(top, topColor),
      _Band(topCorner, Color.lerp(accent, Colors.white, 0.6)!),
      _Band(middle, middleColor),
      _Band(bottom, _grey),
      _Band(bottomCorner, Color.lerp(_grey, Colors.black, 0.06)!),
    ];

    for (final band in bands) {
      canvas.drawPath(
          Path()..addPolygon(band.points, true), Paint()..color = band.color);
    }

    final creasePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final facet in [top, topCorner, middle, bottom, bottomCorner]) {
      canvas.drawPath(Path()..addPolygon(facet, true), creasePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FoldPainter oldDelegate) =>
      oldDelegate.accent != accent;
}

class _Band {
  const _Band(this.points, this.color);

  final List<Offset> points;
  final Color color;
}

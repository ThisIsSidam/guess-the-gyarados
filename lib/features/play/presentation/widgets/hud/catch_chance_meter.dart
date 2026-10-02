import 'dart:math';

import 'package:flutter/material.dart';
import 'package:guessthegyarados/core/constants/asset_paths.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/shake.dart';

/// The round's catch chance as a Pokeball ringed by a draining arc plus the
/// plain percentage. Eases to each new value, and shakes whenever [steps]
/// goes up so the cost of a tap is felt, not just read.
class CatchChanceMeter extends StatelessWidget {
  const CatchChanceMeter({super.key, required this.chance, required this.steps});

  /// 0-100.
  final double chance;

  /// Steps taken so far; each increase triggers the shake.
  final int steps;

  static Color colorFor(double chance) {
    if (chance >= 65) return GameColors.success;
    if (chance >= 35) return GameColors.gold;
    return GameColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Catch chance ${chance.round()} percent',
      child: Shake(
        trigger: steps,
        amplitude: 5,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: chance),
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOut,
          builder: (context, value, _) {
            final color = colorFor(value);
            return Container(
              padding: const EdgeInsets.fromLTRB(8, 6, 16, 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(color: Color(0x33000000), offset: Offset(0, 3)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: CustomPaint(
                      painter: _RingPainter(fraction: value / 100, color: color),
                      child: Center(
                        child: Image.asset(pokeballIcon, width: 26, height: 26),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${value.round()}%',
                        style: const TextStyle(
                          fontSize: 22,
                          height: 1,
                          fontWeight: FontWeight.w800,
                          color: GameColors.textOnLight,
                        ),
                      ),
                      const Text(
                        'catch chance',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.1,
                          fontWeight: FontWeight.w700,
                          color: GameColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.fraction, required this.color});

  final double fraction;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 5.0;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = const Color(0xFFE4E7EF);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke
      ..color = color;

    canvas.drawArc(rect, 0, 2 * pi, false, track);
    canvas.drawArc(rect, -pi / 2, 2 * pi * fraction.clamp(0.0, 1.0), false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction || old.color != color;
}

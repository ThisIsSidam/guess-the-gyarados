import 'package:flutter/material.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';
import 'package:guessthegyarados/features/play/domain/models/round_scoring.dart';

/// "Streak 3 · x1.4": the catches in a row going into this round and the
/// bonus the next catch is worth.
class StreakPill extends StatelessWidget {
  const StreakPill({super.key, required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final multiplier = RoundScoring.streakMultiplier(streak);
    return Semantics(
      label: 'Catch streak $streak, bonus ${multiplier.toStringAsFixed(1)} times',
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 4, 14, 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(color: Color(0xFFC25A12), offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_fire_department_rounded,
                color: Color(0xFFFF8A3D), size: 24),
            const SizedBox(width: 4),
            Text(
              'Streak $streak  ·  x${multiplier.toStringAsFixed(1)}',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: GameColors.textOnLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

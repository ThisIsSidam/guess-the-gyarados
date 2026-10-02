import 'package:flutter/material.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';
import 'package:guessthegyarados/features/profile/domain/level_math.dart';

class LevelProgressBar extends StatelessWidget {
  final int currentPoints;
  final int currentLevel;
  final Color levelBarColor;

  const LevelProgressBar({
    super.key,
    required this.currentPoints,
    required this.currentLevel,
    required this.levelBarColor,
  });

  @override
  Widget build(BuildContext context) {
    final nextLevelThreshold = calculateLevelThreshold(currentLevel + 1);
    final double progress =
        (currentPoints.toDouble() / nextLevelThreshold.toDouble()).clamp(0, 1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _levelChip('$currentLevel'),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: const Color(0xFFC9CEDB), width: 2),
                    ),
                  ),
                  // Fills once when the page opens; nothing moves after that.
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: progress),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) => Container(
                          height: 18,
                          width: constraints.maxWidth * value,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [levelBarColor, GameColors.gold]),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '$currentPoints / $nextLevelThreshold pts',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: GameColors.textOnLight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _levelChip('${currentLevel + 1}'),
      ],
    );
  }

  Widget _levelChip(String level) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: GameColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: GameColors.goldDeep, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 16, color: GameColors.goldDeep),
          const SizedBox(width: 4),
          Text(
            level,
            style: const TextStyle(
              fontSize: 16,
              color: GameColors.textOnLight,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

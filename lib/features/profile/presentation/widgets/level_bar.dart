import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    final double progress = (currentPoints.toDouble() / nextLevelThreshold.toDouble()).clamp(0, 1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _levelChip('$currentLevel'),
        const SizedBox(width: 10),
        Expanded(
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white24),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    height: 16,
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [levelBarColor, GameColors.gold]),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(color: GameColors.gold.withValues(alpha: 0.6), blurRadius: 10),
                      ],
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(
                        duration: const Duration(seconds: 2),
                        color: Colors.white.withValues(alpha: 0.5),
                      );
                },
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GameColors.gold.withValues(alpha: 0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 14, color: GameColors.gold),
          const SizedBox(width: 4),
          Text(
            level,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

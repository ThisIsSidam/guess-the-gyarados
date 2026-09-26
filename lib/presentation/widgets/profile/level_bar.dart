import 'package:flutter/material.dart';
import 'package:guessthegyarados/core/utils/level_math.dart';

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
    final double progress = currentPoints.toDouble() / nextLevelThreshold.toDouble();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Level $currentLevel',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Colors.white
          ),
        ),
        const SizedBox(width: 10,),
        Expanded(
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(levelBarColor),
          ),
        ),
        const SizedBox(width: 10,),
        Text(
          'Level ${currentLevel + 1}',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Colors.white
          )
        ),
      ],
    );
  }
}

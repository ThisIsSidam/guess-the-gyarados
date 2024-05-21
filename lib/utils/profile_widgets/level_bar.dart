import 'package:flutter/material.dart';
import 'package:guessthegyarados/database/user_data.dart';
import 'package:guessthegyarados/utils/misc_methods.dart';

class LevelProgressBar extends StatelessWidget {
  final int currentPoints;

  const LevelProgressBar({
    super.key,
    required this.currentPoints,
  });

  @override
  Widget build(BuildContext context) {
    final currentLevel = UserDB.getData(UserDetails.level) ?? 0;
    final nextLevelThreshold = calculateLevelThreshold(currentLevel + 1);
    final double progress = currentPoints.toDouble() / nextLevelThreshold.toDouble();

    final levelBarColor = darkenColor(
      getColorFromString(
        UserDB.getData(UserDetails.userColorString) ?? "Normal"
      ),
      0.4
    );

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
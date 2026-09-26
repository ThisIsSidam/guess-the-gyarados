import 'package:flutter/material.dart';
import 'package:guessthegyarados/shared/domain/achievements/achievement.dart';
import 'package:guessthegyarados/shared/presentation/widgets/achievement_badge.dart';

// Takes a list of achievements and returns a grid of badges for it.
Widget buildAchievementGrid(List<Achievement> list, {bool isReceived = true}) {
  final len = list.length;

  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 8.0,
    ),
    itemCount: list.length,
    itemBuilder: (context, index) {
      return AchievementBadge(
        achievement: list[len - index - 1],
        isReceived: isReceived,
      );
    },
  );
}

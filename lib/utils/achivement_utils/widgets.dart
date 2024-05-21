import 'package:flutter/material.dart';
import 'package:guessthegyarados/utils/achivement_utils/achievement_classes.dart';

// Takes a list of achievements and returns a list of it. 
Widget buildAchievementGrid(List<Achievement> list) {

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
        return list[len - index -1].achievementBadge;
      },
    ); 
  }

  
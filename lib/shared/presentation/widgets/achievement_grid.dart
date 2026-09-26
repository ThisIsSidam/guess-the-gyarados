import 'package:flutter/material.dart';
import 'package:guessthegyarados/shared/domain/achievements/achievement.dart';
import 'package:guessthegyarados/shared/presentation/widgets/achievement_badge.dart';

const _achievementGridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  childAspectRatio: 1.5,
  mainAxisSpacing: 8.0,
  crossAxisSpacing: 8.0,
);

AchievementBadge _badgeAt(List<Achievement> list, int index, bool isReceived) {
  return AchievementBadge(
    achievement: list[list.length - index - 1],
    isReceived: isReceived,
  );
}

// Takes a list of achievements and returns a grid of badges for it. For use
// inside an already-bounded (e.g. Expanded) region that owns its own
// scrolling — this GridView scrolls itself rather than shrink-wrapping,
// so it never has to eagerly lay out every badge up front.
Widget buildAchievementGrid(List<Achievement> list, {bool isReceived = true}) {
  return GridView.builder(
    gridDelegate: _achievementGridDelegate,
    itemCount: list.length,
    itemBuilder: (context, index) => _badgeAt(list, index, isReceived),
  );
}

// Sliver variant for embedding directly inside a CustomScrollView (e.g.
// alongside section headers), so the grid shares the page's single scroll
// position and lazily builds badges instead of being forced to shrink-wrap.
Widget buildAchievementGridSliver(List<Achievement> list, {bool isReceived = true}) {
  return SliverGrid(
    gridDelegate: _achievementGridDelegate,
    delegate: SliverChildBuilderDelegate(
      (context, index) => _badgeAt(list, index, isReceived),
      childCount: list.length,
    ),
  );
}

import 'dart:math';

int getUserLevel(int userPoints) {
  int level = 0;
  int threshold = 0;

  while (userPoints >= threshold) {
    level++;
    threshold = calculateLevelThreshold(level);
  }

  return level;
}

int calculateLevelThreshold(int level) {
  const basePoints = 175;
  const growthFactor = 1.2;

  return (basePoints * pow(growthFactor, level - 1)).floor();
}

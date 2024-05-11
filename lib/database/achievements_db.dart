import 'package:guessthegyarados/consts/strings.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AchievementDB {
  static final Box box = Hive.box(achievementBox);

  static void update(int achievementId) {
    final receivedAchievements = getList;  
    receivedAchievements.add(achievementId);
    box.put(receivedAchievementsKey, receivedAchievements.toList()); 
  }

  static Set<int> get getList {
    dynamic data = box.get(receivedAchievementsKey);

    Set<int> mySet;

    if (data == null || data.isEmpty) 
    {
      mySet = <int>{};
    } 
    else 
    {
      mySet = Set<int>.from(data.cast<int>());
    }

    return mySet;
  }
}
import 'package:guessthegyarados/consts/strings.dart';
import 'package:guessthegyarados/utils/misc_methods.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum UserDetails {username, firstCatch, 
/// [userColorString] is a pokemon type with which we get the color.
  userColorString, // Primary type of first catch.
  points,
  level
}

class UserDB {
  static final Box box = Hive.box(userDBName);

  static Future<void> updateData(UserDetails key, dynamic value) async {
    await box.put(key.toString(), value);
  }

  static dynamic getData(UserDetails key) {
    return box.get(key.toString());
  }

  static int addPoints(int addition) {
    int points = getData(UserDetails.points) ?? 0; 
    int finalPoints = points + addition;

    int currentLevel = getData(UserDetails.level) ?? 0;
    int nextLevelPointThreshold = calculateLevelThreshold(currentLevel+1);

    while (finalPoints > nextLevelPointThreshold)
    {
      updateData(UserDetails.level, currentLevel+1);
      currentLevel++;
      finalPoints -= nextLevelPointThreshold;
      nextLevelPointThreshold = calculateLevelThreshold(currentLevel+1);
    }

    box.put(UserDetails.points.toString(), finalPoints);

    return finalPoints;
  }
}
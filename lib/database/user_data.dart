import 'package:guessthegyarados/consts/strings.dart';
import 'package:guessthegyarados/utils/misc_methods.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum UserDetails {username, firstCatch, 
/// [userColorString] is a pokemon type with which we get the color.
  userColorString,
  points,
  level
}

class UserDB {
  static final Box box = Hive.box(userDBName);

  static Future<void> updateData(UserDetails key, String value) async {
    await box.put(key.toString(), value);
  }

  static String? getData(UserDetails key) {
    return box.get(key.toString());
  }

  static int addPoints(int addition) {
    int points = int.parse(getData(UserDetails.points) ?? "0");
    int finalPoints = points + addition;

    int currentLevel = int.parse(getData(UserDetails.level) ?? "0");
    int nextLevelPointThreshold = calculateLevelThreshold(currentLevel+1);

    while (finalPoints > nextLevelPointThreshold)
    {
      updateData(UserDetails.level, "${currentLevel+1}");
      currentLevel++;
      finalPoints -= nextLevelPointThreshold;
      nextLevelPointThreshold = calculateLevelThreshold(currentLevel+1);
    }

    box.put(UserDetails.points.toString(), finalPoints.toString());

    return finalPoints;
  }
}
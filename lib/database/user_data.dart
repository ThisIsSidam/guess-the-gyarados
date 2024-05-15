import 'package:guessthegyarados/consts/strings.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum UserDetails {username, firstCatch, 
/// [userColorString] is a pokemon type with which we get the color.
  userColorString 
}

class UserDB {
  static final Box box = Hive.box(userDBName);

  static Future<void> updateData(UserDetails key, String value) async {
    await box.put(key.toString(), value);
  }

  static String? getData(UserDetails key) {
    return box.get(key.toString());
  }
}
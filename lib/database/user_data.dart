import 'package:guessthegyarados/consts/strings.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum UserDetails {username}

class UserDB {
  static final Box box = Hive.box(userDBName);

  static Future<void> addData(UserDetails key, String value) async {
    await box.put(key.toString(), value);
  }

  static String? getData(UserDetails key) {
    return box.get(key.toString());
  }
}
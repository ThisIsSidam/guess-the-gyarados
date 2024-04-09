import 'package:hive_flutter/hive_flutter.dart';

class HiveHelper {

  static List<int> _idList = [];
  static final _idBox = Hive.box('caught_pokemon');

  static void refreshIdList() {
    _idList = _idBox.get('CAUGHT_POKEMON') ?? [];
  }

  static List<int> get idList {
    refreshIdList();
    return _idList;
  }

  static void updateData(int newId) {
    refreshIdList();
    _idList.add(newId);
    _idBox.put('CAUGHT_POKEMON', _idList);
  }

}
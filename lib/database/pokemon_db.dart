import 'package:hive_flutter/hive_flutter.dart';

class PokemonDB {

  static final _idBox = Hive.box('caught_pokemon');

  static List<int> _refreshIdList() {
    return _idBox.get('CAUGHT_POKEMON') ?? [];
  }

  static List<int> get idList {
    final idList = _refreshIdList();
    return idList;
  }

  static void updateData(int newId) {
    final idList = _refreshIdList();
    idList.add(newId);
    _idBox.put('CAUGHT_POKEMON', idList);
  }
  
}
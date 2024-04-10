import 'package:hive_flutter/hive_flutter.dart';

class PokemonDB {

  static final _idBox = Hive.box('caught_pokemon');


  static Map<int, List<int>> get idList {
    return _idBox.get('CAUGHT_POKEMON').cast<int,List<int>>() ?? <int, List<int>>{};
  }

  static void updateData(int id, bool isShiny) {

    final idList = _idBox.get('CAUGHT_POKEMON') ?? {};

    if (idList.containsKey(id))
    {
      idList[id]!.add(isShiny ? 1 : 0);
    }
    else 
    {
      idList[id] = [isShiny ? 1 : 0];
    }

    _idBox.put('CAUGHT_POKEMON', idList);
  }
  
}
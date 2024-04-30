import 'package:guessthegyarados/consts/strings.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CaughtPokemonDB {

  static final _idBox = Hive.box(pokemonsOfUserBox);


  static Map<int, List<int>> get idList {
    return _idBox.get(pokemonsOfUserBoxKey)?.cast<int,List<int>>() ?? <int, List<int>>{};
  }

  static void updateData(int id, bool isShiny) {

    final idList = _idBox.get(pokemonsOfUserBoxKey) ?? {};

    if (idList.containsKey(id))
    {
      idList[id]!.add(isShiny ? 1 : 0);
    }
    else 
    {
      idList[id] = [isShiny ? 1 : 0];
    }

    _idBox.put(pokemonsOfUserBoxKey, idList);
  }
  
}
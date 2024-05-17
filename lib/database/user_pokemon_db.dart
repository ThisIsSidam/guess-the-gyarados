import 'package:flutter/material.dart';
import 'package:guessthegyarados/consts/strings.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum PokemonUpdateType {couldNotGuess, catchFailed, caughtNormal, caughtShiny }

class UserPokemonDB {

  static final _idBox = Hive.box(pokemonsOfUserBox);


  static Map<int, Map<String, int>> get getData {
    final dynamicMap = _idBox.get(pokemonsOfUserBoxKey);
    if (dynamicMap == null) {
      return <int, Map<String, int>>{};
    }

    final result = <int, Map<String, int>>{};
    dynamicMap.forEach((key, value) {
      if (key is int && value is Map) {
        final innerMap = <String, int>{};
        value.forEach((k, v) {
          if (k is String && v is int) {
            innerMap[k] = v;
          }
        });
        result[key] = innerMap;
      }
    });

    return result;
  }

  static Map<PokemonUpdateType, int>? getDataForId(int id) {
    final data = getData;
    if (!data.containsKey(id)) {
      return null; // Return an empty map if the id is not found
    }

    final innerMap = data[id];

    if (innerMap == null) return null;

    final result = <PokemonUpdateType, int>{};

    innerMap.forEach((key, value) {
      final enumType = PokemonUpdateType.values.firstWhere(
        (e) => e.name == key,
        orElse: () => PokemonUpdateType.couldNotGuess, // Default value if not found
      );
      result[enumType] = value;
      });

    return result;
  }

  static Map<int, Map<String, int>> updateData(int id, PokemonUpdateType updateType) {
    final idList = getData;

    if (idList.containsKey(id)) {
      final innerMap = idList[id]!;

      final key = updateType.name; // Convert enum to string
      innerMap[key] = (innerMap[key] ?? 0) + 1;

      idList[id] = innerMap;
    } else {
      final innerMap = {
        'couldNotGuess': 0,
        'catchFailed' : 0,
        'caughtNormal': 0,
        'caughtShiny': 0,
      };
      innerMap[updateType.name] = 1; // Set the corresponding key to 1
      idList[id] = innerMap;
    }

    _idBox.put(pokemonsOfUserBoxKey, idList);
    return idList;
  }

  static List<int> getCaughtPokemonIDs() {
    final filteredIDs = <int>[];
    final idList = _idBox.get(pokemonsOfUserBoxKey) ?? {};

    idList.forEach((id, innerMap) {
      final caughtNormal = innerMap['caughtNormal'] ?? 0;
      final caughtShiny = innerMap['caughtShiny'] ?? 0;

      if (caughtNormal > 0 || caughtShiny > 0) {
        filteredIDs.add(id);
      }
    });


    debugPrint("$filteredIDs");
    return filteredIDs;
  }
  
}
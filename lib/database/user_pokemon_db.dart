import 'package:guessthegyarados/consts/strings.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Data is added tagged as one of these although stored as String in the hive box.
enum PokemonInteractionType {couldNotGuess, catchFailed, caughtNormal, caughtShiny }

// This enum is the type of data used in the app. I was taking data out and then converting to 
// this enum later on. But moved it directly in the hive file and made a method to take get 
// right from here. Maybe I'll remove the PokemonInteractionType entirely, sometime.
enum PokemonDetailType {appeared, guessed, caughtTotal, caughtShiny}

class UserPokemonDB {

  static final _idBox = Hive.box(pokemonsOfUserBox);

  static Map<int, Map<String, int>> get getData {
    final dynamicMap = _idBox.get(pokemonsOfUserBoxKey);
    if (dynamicMap == null) {
      return <int, Map<String, int>>{};
    }

    // Data received from the hive box is dynamic so we gotta properly cast it. 
    // I was having problems normally casting it.
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

  static Map<PokemonInteractionType, int>? getDataForId(int id) {
    final data = getData;
    if (!data.containsKey(id)) {
      return null; // Return an empty map if the id is not found
    }

    final innerMap = data[id];

    if (innerMap == null) return null;

    // enum is stored as String in hive box, so converting back for returning.
    final result = <PokemonInteractionType, int>{};

    innerMap.forEach((key, value) {
      final enumType = PokemonInteractionType.values.firstWhere(
        (e) => e.name == key,
        orElse: () => PokemonInteractionType.couldNotGuess, // Default value if not found
      );
      result[enumType] = value;
      });

    return result;
  }

  static Map<int, Map<String, int>> updateData(int id, PokemonInteractionType updateType) {
    final idList = getData;

    if (idList.containsKey(id)) {
      final innerMap = idList[id]!;

      final key = updateType.name;
      innerMap[key] = (innerMap[key] ?? 0) + 1;

      idList[id] = innerMap;
    } else {
      final innerMap = {
        'couldNotGuess': 0,
        'catchFailed' : 0,
        'caughtNormal': 0,
        'caughtShiny': 0,
      };
      innerMap[updateType.name] = 1;
      idList[id] = innerMap;
    }

    _idBox.put(pokemonsOfUserBoxKey, idList);
    return idList;
  }

  // Returns a list of ids of pokemon that are caught; normal or shiny.
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

    return filteredIDs;
  }

  static Map<PokemonDetailType, int> getVariantStats(int id) {
    final variantData = getDataForId(id);

    if (variantData == null) throw "[getVariantStats] null data";

    final guessed = (variantData[PokemonInteractionType.catchFailed] ?? 0).toInt() +
        (variantData[PokemonInteractionType.caughtNormal] ?? 0).toInt() +
        (variantData[PokemonInteractionType.caughtShiny] ?? 0).toInt();
    final caughtTotal = (variantData[PokemonInteractionType.caughtNormal] ?? 0).toInt() +
        (variantData[PokemonInteractionType.caughtShiny] ?? 0).toInt();
    final appeared = (variantData[PokemonInteractionType.couldNotGuess] ?? 0).toInt() + guessed;
    final caughtShiny = variantData[PokemonInteractionType.caughtShiny] ?? 0;

    return {
      PokemonDetailType.appeared : appeared,
      PokemonDetailType.guessed : guessed,
      PokemonDetailType.caughtTotal : caughtTotal,
      PokemonDetailType.caughtShiny : caughtShiny
    };
  }
  
}
import 'package:guessthegyarados/consts/strings.dart';
import 'package:guessthegyarados/pokemon_class/pokemon.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PokemonDB {
  static final Box<Pokemon> box = Hive.box<Pokemon>(pokemonDataBox);

  static Future<void> addData(int pokemonId, Pokemon mon) async {
    await box.put(pokemonId, mon);
  }

  static Pokemon? getData(int pokemonId) {
    return box.get(pokemonId);
  }
}
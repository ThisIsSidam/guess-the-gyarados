import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/consts/strings.dart';
import 'package:guessthegyarados/pokemon_class/pokemon.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'my_app.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox(pokemonsOfUserBox);
  await Hive.openBox(pokemonImagesBox);
  await Hive.openBox(allPokemonNamesBox);
  Hive.registerAdapter(PokemonAdapter());
  await Hive.openBox<Pokemon>(pokemonDataBox);
  await Hive.openBox(achievementBox);
  await Hive.openBox(userDBName);

  runApp(const ProviderScope(
    child: MyApp())
  );
}
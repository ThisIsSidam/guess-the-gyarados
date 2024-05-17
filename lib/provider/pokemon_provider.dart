import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/database/pokemon_data_db.dart';
import 'package:guessthegyarados/pokemon_class/pokemon.dart';
import 'package:guessthegyarados/utils/fetch_data/fetch_data.dart';

final pokemonFutureProvider = FutureProvider.family<Pokemon?, int>((ref, randomId) async {
  // Fetch Pokemon from Database; null if not in database
  Pokemon? pokemonBaseVariant = PokemonDB.getData(randomId);

  // Fetch from pokeApi if not in database and add in database
  pokemonBaseVariant ??= await fetchPokemonFromPokemonId(randomId);
  PokemonDB.addData(randomId, pokemonBaseVariant);

  // Get the id of the final chosen variant.
  final variantIdList = pokemonBaseVariant.variantIDs;
  final finalId = variantIdList[Random().nextInt(variantIdList.length)];

  // Return base variant if it is final
  if (finalId == randomId) return pokemonBaseVariant;

  // Else get the final variant's details and return
  Pokemon? finalPokemon = PokemonDB.getData(finalId);

  if (finalPokemon != null) return finalPokemon;

  finalPokemon = await fetchPokemonFromPokemonId(finalId);
  return finalPokemon;
});


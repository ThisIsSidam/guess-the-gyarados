import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/database/pokemon_data_db.dart';
import 'package:guessthegyarados/pokemon_class/pokemon.dart';
import 'package:guessthegyarados/utils/fetch_data/fetch_data.dart';

final pokemonFutureProvider = FutureProvider.family<Pokemon?, int>((ref, randomId) async {
  Pokemon? pokemon = PokemonDB.getData(randomId);

  if (pokemon != null) return pokemon;

  pokemon = await fetchPokemonData(randomId);
  PokemonDB.addData(randomId, pokemon);
  
  return pokemon;
});


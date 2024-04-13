import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/pokemon_class/pokemon.dart';
import 'package:guessthegyarados/utils/fetch_data.dart';

final pokemonFutureProvider = FutureProvider.family<Pokemon?, int>((ref, randomId) async {
  Pokemon? pokemon;
  try {
    pokemon = await fetchPokemonData(randomId);
  } catch (e) {
    debugPrint('Error fetching Pokemon data: $e');
  }
  return pokemon;
});


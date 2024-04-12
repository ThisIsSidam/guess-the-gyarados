import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:guessthegyarados/consts/asset_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/pokemon_class/pokemon.dart';
import 'package:guessthegyarados/utils/fetch_data.dart';
import 'package:guessthegyarados/utils/misc_methods.dart';

final pokemonFutureProvider = FutureProvider.family<Pokemon?, int>((ref, randomId) async {
  Pokemon? pokemon;
  try {
    pokemon = await fetchPokemonData(randomId);
  } catch (e) {
    debugPrint('Error fetching Pokemon data: $e');
  }
  return pokemon;
});

final pokemonNamesProvider = FutureProvider<Map<int, String>>((ref) async {
  try {
    // Load the JSON data from the local file
    final jsonData = await rootBundle.loadString(pokemonNamesJson);

    // Parse the JSON data
    final decodedData = jsonDecode(jsonData);
    final results = decodedData['results'] as List<dynamic>;

    final pokemonNames = <int, String>{};

    for (int i = 0; i < results.length; i++) {
      final pokemonData = results[i];
      final pokemonName = pokemonData['name'];
      final pokemonId = i + 1; // Assuming the IDs start from 1

      if (excludePokemon(pokemonName)) continue;

      pokemonNames[pokemonId] = capitalizeString(pokemonName);
    }

    return pokemonNames;
  } catch (e) {
    throw Exception('Failed to load Pokemon names: $e');
  }
});
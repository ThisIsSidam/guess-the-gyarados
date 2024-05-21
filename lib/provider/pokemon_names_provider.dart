import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/consts/asset_paths.dart';
import 'package:guessthegyarados/consts/strings.dart';
import 'package:guessthegyarados/utils/misc_methods.dart';
import 'package:hive/hive.dart';

Future<Map<int, String>> _loadPokemonDataFromJson() async {
  try {
    // Load the JSON data from the local file
    final jsonData = await rootBundle.loadString(pokemonNamesJson);

    // Parse the JSON data
    final decodedData = jsonDecode(jsonData);
    final results = decodedData['results'] as List<dynamic>;

    final pokemonNames = <int,String>{};

    for (int i = 0; i < results.length; i++) {
      final pokemonData = results[i];
      final String pokemonName = pokemonData['name'];

      if (pokemonName.contains("-totem")) continue; // Ignore totem pokemons

      pokemonNames[i+1] = pokemonName.capitalize;
    }

    // Store the list of Pokemon names in Hive
    return pokemonNames;
  } catch (e) {
    throw Exception('bFailed to load Pokemon names: $e');
  }
}

final pokemonNamesProvider = FutureProvider<Map<int, String>>((ref) async {
  try {
    // Get the Hive box (assuming it's already open)
    final pokemonBox = Hive.box(allPokemonNamesBox);

    // Check if the Hive box contains the 'pokemonNames' key
    if (!pokemonBox.containsKey(allPokemonNamesBoxKey)) {
      // Load data from JSON and store in Hive
      final pokemonNames = await _loadPokemonDataFromJson();
      pokemonBox.put(allPokemonNamesBoxKey, pokemonNames);
    }

    // Retrieve Pokemon data from Hive
    final pokemonNames = pokemonBox.get(allPokemonNamesBoxKey).cast<int,String>();

    if (pokemonNames.isEmpty)
    {
      debugPrint("[Error][pokemonNamesProvider] Names not in hive even after adding.");
      return await _loadPokemonDataFromJson();
    }

    return pokemonNames;
  } catch (e, s) {
    throw Exception('aFailed to load Pokemon names: $e\n\n$s');
  }
});
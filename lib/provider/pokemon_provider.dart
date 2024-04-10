import 'dart:convert';
import 'package:guessthegyarados/consts/api_links.dart';
import 'package:http/http.dart' as http;
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

final pokemonNamesProvider = FutureProvider<Map<int, String>>((ref) async {
  final response = await http.get(Uri.parse(pokemonNamesApiLink));

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);
    final results = jsonData['results'] as List<dynamic>;

    final pokemonNames = <int, String>{};

    for (int i = 0; i < results.length; i++) {
      final pokemonData = results[i];
      final pokemonName = pokemonData['name'];
      final pokemonId = i + 1; // Assuming the IDs start from 1
      pokemonNames[pokemonId] = pokemonName;
    }

    return pokemonNames;
  } else {
    throw Exception('Failed to fetch Pokemon names');
  }
});
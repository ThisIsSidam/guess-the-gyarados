import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:guessthegyarados/core/constants/asset_paths.dart';
import 'package:guessthegyarados/core/extensions/string_extensions.dart';

/// Parses the bundled `pokemon_names.json` asset once and memoizes the
/// result in memory. No persistence: it's static bundled data, so
/// re-parsing on cold start is cheap and there's no cache to keep in sync.
class PokemonNamesService {
  Map<int, String>? _cache;

  Future<Map<int, String>> loadNames() async {
    final cached = _cache;
    if (cached != null) return cached;

    final jsonString = await rootBundle.loadString(pokemonNamesJson);
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final results = decoded['results'] as List<dynamic>;

    final names = <int, String>{};
    for (var i = 0; i < results.length; i++) {
      final String name = results[i]['name'];
      if (name.contains('-totem')) continue;
      names[i + 1] = name.capitalize;
    }

    _cache = names;
    return names;
  }
}

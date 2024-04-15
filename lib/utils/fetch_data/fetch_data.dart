import 'dart:convert';
import 'dart:math';
import 'package:guessthegyarados/consts/api_links.dart';
import 'package:guessthegyarados/pokemon_class/pokemon.dart';
import 'package:guessthegyarados/utils/misc_methods.dart';
import 'package:http/http.dart' as http;

Future<Pokemon> fetchPokemonData(int pokemonId) async {
  final speciesUrl = Uri.parse('$pokemonSpeciesDataApiLink$pokemonId');
  final speciesResponse = await http.get(speciesUrl);

  if (speciesResponse.statusCode == 200) {
    final speciesData = json.decode(speciesResponse.body);
    final varieties = speciesData['varieties'] as List<dynamic>;

// Filter out varieties with '-mega', '-gmax', '-totem' in the name
final filteredVarieties = varieties.where((variety) {
  final varietyName = variety['pokemon']['name'];
  return !excludePokemon(varietyName);
}).toList();

// Randomly select one variety from filtered list.
final random = Random();
final selectedVariety = filteredVarieties[random.nextInt(filteredVarieties.length)];

final pokemonUrl = Uri.parse(selectedVariety['pokemon']['url']);
final pokemonResponse = await http.get(pokemonUrl);

if (pokemonResponse.statusCode == 200) {
  final jsonData = json.decode(pokemonResponse.body);
  return Pokemon.fromJsonAsync(jsonData);
} else {
  throw Exception('Failed to fetch Pokemon data');
}
  } else {
    throw Exception('Failed to fetch Pokemon species data');
  }
}

Future<Map<String, dynamic>> fetchJsonFromUrl(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to fetch species data');
  }
}


import 'dart:convert';
import 'package:guessthegyarados/consts/api_links.dart';
import 'package:guessthegyarados/pokemon_class/pokemon.dart';
import 'package:http/http.dart' as http;

Future<Pokemon> fetchPokemonData(int pokemonId) async {
  final url = Uri.parse('$getPokemon$pokemonId');
  final response = await http.get(url);

  if (response.statusCode == 200) 
  {
    final jsonData = json.decode(response.body);
    return Pokemon.fromJsonAsync(jsonData);
  } 
  else 
  {
    throw Exception('Failed to fetch Pokemon data');
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


import 'dart:convert';
import 'package:guessthegyarados/consts/api_links.dart';
import 'package:guessthegyarados/database/pokemon_data_db.dart';
import 'package:guessthegyarados/pokemon_class/pokemon.dart';
import 'package:http/http.dart' as http;

Future<Pokemon> fetchPokemonFromPokemonId(int id) async {

  Pokemon? pokemon = PokemonDB.getData(id);

  if (pokemon != null) return pokemon;

  final pokemonUrl = Uri.parse("$pokemonDataApiLink$id");
  final pokemonResponse = await http.get(pokemonUrl);

  if (pokemonResponse.statusCode == 200)
  {
    final pokemonData = json.decode(pokemonResponse.body);
    return Pokemon.fromJsonAsync(pokemonData);
  }
  else
  {
    throw "[fetchPokemonFromPokemonId] failed";
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


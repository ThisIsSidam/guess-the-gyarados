import 'package:guessthegyarados/utils/fetch_data.dart';

class Pokemon {
  final int id;
  final String name;
  final int generation;
  final int height;
  final int weight;
  final Map<int, String> abilities;
  final int noOfForms;
  final List<String> types;
  final String spriteUrl;
  int evolutionTreeSize;
  String? evolutionItem;
  List<String> usableEvolutionItems;
  int stageOfEvolution;
  String cry; // New attribute
  bool hasMega; // New attribute
  bool hasGmax; // New attribute

  Pokemon({
    required this.id,
    required this.name,
    required this.generation,
    required this.height,
    required this.weight,
    Map<int, String>? abilities,
    required this.noOfForms,
    required this.types,
    required this.spriteUrl,
    required this.evolutionTreeSize,
    this.evolutionItem,
    this.usableEvolutionItems = const [],
    this.stageOfEvolution = 1,
    required this.cry, // New parameter
    required this.hasMega, // New parameter
    required this.hasGmax, // New parameter
  }) : abilities = abilities ?? {0: '', 1: '', 2: ''};

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final abilities = extractAbilities(json['abilities']);
    final forms = json['forms']?.length ?? 0;
    final types = extractTypes(json['types']);
    final spriteUrl = json['sprites']['front_default'];
    final generation = getGeneration(json['id']);
    final cry = json['cries']['latest'] ?? '';

    return Pokemon(
      id: json['id'],
      name: json['name'],
      generation: generation,
      height: json['height'],
      weight: json['weight'],
      abilities: abilities,
      noOfForms: forms,
      types: types,
      spriteUrl: spriteUrl,
      evolutionTreeSize: 0, 
      cry: cry, 
      hasMega: false, 
      hasGmax: false, 
    );
  }

  static Future<Pokemon> fromJsonAsync(Map<String, dynamic> json) async {
    final pokemon = Pokemon.fromJson(json);
    final speciesUrl = json['species']['url'];
    final speciesData = await fetchJsonFromUrl(speciesUrl);
    final evolutionChainJson = await fetchJsonFromUrl(speciesData['evolution_chain']['url']);

    final evolutionDetails = getEvolutionDetails(evolutionChainJson, pokemon.name);

    pokemon.evolutionTreeSize = evolutionDetails['evolutionTreeSize'];
    pokemon.evolutionItem = evolutionDetails['evolutionItem'];
    pokemon.usableEvolutionItems = evolutionDetails['usableEvolutionItems'];
    pokemon.stageOfEvolution = evolutionDetails['stageOfEvolution'];

    final varieties = speciesData['varieties'];
    for (final variety in varieties) {
      final varieName = variety['pokemon']['name'];
      if (varieName.endsWith('-mega')) {
        pokemon.hasMega = true;
      } else if (varieName.endsWith('-gmax')) {
        pokemon.hasGmax = true;
      }
    }

    return pokemon;
  }

  static Map<int, String> extractAbilities(List<dynamic> abilitiesJson) {
    final abilities = <int, String>{};

    for (int i = 0; i < abilitiesJson.length; i++) {
      final abilityJson = abilitiesJson[i];
      final isHidden = abilityJson['is_hidden'];
      final abilityName = abilityJson['ability']['name'];

      if (isHidden) {
        if (abilities[0] == null) {
          abilities[0] = abilityName;
        }
      } else {
        if (abilities[1] == null) {
          abilities[1] = abilityName;
        } else if (abilities[2] == null) {
          abilities[2] = abilityName;
        }
      }
    }

    return abilities;
  }

  static List<String> extractTypes(List<dynamic> typesJson) {
    final types = <String>[];

    for (final typeJson in typesJson) {
      final typeName = typeJson['type']['name'];
      types.add(typeName);
      if (types.length == 2) {
        break;
      }
    }

    return types;
  }

  static int getGeneration(int pokemonId) {
    if (pokemonId <= 151) {
      return 1;
    } else if (pokemonId <= 251) {
      return 2;
    } else if (pokemonId <= 386) {
      return 3;
    } else if (pokemonId <= 493) {
      return 4;
    } else if (pokemonId <= 649) {
      return 5;
    } else if (pokemonId <= 721) {
      return 6;
    } else if (pokemonId <= 809) {
      return 7;
    } else {
      return 8;
    }
  }

  static Map<String, dynamic> getEvolutionDetails(Map<String, dynamic> evolutionChainJson, String pokemonName) {
    final chain = evolutionChainJson['chain'];
    int count = 1; // Start with 1 (the base Pokémon)
    String? evolutionItem;
    List<String> usableEvolutionItems = [];
    int stageOfEvolution = 1; // Initialize with 1

    void countEvolutions(Map<String, dynamic> chainData, int currentStage) {
      final currentSpeciesName = chainData['species']['name'];
      if (currentSpeciesName == pokemonName) {
        // This is the current Pokémon's evolution data
        final evolutionDetails = chainData['evolution_details'];
        if (evolutionDetails != null && evolutionDetails.isNotEmpty) {
          final item = evolutionDetails[0]['item'];
          if (item != null) {
            evolutionItem = item['name'];
          } else {
            evolutionItem = null;
          }
        }
        stageOfEvolution = currentStage; // Update the stage of evolution
      }

      if (chainData.containsKey('evolves_to')) {
        final evolutions = chainData['evolves_to'] as List;
        count += evolutions.length;
        for (int i = 0; i < evolutions.length; i++) {
          final evolution = evolutions[i];
          final evolutionDetails = evolution['evolution_details'];
          if (evolutionDetails != null && evolutionDetails.isNotEmpty) {
            final item = evolutionDetails[0]['item'];
            if (item != null) {
              usableEvolutionItems.add(item['name']);
            }
          }
          countEvolutions(evolution, currentStage + 1); // Increment the stage for the next evolution
        }
      }
    }

    countEvolutions(chain, stageOfEvolution);
    return {
      'evolutionTreeSize': count,
      'evolutionItem': evolutionItem,
      'usableEvolutionItems': usableEvolutionItems,
      'stageOfEvolution': stageOfEvolution,
    };
  }
}
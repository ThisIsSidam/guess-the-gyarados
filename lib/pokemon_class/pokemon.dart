import 'package:guessthegyarados/utils/fetch_data/fetch_data.dart';
import 'package:guessthegyarados/utils/misc_methods.dart';

class Pokemon {
  final int id;
  final String name;
  final int generation;
  final Map<int, String> abilities;
  final int noOfForms;
  final List<String> types;
  final String spriteUrl;
  final String shinySpriteUrl;
  int evolutionTreeSize;
  String? evolutionItem;
  List<String> usableEvolutionItems;
  int stageOfEvolution;
  String cry; 
  bool hasMega; 
  bool hasGmax; 
  bool isBaby;
  bool isLegendary;
  bool isMythical;
  bool isStarter;

  Pokemon({
    required this.id,
    required this.name,
    required this.generation,
    Map<int, String>? abilities,
    required this.noOfForms,
    required this.types,
    required this.spriteUrl,
    required this.shinySpriteUrl,
    required this.evolutionTreeSize,
    this.evolutionItem,
    this.usableEvolutionItems = const [],
    this.stageOfEvolution = 1,
    required this.cry, 
    required this.hasMega, 
    required this.hasGmax, 
    required this.isBaby,
    required this.isLegendary,
    required this.isMythical,
    required this.isStarter
  }) : abilities = abilities ?? {0: '', 1: '', 2: ''};

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final abilities = extractAbilities(json['abilities']);
    final forms = json['forms']?.length ?? 0;
    final types = extractTypes(json['types']);
    final spriteUrl = json['sprites']['front_default'];
    final shinySpriteUrl = json['sprites']['front_shiny'];
    final generation = getGeneration(json['id']);
    final cry = json['cries']['latest'] ?? '';
    final String name = json['name'];

    return Pokemon(
      id: json['id'],
      name: capitalizeString(name),
      generation: generation,
      abilities: abilities,
      noOfForms: forms,
      types: types,
      spriteUrl: spriteUrl,
      shinySpriteUrl: shinySpriteUrl,
      evolutionTreeSize: 0, 
      cry: cry, 
      hasMega: false, 
      hasGmax: false, 
      isBaby: false,
      isLegendary: false,
      isMythical: false,
      isStarter: checkIfStarter(json['id'])
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
      if (varieName.contains('-mega')) {
        pokemon.hasMega = true;
      } else if (varieName.contains('-gmax')) {
        pokemon.hasGmax = true;
      }
    }

    pokemon.isBaby = speciesData['is_baby'];
    pokemon.isLegendary = speciesData['is_legendary'];
    pokemon.isMythical = speciesData['is_mythical'];

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
    int evolutionTreeSize = 1; // Start with 1 (the base Pokémon)
    String? evolutionItem;
    List<String> usableEvolutionItems = [];
    int stageOfEvolution = 1; // Initialize with 1

    void countEvolutions(Map<String, dynamic> chainData, int currentStage) {
      final currentSpeciesName = chainData['species']['name'];
      if (currentSpeciesName == pokemonName.toLowerCase()) 
      {
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
        evolutionTreeSize += evolutions.length;
        for (final evolution in evolutions) {
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
      'evolutionTreeSize': evolutionTreeSize,
      'evolutionItem': evolutionItem,
      'usableEvolutionItems': usableEvolutionItems,
      'stageOfEvolution': stageOfEvolution,
    };
  }

  static bool checkIfStarter(int id) {
    List<int> starterPokemonIds = [
      1, 2, 3,     // Bulbasaur, Ivysaur, Venusaur
      4, 5, 6,     // Charmander, Charmeleon, Charizard
      7, 8, 9,     // Squirtle, Wartortle, Blastoise
      152, 153, 154, // Chikorita, Bayleef, Meganium
      155, 156, 157, // Cyndaquil, Quilava, Typhlosion
      158, 159, 160, // Totodile, Croconaw, Feraligatr
      252, 253, 254, // Treecko, Grovyle, Sceptile
      255, 256, 257, // Torchic, Combusken, Blaziken
      258, 259, 260, // Mudkip, Marshtomp, Swampert
      387, 388, 389, // Turtwig, Grotle, Torterra
      390, 391, 392, // Chimchar, Monferno, Infernape
      393, 394, 395, // Piplup, Prinplup, Empoleon
      495, 496, 497, // Snivy, Servine, Serperior
      498, 499, 500, // Tepig, Pignite, Emboar
      501, 502, 503, // Oshawott, Dewott, Samurott
      650, 651, 652, // Chespin, Quilladin, Chesnaught
      653, 654, 655, // Fennekin, Braixen, Delphox
      656, 657, 658, // Froakie, Frogadier, Greninja
      722, 723, 724, // Rowlet, Dartrix, Decidueye
      725, 726, 727, // Litten, Torracat, Incineroar
      728, 729, 730, // Popplio, Brionne, Primarina
      810, 811, 812, // Grookey, Thwackey, Rillaboom
      813, 814, 815, // Scorbunny, Raboot, Cinderace
      816, 817, 818, // Sobble, Drizzile, Inteleon
      906, 907, 908, // Sprigatito, Fuecoco, Quaxly
      909, 910, 911, // Sprigaquil, Crocalor, Quaxider
      912, 913, 914  // Meowscarada, Skeledric, Quaquavalier
    ];

    return starterPokemonIds.contains(id);
  }
}
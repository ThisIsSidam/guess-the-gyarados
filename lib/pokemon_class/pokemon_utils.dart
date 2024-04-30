class PokemonUtils {
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

  static Map<String, dynamic> getEvolutionDetails(
      Map<String, dynamic> evolutionChainJson, String pokemonName) {
    final chain = evolutionChainJson['chain'];
    int evolutionTreeSize = 1; // Start with 1 (the base Pokémon)
    String? evolutionItem;
    List<String> usableEvolutionItems = [];
    int stageOfEvolution = 1; // Initialize with 1

    void countEvolutions(Map<String, dynamic> chainData, int currentStage) {
      final currentSpeciesName = chainData['species']['name'];
      if (currentSpeciesName == pokemonName.toLowerCase()) {
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

  static bool checkIfPseudo(int id) {
    List<int> pseudoLegendaryPokemonIds = [
      147,148,149, // Gen 1
      246,247,248, // Gen 2
      372,373,374, // Gen 3
      374,375,376, // Gen 3
      443,444,445, // Gen 4
      770,771,635,706,707,690,691, // Gen 5
      784,785,786, // Gen 7
      996,997,998]; // Gen 9

      return pseudoLegendaryPokemonIds.contains(id);
  }
}
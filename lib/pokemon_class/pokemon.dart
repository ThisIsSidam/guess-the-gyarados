import 'package:guessthegyarados/pokemon_class/pokemon_utils.dart';
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
  bool isPseudo;

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
    required this.isStarter,
    required this.isPseudo
  }) : abilities = abilities ?? {0: '', 1: '', 2: ''};

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final abilities = PokemonUtils.extractAbilities(json['abilities']);
    final forms = json['forms']?.length ?? 0;
    final types = PokemonUtils.extractTypes(json['types']);
    final spriteUrl = json['sprites']['front_default'];
    final shinySpriteUrl = json['sprites']['front_shiny'];
    final generation = PokemonUtils.getGeneration(json['id']);
    final cry = json['cries']['latest'] ?? '';
    final String name = json['name'];
    final int id = json['id'];

    return Pokemon(
      id: id,
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
      isStarter: PokemonUtils.checkIfStarter(id),
      isPseudo: PokemonUtils.checkIfPseudo(id)
    );
  }

  static Future<Pokemon> fromJsonAsync(Map<String, dynamic> json) async {
    final pokemon = Pokemon.fromJson(json);
    final speciesUrl = json['species']['url'];
    final speciesData = await fetchJsonFromUrl(speciesUrl);
    final evolutionChainJson =
        await fetchJsonFromUrl(speciesData['evolution_chain']['url']);

    final evolutionDetails =
        PokemonUtils.getEvolutionDetails(evolutionChainJson, pokemon.name);

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
}
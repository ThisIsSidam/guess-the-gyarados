import 'package:guessthegyarados/pokemon_class/pokemon_utils.dart';
import 'package:guessthegyarados/utils/fetch_data/fetch_data.dart';
import 'package:guessthegyarados/utils/misc_methods.dart';
import 'package:hive/hive.dart';
part 'pokemon.g.dart';

@HiveType(typeId: 0)
class Pokemon {
   @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int generation;

  @HiveField(3)
  final Map<int, String> abilities;

  @HiveField(4)
  final int noOfForms;

  @HiveField(5)
  final List<String> types;

  @HiveField(6)
  final String spriteUrl;

  @HiveField(7)
  final String shinySpriteUrl;

  @HiveField(8)
  int evolutionTreeSize;

  @HiveField(9)
  String? evolutionItem;

  @HiveField(10)
  List<String> usableEvolutionItems;

  @HiveField(11)
  int stageOfEvolution;

  @HiveField(12)
  String cry;

  @HiveField(13)
  bool hasMega;

  @HiveField(14)
  bool hasGmax;

  @HiveField(15)
  bool isBaby;

  @HiveField(16)
  bool isLegendary;

  @HiveField(17)
  bool isMythical;

  @HiveField(18)
  bool isStarter;

  @HiveField(19)
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
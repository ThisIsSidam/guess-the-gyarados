import 'package:objectbox/objectbox.dart';

/// Local cache of a Pokemon's derived/parsed data, keyed by its real PokeAPI
/// id. Separate from [PokemonDto] (the API wire format) — see
/// `data/remote/pokemon_dto.dart` for why the two aren't the same class.
@Entity()
class PokemonEntity {
  PokemonEntity({
    this.id = 0,
    required this.name,
    required this.generation,
    required this.bst,
    this.hiddenAbility,
    this.ability1,
    this.ability2,
    required this.noOfForms,
    required this.types,
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
    required this.isPseudo,
    required this.isMega,
    required this.isGmax,
    required this.speciesID,
    required this.variantIDs,
  });

  /// Reuses the actual PokeAPI pokemon id as the ObjectBox primary key.
  /// `assignable: true` because we always set a real, non-zero id ourselves
  /// rather than letting ObjectBox auto-increment one.
  @Id(assignable: true)
  int id;

  String name;
  int generation;
  int bst;

  // Flattened from the API's `Map<int,String> abilities` (0=hidden, 1/2=normal).
  String? hiddenAbility;
  String? ability1;
  String? ability2;

  int noOfForms;
  List<String> types;

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
  bool isMega;
  bool isGmax;

  int speciesID;
  List<int> variantIDs;
}

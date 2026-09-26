import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:guessthegyarados/core/extensions/string_extensions.dart';
import 'package:guessthegyarados/shared/data/entities/pokemon_entity.dart';
import 'package:guessthegyarados/shared/data/remote/pokemon_api_parser.dart';

part 'generated/pokemon_dto.freezed.dart';

/// The PokeAPI wire format. Deliberately kept separate from [PokemonEntity]
/// (the ObjectBox local cache) rather than made into one dual-purpose class —
/// see the "Model design" note in AGENTS.md for why.
@freezed
abstract class PokemonDto with _$PokemonDto {
  const PokemonDto._();

  const factory PokemonDto({
    required int id,
    required String name,
    required int generation,
    required int bst,
    required Map<int, String> abilities,
    required int noOfForms,
    required List<String> types,
    required String spriteUrl,
    required String shinySpriteUrl,
    required int evolutionTreeSize,
    String? evolutionItem,
    @Default(<String>[]) List<String> usableEvolutionItems,
    @Default(1) int stageOfEvolution,
    required String cry,
    required bool hasMega,
    required bool hasGmax,
    required bool isBaby,
    required bool isLegendary,
    required bool isMythical,
    required bool isStarter,
    required bool isPseudo,
    required int speciesID,
    required List<int> variantIDs,
    required bool isMega,
    required bool isGmax,
  }) = _PokemonDto;

  /// Parses the base `/pokemon/{id}` PokeAPI response. Species/evolution
  /// fields are left at their defaults — [PokemonRepository] fills them in
  /// with a `copyWith` after fetching the species and evolution-chain data.
  factory PokemonDto.fromPokemonJson(Map<String, dynamic> json) {
    final abilities = PokemonUtils.extractAbilities(json['abilities']);
    final types = PokemonUtils.extractTypes(json['types']);
    final spriteUrl = json['sprites']['front_default'];
    final shinySpriteUrl = json['sprites']['front_shiny'];
    final cry = json['cries']['latest'] ?? '';
    final String name = json['name'];
    final int id = json['id'];

    return PokemonDto(
      id: id,
      name: name.capitalize,
      generation: -1,
      bst: PokemonUtils.getBST(json['stats']),
      abilities: abilities,
      noOfForms: json['forms']?.length ?? 0,
      types: types,
      spriteUrl: spriteUrl ?? 'null',
      shinySpriteUrl: shinySpriteUrl ?? 'null',
      evolutionTreeSize: 0,
      cry: cry,
      hasMega: false,
      hasGmax: false,
      isBaby: false,
      isLegendary: false,
      isMythical: false,
      isStarter: PokemonUtils.checkIfStarter(id),
      isPseudo: PokemonUtils.checkIfPseudo(id),
      speciesID: 0,
      variantIDs: const [],
      isMega: name.contains('-mega'),
      isGmax: name.contains('-gmax'),
    );
  }

  PokemonEntity toEntity() {
    return PokemonEntity(
      id: id,
      name: name,
      generation: generation,
      bst: bst,
      hiddenAbility: abilities[0],
      ability1: abilities[1],
      ability2: abilities[2],
      noOfForms: noOfForms,
      types: types,
      evolutionTreeSize: evolutionTreeSize,
      evolutionItem: evolutionItem,
      usableEvolutionItems: usableEvolutionItems,
      stageOfEvolution: stageOfEvolution,
      cry: cry,
      hasMega: hasMega,
      hasGmax: hasGmax,
      isBaby: isBaby,
      isLegendary: isLegendary,
      isMythical: isMythical,
      isStarter: isStarter,
      isPseudo: isPseudo,
      isMega: isMega,
      isGmax: isGmax,
      speciesID: speciesID,
      variantIDs: variantIDs,
    );
  }
}

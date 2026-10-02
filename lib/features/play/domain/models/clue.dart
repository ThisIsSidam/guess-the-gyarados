import 'package:flutter/material.dart';
import 'package:guessthegyarados/shared/data/entities/pokemon_entity.dart';
import 'package:guessthegyarados/shared/domain/models/region.dart';

/// A boolean clue reveals its answer the instant it's tapped (nothing to
/// pick). A choice clue opens the shared [InlineAnswerPanel] so the player
/// has to pick the right value out of [ClueSpec.options].
enum ClueKind { boolean, choice }

/// One guessable/revealable fact about the mystery Pokemon. [id] must be
/// unique within a [ClueCatalog] — it's used to track which clues have
/// already been revealed and which one (if any) is currently being answered.
class ClueSpec {
  const ClueSpec({
    required this.id,
    required this.label,
    required this.answer,
    required this.kind,
    required this.icon,
    this.options,
    this.coloredOptions = false,
    this.maxAttempts = 3,
    String? dialogLabel,
  }) : dialogLabel = dialogLabel ?? label;

  final String id;
  final String label;
  // The question text shown when this clue's answer sheet opens — usually
  // the same as [label], but the info-row chips use a short label ("Primary")
  // while the dialog spells it out ("Primary Type").
  final String dialogLabel;
  final String answer;
  final ClueKind kind;
  final IconData icon;
  final List<String>? options;
  final bool coloredOptions;

  /// Wrong picks allowed on a choice clue before its dialog locks (the clue
  /// stays unrevealed). Unused for boolean clues.
  final int maxAttempts;
}

/// Every clue for one round, already split the way the play page presents
/// them: quick descriptive facts in a horizontal info row, and the rest
/// grouped into a handful of carousel cards.
class ClueCatalog {
  const ClueCatalog(
      {required this.infoRow,
      required this.cardGroups,
      required this.cardTitles});

  final List<ClueSpec> infoRow;
  final List<List<ClueSpec>> cardGroups;
  final List<String> cardTitles;
}

const typeOptions = [
  "Fire",
  "Water",
  "Grass",
  "Rock",
  "Steel",
  "Ground",
  "Ghost",
  "Dark",
  "Psychic",
  "Fairy",
  "Dragon",
  "Ice",
  "Electric",
  "Bug",
  "Flying",
  "Poison",
  "Normal",
  "Fighting",
];

/// The region each generation introduced, in generation order (index 0 =
/// generation 1). Generation clues are asked and answered by region name.
final generationRegions = [for (final r in regions) r.name];

/// Base-stat-total brackets, lowest first.
const bstBrackets = ['Under 300', '300-399', '400-499', '500-599', '600+'];

String bstBracket(int bst) {
  if (bst < 300) return bstBrackets[0];
  if (bst < 400) return bstBrackets[1];
  if (bst < 500) return bstBrackets[2];
  if (bst < 600) return bstBrackets[3];
  return bstBrackets[4];
}

const heightBrackets = ['Under 0.5 m', '0.5-1 m', '1-2 m', '2-3 m', 'Over 3 m'];

/// [decimetres] is PokeAPI's unit.
String heightBracket(int decimetres) {
  final metres = decimetres / 10;
  if (metres < 0.5) return heightBrackets[0];
  if (metres < 1) return heightBrackets[1];
  if (metres < 2) return heightBrackets[2];
  if (metres < 3) return heightBrackets[3];
  return heightBrackets[4];
}

const weightBrackets = [
  'Under 5 kg',
  '5-25 kg',
  '25-100 kg',
  '100-300 kg',
  'Over 300 kg',
];

/// [hectograms] is PokeAPI's unit.
String weightBracket(int hectograms) {
  final kg = hectograms / 10;
  if (kg < 5) return weightBrackets[0];
  if (kg < 25) return weightBrackets[1];
  if (kg < 100) return weightBrackets[2];
  if (kg < 300) return weightBrackets[3];
  return weightBrackets[4];
}

const colorOptions = [
  'Black',
  'Blue',
  'Brown',
  'Gray',
  'Green',
  'Pink',
  'Purple',
  'Red',
  'White',
  'Yellow',
];

const habitatOptions = [
  'Cave',
  'Forest',
  'Grassland',
  'Mountain',
  'Rare',
  'Rough terrain',
  'Sea',
  'Urban',
  'Waters edge',
  'None',
];

/// PokeAPI's "rough-terrain" -> "Rough terrain"; no habitat -> "None".
String habitatLabel(String? habitat) {
  if (habitat == null || habitat.isEmpty) return 'None';
  final spaced = habitat.replaceAll('-', ' ');
  return '${spaced[0].toUpperCase()}${spaced.substring(1)}';
}

ClueCatalog buildClueCatalog(PokemonEntity pokemon) {
  final types = pokemon.types;
  final type1 = types.first;
  final type2 = types.length > 1 ? types.last : types.first;

  final infoRow = [
    ClueSpec(
      id: "type1",
      label: "Primary",
      dialogLabel: "Primary Type",
      answer: type1,
      kind: ClueKind.choice,
      icon: Icons.category,
      options: typeOptions,
      coloredOptions: true,
    ),
    ClueSpec(
      id: "type2",
      label: "Secondary",
      dialogLabel: "Secondary Type",
      answer: type2,
      kind: ClueKind.choice,
      icon: Icons.category,
      options: typeOptions,
      coloredOptions: true,
    ),
  ];

  final cardGroups = [
    [
      ClueSpec(
        id: "generation",
        label: "Generation",
        answer: generationRegions[
            (pokemon.generation - 1).clamp(0, generationRegions.length - 1)],
        kind: ClueKind.choice,
        icon: Icons.filter_9_plus,
        options: generationRegions,
      ),
      ClueSpec(
        id: "evoStage",
        label: "Evo. Stage",
        answer: pokemon.stageOfEvolution.toString(),
        kind: ClueKind.choice,
        icon: Icons.timeline,
        options: List.generate(3, (i) => (i + 1).toString()),
        // One in three is a coin flip with a spare; two tries keeps it honest.
        maxAttempts: 2,
      ),
      ClueSpec(
        id: "evoTreeSize",
        label: "Evo. Tree Size",
        answer: pokemon.evolutionTreeSize.toString(),
        kind: ClueKind.choice,
        icon: Icons.account_tree,
        options: List.generate(10, (i) => (i + 1).toString()),
      ),
      ClueSpec(
        id: "bst",
        label: "Base Stats",
        dialogLabel: "Base Stat Total",
        answer: bstBracket(pokemon.bst),
        kind: ClueKind.choice,
        icon: Icons.bar_chart,
        options: bstBrackets,
      ),
    ],
    [
      ClueSpec(
        id: "height",
        label: "Height",
        answer: heightBracket(pokemon.height),
        kind: ClueKind.choice,
        icon: Icons.height,
        options: heightBrackets,
      ),
      ClueSpec(
        id: "weight",
        label: "Weight",
        answer: weightBracket(pokemon.weight),
        kind: ClueKind.choice,
        icon: Icons.fitness_center,
        options: weightBrackets,
      ),
      ClueSpec(
        id: "color",
        label: "Colour",
        answer: pokemon.color == null
            ? 'None'
            : '${pokemon.color![0].toUpperCase()}${pokemon.color!.substring(1)}',
        kind: ClueKind.choice,
        icon: Icons.palette,
        options: colorOptions,
      ),
      ClueSpec(
        id: "habitat",
        label: "Habitat",
        answer: habitatLabel(pokemon.habitat),
        kind: ClueKind.choice,
        icon: Icons.landscape,
        options: habitatOptions,
      ),
    ],
    [
      ClueSpec(
        id: "hasMega",
        label: "Has a Mega Evolution",
        answer: pokemon.hasMega ? "Yes" : "No",
        kind: ClueKind.boolean,
        icon: Icons.bolt,
      ),
      ClueSpec(
        id: "isMega",
        label: "Is a Mega Form",
        answer: pokemon.isMega ? "Yes" : "No",
        kind: ClueKind.boolean,
        icon: Icons.auto_awesome,
      ),
      ClueSpec(
        id: "hasGmax",
        label: "Has a Gigantamax Form",
        answer: pokemon.hasGmax ? "Yes" : "No",
        kind: ClueKind.boolean,
        icon: Icons.expand,
      ),
      ClueSpec(
        id: "isGmax",
        label: "Is a Gigantamax Form",
        answer: pokemon.isGmax ? "Yes" : "No",
        kind: ClueKind.boolean,
        icon: Icons.expand_more,
      ),
    ],
    [
      ClueSpec(
        id: "isBaby",
        label: "Is a Baby Pokemon",
        answer: pokemon.isBaby ? "Yes" : "No",
        kind: ClueKind.boolean,
        icon: Icons.child_care,
      ),
      ClueSpec(
        id: "isLegendary",
        label: "Is a Legendary",
        answer: pokemon.isLegendary ? "Yes" : "No",
        kind: ClueKind.boolean,
        icon: Icons.star,
      ),
      ClueSpec(
        id: "isMythical",
        label: "Is a Mythical",
        answer: pokemon.isMythical ? "Yes" : "No",
        kind: ClueKind.boolean,
        icon: Icons.auto_awesome_motion,
      ),
    ],
    [
      ClueSpec(
        id: "itemEvolution",
        label: "Evolved Using an Item",
        answer: pokemon.evolutionItem != null ? "Yes" : "No",
        kind: ClueKind.boolean,
        icon: Icons.diamond,
      ),
      ClueSpec(
        id: "isStarter",
        label: "Is a Starter",
        answer: pokemon.isStarter ? "Yes" : "No",
        kind: ClueKind.boolean,
        icon: Icons.flag,
      ),
      ClueSpec(
        id: "isPseudo",
        label: "Is a Pseudo-Legendary",
        answer: pokemon.isPseudo ? "Yes" : "No",
        kind: ClueKind.boolean,
        icon: Icons.shield,
      ),
    ],
  ];

  return ClueCatalog(
    infoRow: infoRow,
    cardGroups: cardGroups,
    cardTitles: const [
      "General Info",
      "Body & Looks",
      "Mega & Gmax",
      "Origin",
      "Evolution Traits"
    ],
  );
}

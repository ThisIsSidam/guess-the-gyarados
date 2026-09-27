import 'package:flutter/material.dart';
import 'package:guessthegyarados/shared/data/entities/pokemon_entity.dart';

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
        answer: pokemon.generation.toString(),
        kind: ClueKind.choice,
        icon: Icons.filter_9_plus,
        options: List.generate(9, (i) => (i + 1).toString()),
      ),
      ClueSpec(
        id: "evoStage",
        label: "Evo. Stage",
        answer: pokemon.stageOfEvolution.toString(),
        kind: ClueKind.choice,
        icon: Icons.timeline,
        options: List.generate(3, (i) => (i + 1).toString()),
      ),
      ClueSpec(
        id: "evoTreeSize",
        label: "Evo. Tree Size",
        answer: pokemon.evolutionTreeSize.toString(),
        kind: ClueKind.choice,
        icon: Icons.account_tree,
        options: List.generate(10, (i) => (i + 1).toString()),
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
      "Mega & Gmax",
      "Origin",
      "Evolution Traits"
    ],
  );
}

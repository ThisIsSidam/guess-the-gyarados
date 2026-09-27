import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/core/constants/asset_paths.dart';
import 'package:guessthegyarados/core/di/injection.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';
import 'package:guessthegyarados/core/theme/pokemon_type_colors.dart';
import 'package:guessthegyarados/features/play/domain/models/clue.dart';
import 'package:guessthegyarados/features/play/presentation/widgets/backdrop/folded_backdrop.dart';
import 'package:guessthegyarados/features/play/presentation/widgets/catching/catching_widget.dart';
import 'package:guessthegyarados/features/play/presentation/widgets/question/clue_answer_sheet.dart';
import 'package:guessthegyarados/features/play/presentation/widgets/question/clue_carousel.dart';
import 'package:guessthegyarados/features/play/presentation/widgets/question/clue_tile.dart';
import 'package:guessthegyarados/features/play/presentation/widgets/reveal/pokemon_morph_reveal.dart';
import 'package:guessthegyarados/features/profile/data/repositories/user_profile_repository.dart';
import 'package:guessthegyarados/shared/application/providers/caught_pokemon_provider.dart';
import 'package:guessthegyarados/shared/application/providers/pokemon_names_provider.dart';
import 'package:guessthegyarados/shared/application/providers/pokemon_provider.dart';
import 'package:guessthegyarados/shared/application/providers/steps_provider.dart';
import 'package:guessthegyarados/shared/data/entities/pokemon_entity.dart';
import 'package:guessthegyarados/shared/data/entities/pokemon_interaction_entity.dart';
import 'package:guessthegyarados/shared/data/repositories/user_pokemon_repository.dart';
import 'package:guessthegyarados/shared/presentation/widgets/audio_player_widget.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/tilt_card.dart';
import 'package:guessthegyarados/shared/presentation/widgets/pokemon_sprite_image.dart';
import 'package:guessthegyarados/shared/presentation/widgets/screens/error_screen.dart';
import 'package:guessthegyarados/shared/presentation/widgets/screens/loading_screen.dart';

/// Neutral, per-round-stable accent colors shown before any type clue has
/// been revealed — picked from [randomId] so they don't flicker on rebuild,
/// but they carry no hint about the mystery Pokemon's actual type(s).
const _neutralAccents = [
  Colors.teal,
  Colors.orange,
  Colors.pink,
  Colors.cyan,
  Colors.amber,
  Colors.blueGrey,
  Colors.lightGreen,
];

class PlayPage extends ConsumerStatefulWidget {
  const PlayPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlayPageState();
}

class _PlayPageState extends ConsumerState<PlayPage> {
  final randomId = Random().nextInt(1025) + 1; // Randomly pick a pokemon id
  bool isShiny = false;

  @override // Lucky enough for a shiny?
  void initState() {
    final shinyChances = Random().nextInt(1000);
    if (shinyChances == 69) isShiny = true; // ¯\_(ツ)_/¯ (¬‿¬)

    super.initState();
  }

  late int stepsCount = ref.read(stepsCounterProvider);

  bool pokemonGuessedCorrectly = false;

  // Which clues have already been guessed/revealed this round.
  final Set<String> revealedClueIds = {};

  Color get _neutralAccent =>
      _neutralAccents[randomId % _neutralAccents.length];

  @override
  Widget build(BuildContext context) {
    final arceusImage = Image.asset(
      arceusImagePath,
      height: 200,
      width: 200,
      fit: BoxFit.contain,
    );

    // Load data
    final pokemonAsync = ref.watch(pokemonProvider(randomId));
    final pokemonsMap = ref.watch(pokemonNamesProvider).value;
    stepsCount = ref.watch(stepsCounterProvider);

    return pokemonAsync.when(
      data: (thisPokemon) {
        debugPrint(thisPokemon.name + thisPokemon.bst.toString());

        final catalog = buildClueCatalog(thisPokemon);
        final accentColor = _accentColorFor(catalog);

        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: FoldedBackdrop(
            accentColor: accentColor,
            child: SafeArea(
              child: Column(
                children: [
                  topBar(thisPokemon, accentColor),
                  Expanded(
                    flex: pokemonGuessedCorrectly ? 4 : 5,
                    child: revealArea(thisPokemon, pokemonsMap ?? const {}),
                  ),
                  if (pokemonGuessedCorrectly)
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: CatchingWidget(
                          steps: stepsCount,
                          pokemon: thisPokemon,
                          isShiny: isShiny,
                        ),
                      ),
                    )
                  else ...[
                    infoRow(catalog, accentColor),
                    const SizedBox(height: 8),
                    ClueCarousel(
                      cardGroups: catalog.cardGroups,
                      cardTitles: catalog.cardTitles,
                      revealedIds: revealedClueIds,
                      accentColor: accentColor,
                      onClueTap: (clue) => onClueTap(clue, accentColor),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (!pokemonGuessedCorrectly)
                    getSubmissionBar(thisPokemon,
                        pokemonsMap?.values.toList() ?? const [], accentColor),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
      error: (err, stack) {
        debugPrint("[playPage] Error: $err");
        debugPrint("[playPage] stack : $stack");
        return ErrorScreen(
          image: arceusImage,
          errorText: err.toString(),
        );
      },
      loading: () => HoveringImageLoadingScreen(
        image: arceusImage,
        text: "Lemme think",
      ),
    );
  }

  // The neutral, per-round accent until a type is revealed; blends towards
  // (and eventually becomes) the real type color(s) as Type 1/Type 2 clues
  // are answered correctly.
  Color _accentColorFor(ClueCatalog catalog) {
    final type1 = catalog.infoRow[0];
    final type2 = catalog.infoRow[1];
    final revealed1 = revealedClueIds.contains(type1.id);
    final revealed2 = revealedClueIds.contains(type2.id);

    if (!revealed1 && !revealed2) return _neutralAccent;
    if (revealed1 && revealed2) {
      return Color.lerp(getColorFromString(type1.answer),
          getColorFromString(type2.answer), 0.5)!;
    }
    return getColorFromString((revealed1 ? type1 : type2).answer);
  }

  // Deliberately very different: a soft tick for a right pick, a hard
  // double-buzz for a wrong one, so the two are never confused by feel.
  void _feedback(bool success) {
    if (success) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.heavyImpact();
      Future.delayed(
          const Duration(milliseconds: 90), HapticFeedback.heavyImpact);
    }
  }

  void onClueTap(ClueSpec clue, Color accentColor) {
    if (revealedClueIds.contains(clue.id)) return;

    if (clue.kind == ClueKind.boolean) {
      // Nothing to pick — a boolean fact just reveals itself, at the cost
      // of a step.
      setState(() {
        revealedClueIds.add(clue.id);
        ref.read(stepsCounterProvider.notifier).increment();
      });
      _feedback(true);
      return;
    }

    showAnswerSheet(
      context: context,
      question: clue.dialogLabel,
      options: clue.options!,
      correctAnswer: clue.answer,
      coloredOptions: clue.coloredOptions,
      accentColor: accentColor,
      onAttempt: (correct, value) {
        ref.read(stepsCounterProvider.notifier).increment();
        _feedback(correct);
        if (correct) setState(() => revealedClueIds.add(clue.id));
      },
    );
  }

  void onSubmitTap(
      PokemonEntity pokemon, List<String> pokemonNames, Color accentColor) {
    showAnswerSheet(
      context: context,
      question: "Who's that Pokemon?",
      options: pokemonNames,
      correctAnswer: pokemon.name,
      accentColor: accentColor,
      onAttempt: (correct, value) {
        ref.read(stepsCounterProvider.notifier).increment();
        _feedback(correct);
        if (correct) setState(() => pokemonGuessedCorrectly = true);
      },
    );
  }

  Widget revealArea(PokemonEntity thisPokemon, Map<int, String> pokemonNames) {
    return Center(
      child: AudioPlayerWidget(
        audioLink: thisPokemon.cry,
        child: TiltCard(
          child: SizedBox(
            height: 220,
            width: 220,
            child: FlipCard(
              flipped: pokemonGuessedCorrectly,
              front: PokemonMorphReveal(
                pokemonNames: pokemonNames,
                excludeId: thisPokemon.id,
                size: 220,
              ),
              back: PokemonSpriteImage(
                pokemonId: thisPokemon.id,
                pokemonName: thisPokemon.name,
                isShiny: isShiny,
                showLoadingIndicator: false,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Replaces the old AppBar — a plain row on the backdrop itself so there's
  // no separate Material surface/shadow between it and the rest of the page.
  Widget topBar(PokemonEntity thisPokemon, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => onPressedBack(thisPokemon.bst, thisPokemon.name),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  pokemonGuessedCorrectly
                      ? Icons.keyboard_return
                      : Icons.arrow_back,
                  color: GameColors.textOnLight,
                ),
              ),
            ),
          ),
          stepsHudBadge(accentColor),
        ],
      ),
    );
  }

  Widget stepsHudBadge(Color accentColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: GameColors.surfaceRaised,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: accentColor.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.touch_app, size: 18, color: accentColor),
          const SizedBox(width: 6),
          Text(
            "$stepsCount",
            style: const TextStyle(
                color: GameColors.textOnLight, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget infoRow(ClueCatalog catalog, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final clue in catalog.infoRow) ...[
            if (clue != catalog.infoRow.first) const SizedBox(width: 12),
            ClueRowChip(
              clue: clue,
              revealed: revealedClueIds.contains(clue.id),
              onTap: () => onClueTap(clue, accentColor),
            ),
          ],
        ],
      ),
    );
  }

  // Only rendered pre-guess — the exit/return control lives in the app bar.
  Widget getSubmissionBar(
      PokemonEntity pokemon, List<String> pokemonNames, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: submitSearchBar(
          () => onSubmitTap(pokemon, pokemonNames, accentColor), accentColor),
    );
  }

  Widget submitSearchBar(VoidCallback onTap, Color accentColor) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: GameColors.surface,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: accentColor.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: accentColor),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                "Found it? Search the name...",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: GameColors.textMuted, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // For the close button present on bottom bar
  void onPressedBack(int pokemonBST, String pokemonName) {
    if (!pokemonGuessedCorrectly) {
      final snackBar = SnackBar(
        content: Text("${isShiny ? "Shiny" : ''} $pokemonName ran away!"),
        duration: const Duration(seconds: 2),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      getIt<UserPokemonRepository>()
          .recordInteraction(randomId, PokemonInteractionType.couldNotGuess);
      final steps = ref.read(stepsCounterProvider);
      getIt<UserProfileRepository>()
          .addPoints(((pokemonBST / 100) * steps).toInt());
    }

    ref.read(caughtPokemonProvider.notifier).refresh();
    final newAchievements =
        ref.read(caughtPokemonProvider).newlyReceivedAchievements;

    if (newAchievements.isNotEmpty) {
      final snackBar = SnackBar(
        content: Row(
          children: [
            Text(
                "You just received ${newAchievements.length == 1 ? 'an' : 'some'} achievement${newAchievements.length == 1 ? '' : 's'}!"),
          ],
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    Navigator.pop(context);
  }
}

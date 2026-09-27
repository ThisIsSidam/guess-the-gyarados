import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/shared/application/providers/caught_pokemon_provider.dart';
import 'package:guessthegyarados/shared/application/providers/pokemon_names_provider.dart';
import 'package:guessthegyarados/shared/application/providers/pokemon_provider.dart';
import 'package:guessthegyarados/shared/application/providers/steps_provider.dart';
import 'package:guessthegyarados/core/constants/asset_paths.dart';
import 'package:guessthegyarados/core/di/injection.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';
import 'package:guessthegyarados/core/theme/pokemon_type_colors.dart';
import 'package:guessthegyarados/shared/data/entities/pokemon_entity.dart';
import 'package:guessthegyarados/shared/data/entities/pokemon_interaction_entity.dart';
import 'package:guessthegyarados/shared/data/repositories/user_pokemon_repository.dart';
import 'package:guessthegyarados/features/profile/data/repositories/user_profile_repository.dart';
import 'package:guessthegyarados/shared/presentation/widgets/audio_player_widget.dart';
import 'package:guessthegyarados/features/play/presentation/widgets/catching/catching_widget.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/game_button.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/tilt_card.dart';
import 'package:guessthegyarados/shared/presentation/widgets/pokemon_sprite_image.dart';
import 'package:guessthegyarados/features/play/presentation/widgets/question/bottom_sheet_methods.dart';
import 'package:guessthegyarados/features/play/presentation/widgets/question/question_wrapped_utils.dart';
import 'package:guessthegyarados/shared/presentation/widgets/screens/error_screen.dart';
import 'package:guessthegyarados/shared/presentation/widgets/screens/loading_screen.dart';

class PlayPage extends ConsumerStatefulWidget {
  const PlayPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlayPageState();
}

class _PlayPageState extends ConsumerState<PlayPage>{
  final randomId = Random().nextInt(1025) + 1; // Randoly pick a pokemon id
  bool isShiny = false;

  @override // Lucky enough for a shiny?
  void initState() {
    final shinyChances = Random().nextInt(1000);
    if (shinyChances == 69) isShiny = true; // ¯\_(ツ)_/¯ (¬‿¬)

    super.initState();
  }

  late int stepsCount = ref.read(stepsCounterProvider);

  bool pokemonGuessedCorrectly = false;

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

        final questionWrappedUtils = QuestionWrappedUtils(
          pokemon: thisPokemon,
          context: context,
          color: getColorFromString(thisPokemon.name).withValues(alpha: 0.7)
        );

        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  GameColors.backgroundDeep,
                  getColorFromString(thisPokemon.name).withValues(alpha: 0.55),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter
              ),
            ),
            child: Column(
              children: [
                topRow(questionWrappedUtils),
                const SizedBox(height: 24),
                pokemonImageWidget(thisPokemon),
                Expanded( // Game-panel section including questions and bottomBar
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: GameColors.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28)
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: getColorFromString(thisPokemon.name).withValues(alpha: 0.5),
                          blurRadius: 30,
                          spreadRadius: -10,
                          offset: const Offset(0, -10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          width: 48,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        getSubmissionBar(
                          thisPokemon.bst,
                          thisPokemon.name,
                          pokemonsMap!.values.toList(),
                        ),
                        if (!pokemonGuessedCorrectly)
                          Expanded(
                            child: listOfQuestionPills(questionWrappedUtils),
                          ),
                        if (pokemonGuessedCorrectly)
                          Expanded(
                            child: CatchingWidget(
                              steps: stepsCount,
                              pokemon: thisPokemon,
                              isShiny: isShiny,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
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
      } ,
      loading: () => HoveringImageLoadingScreen(
        image: arceusImage,
        text: "Lemme think",
      ),
    );
  }

  Widget topRow(QuestionWrappedUtils questionWrappedUtils) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16, right: 16, bottom: 8, top: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          stepsHudBadge(),
          if (!pokemonGuessedCorrectly)
          questionWrappedUtils.typesRow(),
        ],
      ),
    );
  }

  Widget stepsHudBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: GameColors.surfaceRaised,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GameColors.primary.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(color: GameColors.primary.withValues(alpha: 0.35), blurRadius: 12),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.directions_walk, size: 18, color: GameColors.primary),
          const SizedBox(width: 6),
          Text(
            "$stepsCount",
            style: const TextStyle(color: GameColors.textOnDark, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget pokemonImageWidget(PokemonEntity thisPokemon) {

    final questionMark = Image.asset(
      questionMarkIcon,
      fit: BoxFit.cover,
      height: 300,
      width: 300,
    );

    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
              child: SizedBox(
                height: 250,
                width: 250,
                child: AudioPlayerWidget(
                  audioLink: thisPokemon.cry,
                  child: TiltCard(
                    child: pokemonGuessedCorrectly
                    ? PokemonSpriteImage(
                        pokemonId: thisPokemon.id,
                        pokemonName: thisPokemon.name,
                        isShiny: isShiny,
                      )
                    : questionMark,
                  ),
                ),
              ),
            ),
      ),
    );
  }

  Widget listOfQuestionPills(QuestionWrappedUtils questionWrappedUtils) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                questionWrappedUtils.generationWidget(),
                questionWrappedUtils.evolutionTreeSizeWidget(),
                // There are issues with forms-variants with PokeAPI. Can't get the value I want.
                // questionWrappedUtils.noOfFormsWidget(),
                questionWrappedUtils.itemEvolutionWidget(),
                questionWrappedUtils.hasMegaWidget(),
                questionWrappedUtils.isMegaWidget(),
                questionWrappedUtils.hasGmaxWidget(),
                questionWrappedUtils.isGmaxWidget(),
                questionWrappedUtils.currentEvoStageWidget(),
                questionWrappedUtils.isBabyWidget(),
                questionWrappedUtils.isLegendaryWidget(),
                questionWrappedUtils.isMythiscalWidget(),
                questionWrappedUtils.isStarterWidget(),
                questionWrappedUtils.isPseudoWidget()
              ],
            ),
            const SizedBox(height: 10,)
          ],
        ),
      ),
    );
  }

  Widget getSubmissionBar(int pokemonBST, String pokemonName, List<String> pokemonsList) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Expanded( // Close button
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GameButton(
                color: pokemonGuessedCorrectly ? GameColors.surfaceRaised : GameColors.danger,
                borderRadius: 16,
                depth: 6,
                padding: const EdgeInsets.symmetric(vertical: 14),
                onPressed: () {
                  onPressedBack(pokemonBST, pokemonName);
                },
                child: Icon(
                  pokemonGuessedCorrectly
                  ? Icons.keyboard_return
                  : Icons.close,
                  color: GameColors.textOnDark,
                )
              ),
            ),
          ),
          if(!pokemonGuessedCorrectly)
          Expanded( // Submit button
            flex: pokemonGuessedCorrectly ? 1 : 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GameButton(
                color: getColorFromString(pokemonName),
                borderRadius: 16,
                depth: 6,
                padding: const EdgeInsets.symmetric(vertical: 14),
                onPressed: () {
                  showTextFieldWithOptionsBottomSheet(
                    context,
                    "Who's that Pokemon?",
                    pokemonName,
                    pokemonsList,
                    isAnswerCorrect: (answerValidity) {
                      setState(() {
                        ref.read(stepsCounterProvider.notifier).increment();
                        pokemonGuessedCorrectly = answerValidity;
                      });
                    }
                  );
                },
                child: const Text(
                  "SUBMIT",
                  style: TextStyle(color: GameColors.backgroundDeep, fontWeight: FontWeight.bold),
                )
              ),
            ),
          )
        ],
      ),
    );
  }

  // For the close button present on bottom bar
  void onPressedBack(int pokemonBST, String pokemonName) {
    if (!pokemonGuessedCorrectly)
    {
      final snackBar = SnackBar(
        content: Text("${isShiny ? "Shiny" : ''} $pokemonName ran away!"),
        duration: const Duration(seconds: 2),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      getIt<UserPokemonRepository>().recordInteraction(
        randomId,
        PokemonInteractionType.couldNotGuess
      );
      final steps = ref.read(stepsCounterProvider);
      getIt<UserProfileRepository>().addPoints(((pokemonBST / 100) * steps).toInt());
    }

    ref.read(caughtPokemonProvider.notifier).refresh();
    final newAchievements = ref.read(caughtPokemonProvider).newlyReceivedAchievements;

    if (newAchievements.isNotEmpty)
    {
      final snackBar = SnackBar(
        content: Row(
          children: [
            Text("You just received ${newAchievements.length==1 ? 'an' : 'some'} achievement${newAchievements.length==1 ? '' : 's'}!"),
          ],
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    Navigator.pop(context);
  }
}

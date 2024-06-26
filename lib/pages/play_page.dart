import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/consts/asset_paths.dart';
import 'package:guessthegyarados/database/user_pokemon_db.dart';
import 'package:guessthegyarados/database/user_data.dart';
import 'package:guessthegyarados/pokemon_class/pokemon.dart';
import 'package:guessthegyarados/provider/pokemon_names_provider.dart';
import 'package:guessthegyarados/provider/pokemon_provider.dart';
import 'package:guessthegyarados/provider/steps_provider.dart';
import 'package:guessthegyarados/provider/user_pokemon_db_provider.dart';
import 'package:guessthegyarados/utils/audio_player_widget.dart';
import 'package:guessthegyarados/utils/catching_widgets/catching_widget.dart';
import 'package:guessthegyarados/utils/get_image.dart';
import 'package:guessthegyarados/utils/screens/error_screen.dart';
import 'package:guessthegyarados/utils/screens/loading_screen.dart';
import 'package:guessthegyarados/utils/misc_methods.dart';
import 'package:guessthegyarados/utils/q_wrapper_and_widgets/bottom_sheet_methods.dart';
import 'package:guessthegyarados/utils/q_wrapper_and_widgets/question_wrapped_utils.dart';

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

  late int stepsCount = ref.read(counterProvider);
  late CounterNotifier stepsCountNotifier = ref.read(counterProvider.notifier); 

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
    final pokemonAsync = ref.watch(pokemonFutureProvider(133));
    final pokemonsMap = ref.watch(pokemonNamesProvider).value;
    stepsCount = ref.watch(counterProvider);

    return pokemonAsync.when(
      data: (thisPokemon) {

        if (thisPokemon == null) {
          return ErrorScreen(image: arceusImage);
        }
        debugPrint(thisPokemon.name + thisPokemon.bst.toString());

        final questionWrappedUtils = QuestionWrappedUtils(
          pokemon: thisPokemon, 
          context: context,
          color: getColorFromString(thisPokemon.name).withOpacity(0.7)
        );

        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).scaffoldBackgroundColor,
                  getColorFromString(thisPokemon.name)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter
              ),
            ),
            child: Column(
              children: [
                topRow(questionWrappedUtils),
                const SizedBox(height: 40),
                pokemonImageWidget(thisPokemon),
                Expanded( // White Section including questions and bottomBar
                  flex: 2,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25)
                      )
                    ),
                    child: Column(
                      children: [
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
          Text("  Steps: $stepsCount  "),
          if (!pokemonGuessedCorrectly)
          questionWrappedUtils.typesRow(),
        ],
      ),
    );
  }

  Widget pokemonImageWidget(Pokemon thisPokemon) {
   
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
                  child: pokemonGuessedCorrectly
                  ? FutureBuilder<Widget>(
                      future: getPokemonImage(
                        thisPokemon.id, 
                        isShiny: isShiny
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          debugPrint("[playPage] ${snapshot.error}");
                          return const Center(child: Text('[playPage] Failed to load image'));
                        } else {
                          return snapshot.data!;
                        }
                      },
                      
                  )
                  : questionMark,
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
              child: ElevatedButton(
                onPressed: () {
                  onPressedBack(pokemonBST, pokemonName);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: pokemonGuessedCorrectly
                  ? Theme.of(context).canvasColor
                  : Colors.red,
                ), 
                child: Icon(
                  pokemonGuessedCorrectly
                  ? Icons.keyboard_return
                  : Icons.close,
                )
              ),
            ),
          ),
          if(!pokemonGuessedCorrectly)
          Expanded( // Submit button
            flex: pokemonGuessedCorrectly ? 1 : 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showTextFieldWithOptionsBottomSheet(
                        context,
                        "Who's that Pokemon?", 
                        pokemonName, 
                        pokemonsList,
                        isAnswerCorrect: (answerValidity) {
                          setState(() {
                            stepsCountNotifier.increment();
                            pokemonGuessedCorrectly = answerValidity;
                          });
                        }
                      );
                    },
                    style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                      backgroundColor: MaterialStatePropertyAll(getColorFromString(pokemonName)),
                    ), 
                    child: const Text("Submit")
                  );
                }
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

      UserPokemonDB.updateData(
        randomId, 
        PokemonInteractionType.couldNotGuess
      );
      final steps = ref.read(counterProvider);
      UserDB.addPoints(((pokemonBST / 100) * steps).toInt());
    }

    ref.read(userPokemonProvider.notifier).updateData();
    final newAchievements = ref.read(userPokemonProvider).newlyReceivedAchievements;
    
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
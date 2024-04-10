import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/provider/pokemon_provider.dart';
import 'package:guessthegyarados/provider/provider.dart';
import 'package:guessthegyarados/theme/theme.dart';
import 'package:guessthegyarados/utils/audio_player_widget.dart';
import 'package:guessthegyarados/utils/catching_widget.dart';
import 'package:guessthegyarados/utils/get_image.dart';
import 'package:guessthegyarados/utils/input_utils.dart';
import 'package:guessthegyarados/utils/question_wrapped_utils.dart';

class PlayPage extends ConsumerStatefulWidget {
  const PlayPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlayPageState();
}

class _PlayPageState extends ConsumerState<PlayPage>{
  final randomId = Random().nextInt(1000) + 1;

  late int stepsCount = ref.read(counterProvider);
  late CounterNotifier stepsCountNotifier = ref.read(counterProvider.notifier); 

  bool pokemonGuessedCorrectly = false;

  @override
  Widget build(BuildContext context) {
    final pokemonAsync = ref.watch(pokemonFutureProvider(randomId));
    final pokemonsMap = ref.watch(pokemonNamesProvider).value;

    stepsCount = ref.watch(counterProvider);

    return pokemonAsync.when(
      data: (thisPokemon) {

        if (thisPokemon == null) {
          return const Scaffold(
            body: Center(child: Text('Failed to fetch Pokemon data'))
          );
        }

        final gyaradosSilhouette = Image.asset(
          "assets/mc_gyarados/gyarados_silhouette.png",
          fit: BoxFit.cover,
        );

        debugPrint(thisPokemon.name);

        final questionWrappedUtils = QuestionWrappedUtils(
          pokemon: thisPokemon, 
          context: context
        );

        return Scaffold(
          body: Column(
              children: [
                const SizedBox(height: 40,),
                Expanded(
                  flex: 2,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: SizedBox(
                          height: 200,
                          width: 200,
                          child: AudioPlayerWidget(
                            audioLink: thisPokemon.cry,
                            child: pokemonGuessedCorrectly
                            ? FutureBuilder<Widget>(
                                future: getPokemonImage(thisPokemon.id, thisPokemon.spriteUrl),
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
                            : gyaradosSilhouette,
                          ),
                        ),
                      ),
                      Positioned( 
                        top: 8,
                        right: 8,
                        child: questionWrappedUtils.typesRow(),
                      ),
                      Positioned( 
                        top: 8,
                        left: 16,
                        child: ElevatedButton(
                          onPressed: () {},
                          child: Text("Steps: $stepsCount")
                        ),
                      ),
                    ],
                  ),
                ),
                if (!pokemonGuessedCorrectly)
                  listOfQuestionPills(questionWrappedUtils),
                if (pokemonGuessedCorrectly)
                  CatchingWidget(steps: stepsCount, pokemon: thisPokemon)
              ],
            ),
            bottomNavigationBar: getBottomBar(
              thisPokemon.name,
              pokemonsMap!.values.toList()
            ),
        );
      },
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Error: $err')),
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget listOfQuestionPills(QuestionWrappedUtils questionWrappedUtils) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              questionWrappedUtils.generationWidget(),
              questionWrappedUtils.evolutionTreeSizeWidget(),
              questionWrappedUtils.noOfFormsWidget(),
              questionWrappedUtils.itemEvolutionWidget(),
              questionWrappedUtils.hasMegaWidget(),
              questionWrappedUtils.hasGmaxWidget(),
              questionWrappedUtils.currentEvoStageWidget(),
              questionWrappedUtils.isBabyWidget(),
              questionWrappedUtils.isLegendaryWidget(),
              questionWrappedUtils.isMythiscalWidget()
            ],
          ),
        ),
      )
    );
  }

  Widget getBottomBar(String pokemonName, List<String> pokemonsList) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  if (!pokemonGuessedCorrectly)
                  {
                    final snackBar = SnackBar(
                      content: Text("$pokemonName ran away!"),
                      duration: const Duration(seconds: 2),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }

                  Navigator.pop(context);
                }, 
                child: Icon(
                  pokemonGuessedCorrectly
                  ? Icons.keyboard_return
                  : Icons.close
                )
              ),
            ),
          ),
          Expanded(
            flex: 3,
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
                      backgroundColor: MaterialStateProperty.all<Color>(completionPill),
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

}
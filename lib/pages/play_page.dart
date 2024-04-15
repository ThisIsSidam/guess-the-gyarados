import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/consts/strings.dart';
import 'package:guessthegyarados/pokemon_class/pokemon.dart';
import 'package:guessthegyarados/provider/pokemon_names_provider.dart';
import 'package:guessthegyarados/provider/pokemon_provider.dart';
import 'package:guessthegyarados/provider/steps_provider.dart';
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
  bool isShiny = false;

  @override
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
    final pokemonAsync = ref.watch(pokemonFutureProvider(494));
    final pokemonsMap = ref.watch(pokemonNamesProvider).value;

    stepsCount = ref.watch(counterProvider);

    return pokemonAsync.when(
      data: (thisPokemon) {


        if (thisPokemon == null) {
          return const Scaffold(
            body: Center(child: Text('Failed to fetch Pokemon data'))
          );
        }

        debugPrint(thisPokemon.name);

        final questionWrappedUtils = QuestionWrappedUtils(
          pokemon: thisPokemon, 
          context: context
        );

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(bg1),
                fit: BoxFit.cover
              )
            ),
            child: Column(
                children: [
                  topRow(questionWrappedUtils),
                  const SizedBox(height: 40,),
                  pokemonImageWidget(thisPokemon),
                  if (!pokemonGuessedCorrectly)
                    Expanded(
                      flex: 2,
                      child: listOfQuestionPills(questionWrappedUtils)
                    ),
                  if (pokemonGuessedCorrectly)
                    Expanded(
                      flex: 2,
                      child: CatchingWidget(steps: stepsCount, pokemon: thisPokemon, isShiny: isShiny)
                    ),
                  getBottomBar(
                    thisPokemon.name,
                    pokemonsMap!.values.toList()
                  )
                ],
              ),
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

  Widget topRow(QuestionWrappedUtils questionWrappedUtils) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16, right: 16, bottom: 8, top: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
              onPressed: () {},
              child: Text("Steps: $stepsCount")
          ),
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
                        thisPokemon.name,
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
            questionWrappedUtils.isMythiscalWidget(),
            const SizedBox(height: 10, width: 200,)
          ],
        ),
      ),
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
                      content: Text("${isShiny ? "Shiny" : ''} $pokemonName ran away!"),
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
          if(!pokemonGuessedCorrectly)
          Expanded(
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
                      backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.secondary),
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
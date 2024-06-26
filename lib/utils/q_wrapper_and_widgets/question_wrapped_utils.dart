import 'package:flutter/material.dart';
import 'package:guessthegyarados/pokemon_class/pokemon.dart';
import 'package:guessthegyarados/utils/misc_methods.dart';
import 'package:guessthegyarados/utils/q_wrapper_and_widgets/question_wrapper.dart';

class QuestionWrappedUtils {

  final Pokemon pokemon;
  final BuildContext context;
  final Color color;

  QuestionWrappedUtils({
    required this.pokemon,
    required this.context,
    this.color = Colors.black12
  });

  Widget typesRow() {
    List<String> types = pokemon.types;

    String typeOne = types.first;
    String typeTwo = types.length > 1
      ? types.last
      : types.first;

    List<String> typeOptions = [
      "Fire", "Water", "Grass",
      "Rock", "Steel", "Ground",
      "Ghost", "Dark", "Psychic",
      "Fairy", "Dragon", "Ice",
      "Electric", "Bug", "Flying", 
      "Poison", "Normal", "Fighting", 
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        QuestionWrapper(
          question: "Primary type",
          answer: typeOne,
          aliasWidget: const Chip(
                label: Text(
                  "Type 1",
                ),
                backgroundColor: Colors.black12,
              ),
          options: typeOptions,
          coloredOptions: true,
          defaultColor: color,
          child: Chip(
            label: Text(
              typeOne.capitalize,
            ),
            backgroundColor: getColorFromString(typeOne),
          ),
        ),
        const SizedBox(width: 10,),
        QuestionWrapper(
          question: "Secondary type",
          answer: typeTwo,
          aliasWidget: const Chip(
                label: Text(
                  "Type 2",
                ),
                backgroundColor: Colors.black12,
              ),
          options: typeOptions,
          coloredOptions: true,
          defaultColor: color,
          child: Chip(
            label: Text(
              typeTwo.capitalize,
            ),
            backgroundColor: getColorFromString(typeTwo),
          )
        ),
      ],
    );
  }

  Widget generationWidget() {

    int generation = pokemon.generation;
    
    return QuestionWrapper(
      question: "Generation",
      answer: generation.toString(),
      options: List.generate(9, (index) => (index+1).toString()),
      defaultColor: color,
      child: Text(
        'Generation',
        style: Theme.of(context).textTheme.bodyLarge,
      )
    );
  }

  Widget noOfFormsWidget() {
    int noOfForms = pokemon.noOfForms;

    return QuestionWrapper(
      question: "Number of Forms",
      answer: noOfForms.toString(),
      options: List.generate(30, (index) => (index+1).toString()),
      defaultColor: color,
      child: Text(
        'Forms',
        style: Theme.of(context).textTheme.bodyLarge,
      )
    );
  }


  Widget evolutionTreeSizeWidget() {
    int evoTreeSize = pokemon.evolutionTreeSize;

    return QuestionWrapper(
      question: "Size of evolution tree", 
      answer: evoTreeSize.toString(),
      options: List.generate(10, (index) => (index+1).toString()),
      defaultColor: color, 
      child: Text(
        'Size of evolution tree',
        style: Theme.of(context).textTheme.bodyLarge,
      )
    );
  }

  Widget currentEvoStageWidget() {
    int currentEvoStage = pokemon.stageOfEvolution;

    return QuestionWrapper(
      question: "Current Evolution Stage", 
      answer: currentEvoStage.toString(),
      options: List.generate(3, (index) => (index+1).toString()),
      defaultColor: color, 
      child: Text(
        'Evolution Stage',
        style: Theme.of(context).textTheme.bodyLarge,
      )
    );
  }
  Widget itemEvolutionWidget() {
    String ans = pokemon.evolutionItem != null ? "Yes" : "No";

    return QuestionWrapper(
      question: "Has evolved using an item", 
      answer: ans, 
      answerIsBoolean: true,
      defaultColor: color,
      child: Text(
        "Has evolved using an item",
        style: Theme.of(context).textTheme.bodyLarge,
      )
    );
  }

  Widget hasMegaWidget() {
    String ans = pokemon.hasMega ? "Yes" : "No";

    return QuestionWrapper(
      question: "Has Mega Evolution", 
      answer: ans, 
      answerIsBoolean: true,
      defaultColor: color,
      child: Text(
        "Has Mega",
        style: Theme.of(context).textTheme.bodyLarge,
      )
    );
  }

  Widget isMegaWidget() {
    String ans = pokemon.isMega ? "Yes" : "No";

    return QuestionWrapper(
      question: "Is Mega Form", 
      answer: ans, 
      answerIsBoolean: true,
      defaultColor: color,
      child: Text(
        "Is Mega",
        style: Theme.of(context).textTheme.bodyLarge,
      )
    );
  }

  Widget hasGmaxWidget() {
    String ans = pokemon.hasGmax ? "Yes" : "No";

    return QuestionWrapper(
      question: "Has Gmax Form", 
      answer: ans, 
      answerIsBoolean: true,
      defaultColor: color,
      child: Text(
        "Has Gmax form",
        style: Theme.of(context).textTheme.bodyLarge,
      )
    );
  }

  Widget isGmaxWidget() {
    String ans = pokemon.isGmax ? "Yes" : "No";

    return QuestionWrapper(
      question: "Is Gmax Form", 
      answer: ans, 
      answerIsBoolean: true,
      defaultColor: color,
      child: Text(
        "Is Gmax form",
        style: Theme.of(context).textTheme.bodyLarge,
      )
    );
  }
  Widget isBabyWidget() {
    String ans = pokemon.isBaby ? "Yes" : "No";

    return QuestionWrapper(
      question: "Is Baby Pokemon", 
      answer: ans, 
      answerIsBoolean: true,
      defaultColor: color,
      child: Text(
        "Is Baby Pokemon",
        style: Theme.of(context).textTheme.bodyLarge,
      )
    );
  }
  Widget isLegendaryWidget() {
    String ans = pokemon.isLegendary ? "Yes" : "No";

    return QuestionWrapper(
      question: "Is a Legendary", 
      answer: ans, 
      answerIsBoolean: true,
      defaultColor: color,
      child: Text(
        "Is a Legendary",
        style: Theme.of(context).textTheme.bodyLarge,
      )
    );
  }
  Widget isMythiscalWidget() {
    String ans = pokemon.isMythical ? "Yes" : "No";

    return QuestionWrapper(
      question: "Is a Mythical", 
      answer: ans, 
      answerIsBoolean: true,
      defaultColor: color,
      child: Text(
        "Is a Mythical",
        style: Theme.of(context).textTheme.bodyLarge,
      )
    );
  }
  Widget isStarterWidget() {
    String ans = pokemon.isStarter ? "Yes" : "No";

    return QuestionWrapper(
      question: "Is a Starter", 
      answer: ans, 
      answerIsBoolean: true,
      defaultColor: color,
      child: Text(
        "Is a Starter",
        style: Theme.of(context).textTheme.bodyLarge,
      )
    );
  }
  Widget isPseudoWidget() {
    String ans = pokemon.isPseudo ? "Yes" : "No";

    return QuestionWrapper(
      question: "Is a Pseudo-Legendary", 
      answer: ans, 
      answerIsBoolean: true,
      defaultColor: color,
      child: Text(
        "Is a Pseudo-Legendary",
        style: Theme.of(context).textTheme.bodyLarge,
      )
    );
  }

}
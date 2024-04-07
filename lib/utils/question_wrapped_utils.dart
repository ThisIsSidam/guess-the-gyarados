import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guessthegyarados/pokemon_class/pokemon.dart';
import 'package:guessthegyarados/utils/question_wrapper.dart';
import 'package:guessthegyarados/utils/type_card.dart';

class QuestionWrappedUtils {

  final Pokemon pokemon;
  final BuildContext context;

  QuestionWrappedUtils({
    required this.pokemon,
    required this.context
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
      "Fairy", "Dragon", "Electric", 
      "Bug", "Flying", "Poison",
      "Normal", "Fighting", "Ice"
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        QuestionWrapper(
          question: "Primary type",
          answer: typeOne,
          aliasWidget: const TypeCard(type: "??",),
          options: typeOptions,
          child: TypeCard(type: typeOne),
        ),
        QuestionWrapper(
          question: "Secondary type",
          answer: typeTwo,
          aliasWidget: const TypeCard(type: "??",),
          options: typeOptions,
          child: TypeCard(type: typeTwo),
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
      child: Text(
        'Generation',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  Widget noOfFormsWidget() {
    int noOfForms = pokemon.noOfForms;

    return QuestionWrapper(
      question: "Number of Forms",
      answer: noOfForms.toString(),
      options: List.generate(10, (index) => (index+1).toString()),
      child: Text(
        'Forms',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }


  Widget evolutionTreeSizeWidget() {
    int evoTreeSize = pokemon.evolutionTreeSize;

    return QuestionWrapper(
      question: "Size of evolution tree", 
      answer: evoTreeSize.toString(),
      options: List.generate(10, (index) => (index+1).toString()), 
      child: Text(
        'Size of evolution tree',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  Widget currentEvoStageWidget() {
    int currentEvoStage = pokemon.stageOfEvolution;

    return QuestionWrapper(
      question: "Current Evolution Stage", 
      answer: currentEvoStage.toString(),
      options: List.generate(3, (index) => (index+1).toString()), 
      child: Text(
        'Evolution Stage',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
  Widget itemEvolutionWidget() {
    String ans = pokemon.evolutionItem != null ? "Yes" : "No";

    return QuestionWrapper(
      question: "Has evolved using an item", 
      answer: ans, 
      answerIsBoolean: true,
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
      child: Text(
        "Has Mega",
        style: Theme.of(context).textTheme.bodyLarge,
      )
    );
  }

  Widget hasGmaxWidget() {
    String ans = pokemon.hasMega ? "Yes" : "No";

    return QuestionWrapper(
      question: "Has Gmax Form", 
      answer: ans, 
      answerIsBoolean: true,
      child: Text(
        "Has Gmax form",
        style: Theme.of(context).textTheme.bodyLarge,
      )
    );
  }

}
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guessthegyarados/features/play/domain/models/clue_attempts.dart';
import 'package:guessthegyarados/features/play/domain/models/guess_feedback.dart';
import 'package:guessthegyarados/features/play/presentation/widgets/guess/guess_log_sheet.dart';
import 'package:guessthegyarados/features/play/presentation/widgets/question/inline_answer_panel.dart';
import 'package:guessthegyarados/shared/data/entities/pokemon_entity.dart';

PokemonEntity _mon(
  String name, {
  List<String> types = const ['water'],
  int gen = 1,
  int stage = 1,
  int bst = 400,
}) =>
    PokemonEntity(
      id: 1,
      name: name,
      generation: gen,
      bst: bst,
      noOfForms: 1,
      types: types,
      evolutionTreeSize: 1,
      stageOfEvolution: stage,
      cry: '',
      hasMega: false,
      hasGmax: false,
      isBaby: false,
      isLegendary: false,
      isMythical: false,
      isStarter: false,
      isPseudo: false,
      isMega: false,
      isGmax: false,
      speciesID: 1,
      variantIDs: const [],
    );

void main() {
  final answer =
      _mon('gyarados', types: ['water', 'flying'], gen: 1, stage: 2, bst: 540);

  test('numbers point towards the answer', () {
    final f = GuessFeedback.compare(
      guess: _mon('rattata', types: ['normal'], gen: 3, stage: 1, bst: 253),
      answer: answer,
    );
    expect(f.generation, Hit.lower); // answer's gen 1 is lower than 3
    expect(f.stage, Hit.higher);
    expect(f.bst, Hit.higher);
  });

  test('types: exact, other slot, none', () {
    // Same primary, no secondary: slot 1 matches, slot 2 misses.
    var f = GuessFeedback.compare(guess: _mon('magikarp'), answer: answer);
    expect(f.type1, Hit.exact);
    expect(f.type2, Hit.miss);

    // Types swapped: both are right but in the other slot.
    f = GuessFeedback.compare(
        guess: _mon('x', types: ['flying', 'water']), answer: answer);
    expect(f.type1, Hit.partial);
    expect(f.type2, Hit.partial);

    // A missing second type matches a missing second type.
    f = GuessFeedback.compare(
        guess: _mon('x', types: ['fire']), answer: _mon('y', types: ['fire']));
    expect(f.type1, Hit.exact);
    expect(f.type2, Hit.exact);
  });

  testWidgets('closeOnWrong closes the panel straight after a wrong pick',
      (tester) async {
    var closes = 0;
    final attempts = ClueAttempts(3);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: InlineAnswerPanel(
          question: 'Pick',
          options: const ['A', 'B'],
          attempts: attempts,
          closeOnWrong: true,
          onSelect: (v) => v == 'A',
          onClose: () => closes++,
        ),
      ),
    ));

    await tester.tap(find.text('B'));
    await tester.pump();
    expect(closes, 1);
  });

  testWidgets('the guess log lists guesses with their comparison',
      (tester) async {
    final entries = [
      GuessEntry(
          id: 129,
          name: 'magikarp',
          data: Future.value(_mon('magikarp', gen: 1, stage: 1, bst: 200))),
      GuessEntry(
          id: 1,
          name: 'broken',
          data: Future<PokemonEntity>.error(StateError('offline'))..ignore()),
    ];

    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => showGuessLogSheet(
              context: context,
              entries: entries,
              answer: answer,
              justMissed: true,
              onGuessAgain: () {},
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Not it!'), findsOneWidget);
    expect(find.text('3 guesses left'), findsOneWidget);
    expect(find.text('Magikarp'), findsOneWidget);
    expect(find.text("Couldn't look that one up."), findsOneWidget);
    expect(find.text('GUESS AGAIN'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_upward_rounded), findsWidgets);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guessthegyarados/features/play/domain/models/clue_attempts.dart';
import 'package:guessthegyarados/features/play/presentation/widgets/question/inline_answer_panel.dart';

void main() {
  const options = ['Alpha', 'Bravo', 'Charlie', 'Delta'];
  const answer = 'Charlie';

  Future<
      ({
        ClueAttempts attempts,
        List<String> picks,
        int Function() closes,
      })> pumpPanel(WidgetTester tester, {int maxAttempts = 2}) async {
    final attempts = ClueAttempts(maxAttempts);
    final picks = <String>[];
    var closes = 0;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: InlineAnswerPanel(
            question: 'Pick one',
            options: options,
            attempts: attempts,
            onSelect: (value) {
              picks.add(value);
              final correct = value == answer;
              if (!correct) attempts.recordWrong(value);
              return correct;
            },
            onClose: () => closes++,
          ),
        ),
      ),
    ));
    return (attempts: attempts, picks: picks, closes: () => closes);
  }

  testWidgets('a wrong pick spends a try and cannot be picked again', (tester) async {
    final panel = await pumpPanel(tester);
    expect(find.text('2 tries left'), findsOneWidget);

    await tester.tap(find.text('Bravo'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('1 try left'), findsOneWidget);

    await tester.tap(find.text('Bravo'), warnIfMissed: false);
    await tester.pump();
    expect(panel.picks, ['Bravo']);
    expect(panel.attempts.used, 1);
  });

  testWidgets('out of tries: everything is disabled but the panel stays usable', (tester) async {
    final panel = await pumpPanel(tester);

    await tester.tap(find.text('Alpha'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Bravo'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('No tries left'), findsOneWidget);

    // Even the right answer can't be picked any more.
    await tester.tap(find.text('Charlie'), warnIfMissed: false);
    await tester.pump(const Duration(seconds: 1));
    expect(panel.picks, ['Alpha', 'Bravo']);
    expect(panel.closes(), 0);

    // Wrong picks are marked (struck out + cross); merely locked ones are not.
    final alpha = tester.widget<Text>(find.text('Alpha'));
    final charlie = tester.widget<Text>(find.text('Charlie'));
    expect(alpha.style?.decoration, TextDecoration.lineThrough);
    expect(charlie.style?.decoration, isNull);
  });

  testWidgets('the right pick locks the rest and closes after a delay', (tester) async {
    final panel = await pumpPanel(tester);

    await tester.tap(find.text('Charlie'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(panel.closes(), 0);

    await tester.tap(find.text('Alpha'), warnIfMissed: false);
    await tester.pump();
    expect(panel.picks, ['Charlie']);

    await tester.pump(const Duration(milliseconds: 600));
    expect(panel.closes(), 1);
  });
}

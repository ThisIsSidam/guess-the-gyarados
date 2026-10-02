import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guessthegyarados/features/play/domain/models/hint.dart';
import 'package:guessthegyarados/features/play/presentation/widgets/hints/hint_sheet.dart';

void main() {
  test('first-letter mask keeps the shape of the name', () {
    expect(Hint.maskName('gyarados'), 'G _ _ _ _ _ _ _');
    expect(Hint.maskName('mr-mime'), 'M _ - _ _ _ _');
    expect(Hint.maskName('ho-oh'), 'H _ - _ _');
  });

  Future<List<Hint>> pump(WidgetTester tester, int coins) async {
    final bought = <Hint>[];
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => showHintSheet(
                context: context,
                coins: coins,
                bought: const {},
                onBuy: (hint) {
                  bought.add(hint);
                  return coins - hint.cost;
                },
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return bought;
  }

  testWidgets('a hint the player can afford is bought and closes the sheet',
      (tester) async {
    final bought = await pump(tester, 100);

    await tester.tap(find.text('First letter'));
    await tester.pumpAndSettle();

    expect(bought, [Hint.firstLetter]);
    expect(find.text('Hints'), findsNothing);
  });

  testWidgets('a hint that costs too much is refused and the sheet stays',
      (tester) async {
    final bought = await pump(tester, 30);

    await tester.tap(find.text('Silhouette'));
    await tester.pumpAndSettle();

    expect(bought, isEmpty);
    expect(find.text('Hints'), findsOneWidget);
  });
}

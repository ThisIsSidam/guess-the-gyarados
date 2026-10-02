import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guessthegyarados/shared/domain/achievements/achievement.dart';
import 'package:guessthegyarados/shared/domain/achievements/achievement_catalog.dart';
import 'package:guessthegyarados/shared/domain/models/region.dart';
import 'package:guessthegyarados/shared/presentation/widgets/achievement_grid.dart';

void main() {
  test('regions tile the national dex with no gaps or overlaps', () {
    expect(regions.first.firstId, 1);
    expect(regions.last.lastId, 1025);
    for (var i = 1; i < regions.length; i++) {
      expect(regions[i].firstId, regions[i - 1].lastId + 1);
    }
  });

  test('achievement ids are unique', () {
    final ids = achievementCatalog.map((a) => a.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('a region achievement counts only that region and caps at target', () {
    final johto10 = regionAchievements
        .whereType<RegionAchievement>()
        .firstWhere((a) => a.region.name == 'Johto' && a.target == 10);

    final kantoOnly = {for (var i = 1; i <= 40; i++) i};
    expect(johto10.progress(kantoOnly), 0);
    expect(johto10.isMet(kantoOnly), isFalse);

    final johtoSome = {for (var i = 152; i < 160; i++) i};
    expect(johto10.progress(johtoSome), 8);

    final johtoMany = {for (var i = 152; i < 200; i++) i};
    expect(johto10.progress(johtoMany), 10);
    expect(johto10.isMet(johtoMany), isTrue);
  });

  test('the master tier asks for the whole region', () {
    final kantoMaster = regionAchievements
        .whereType<RegionAchievement>()
        .firstWhere((a) => a.region.name == 'Kanto' && a.target == 151);
    expect(kantoMaster.description, 'Catch every Pokemon in Kanto');
    expect(kantoMaster.isMet({for (var i = 1; i <= 151; i++) i}), isTrue);
    expect(kantoMaster.isMet({for (var i = 1; i <= 150; i++) i}), isFalse);
  });

  for (final received in [false, true]) {
    testWidgets(
        'region tiles fit the achievements grid cell (received: $received)',
        (tester) async {
      final johto = regionAchievements.whereType<RegionAchievement>().toList();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 400,
              child: buildAchievementGrid(
                johto.take(4).toList(),
                isReceived: received,
                caughtIds: {for (var i = 1; i < 8; i++) i},
              ),
            ),
          ),
        ),
      ));
      expect(tester.takeException(), isNull);
    });
  }
}

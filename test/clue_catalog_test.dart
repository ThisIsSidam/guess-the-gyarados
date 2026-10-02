import 'package:flutter_test/flutter_test.dart';
import 'package:guessthegyarados/features/play/domain/models/clue.dart';
import 'package:guessthegyarados/shared/data/entities/pokemon_entity.dart';

PokemonEntity _mon({
  int bst = 540,
  int height = 65,
  int weight = 2350,
  String? color = 'blue',
  String? habitat = 'waters-edge',
}) =>
    PokemonEntity(
      id: 130,
      name: 'gyarados',
      generation: 1,
      bst: bst,
      noOfForms: 1,
      types: const ['water', 'flying'],
      evolutionTreeSize: 2,
      stageOfEvolution: 2,
      cry: '',
      hasMega: true,
      hasGmax: false,
      isBaby: false,
      isLegendary: false,
      isMythical: false,
      isStarter: false,
      isPseudo: false,
      isMega: false,
      isGmax: false,
      speciesID: 130,
      variantIDs: const [],
      height: height,
      weight: weight,
      color: color,
      habitat: habitat,
    );

void main() {
  test('brackets put boundary values in the upper bucket', () {
    expect(bstBracket(299), 'Under 300');
    expect(bstBracket(300), '300-399');
    expect(bstBracket(600), '600+');

    expect(heightBracket(4), 'Under 0.5 m'); // 0.4 m
    expect(heightBracket(5), '0.5-1 m'); // exactly 0.5 m
    expect(heightBracket(30), 'Over 3 m'); // exactly 3 m

    expect(weightBracket(49), 'Under 5 kg'); // 4.9 kg
    expect(weightBracket(50), '5-25 kg'); // exactly 5 kg
  });

  test('height and weight convert from decimetres and hectograms', () {
    // Gyarados: 6.5 m and 235 kg in PokeAPI's units.
    expect(heightBracket(65), 'Over 3 m');
    expect(weightBracket(2350), '100-300 kg');
    expect(heightBracket(17), '1-2 m'); // 1.7 m
  });

  test('habitat labels read naturally', () {
    expect(habitatLabel('waters-edge'), 'Waters edge');
    expect(habitatLabel('cave'), 'Cave');
    expect(habitatLabel(null), 'None');
  });

  test('every choice clue is answerable and ids are unique', () {
    for (final mon in [
      _mon(),
      _mon(bst: 190, height: 3, weight: 10, habitat: null, color: 'pink'),
      _mon(bst: 780, height: 200, weight: 9500, habitat: 'rough-terrain'),
    ]) {
      final catalog = buildClueCatalog(mon);
      final all = [...catalog.infoRow, ...catalog.cardGroups.expand((g) => g)];

      expect(all.map((c) => c.id).toSet().length, all.length);
      expect(catalog.cardTitles.length, catalog.cardGroups.length);

      for (final clue in all.where((c) => c.kind == ClueKind.choice)) {
        expect(
          clue.options!.map((o) => o.toLowerCase()),
          contains(clue.answer.toLowerCase()),
          reason: '${clue.id} answer "${clue.answer}" is not among its options',
        );
      }
    }
  });
}

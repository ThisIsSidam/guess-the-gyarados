import 'package:flutter_test/flutter_test.dart';
import 'package:guessthegyarados/features/play/domain/models/round_scoring.dart';
import 'package:guessthegyarados/shared/data/entities/pokemon_entity.dart';

PokemonEntity _pokemon({
  String name = 'eevee',
  int bst = 400,
  int stage = 1,
  bool legendary = false,
}) =>
    PokemonEntity(
      id: 1,
      name: name,
      generation: 1,
      bst: bst,
      noOfForms: 1,
      types: const ['normal'],
      evolutionTreeSize: 1,
      stageOfEvolution: stage,
      cry: '',
      hasMega: false,
      hasGmax: false,
      isBaby: false,
      isLegendary: legendary,
      isMythical: false,
      isStarter: false,
      isPseudo: false,
      isMega: false,
      isGmax: false,
      speciesID: 1,
      variantIDs: const [],
    );

void main() {
  test('meter drains 3% per step and stops at the floor', () {
    expect(RoundScoring.meter(0), 100);
    expect(RoundScoring.meter(10), 70);
    expect(RoundScoring.meter(100), RoundScoring.meterFloor);
  });

  test('catch chance applies hidden modifiers on top of the meter', () {
    expect(RoundScoring.catchChance(steps: 0, pokemon: _pokemon()), 100);
    expect(RoundScoring.catchChance(steps: 0, pokemon: _pokemon(stage: 2)), 95);
    expect(RoundScoring.catchChance(steps: 0, pokemon: _pokemon(stage: 3)), 90);
    expect(
        RoundScoring.catchChance(steps: 0, pokemon: _pokemon(legendary: true)),
        50);
    expect(
        RoundScoring.catchChance(steps: 0, pokemon: _pokemon(name: 'Arceus')),
        1);
  });

  test('catch points shrink with steps, shiny doubles, misses pay half', () {
    final mon = _pokemon();
    expect(RoundScoring.catchPoints(steps: 0, pokemon: mon, isShiny: false), 400);
    expect(RoundScoring.catchPoints(steps: 0, pokemon: mon, isShiny: true), 800);
    final late = RoundScoring.catchPoints(steps: 30, pokemon: mon, isShiny: false);
    expect(late, lessThan(400));
    expect(RoundScoring.missPoints(steps: 0, pokemon: mon), 200);
  });

  test('forfeit pays a small amount that falls as steps rise', () {
    final mon = _pokemon();
    final fresh = RoundScoring.forfeitPoints(steps: 0, pokemon: mon);
    final spammed = RoundScoring.forfeitPoints(steps: 40, pokemon: mon);
    expect(fresh, 40);
    expect(spammed, lessThan(fresh));
    expect(spammed, greaterThanOrEqualTo(1));
  });
}

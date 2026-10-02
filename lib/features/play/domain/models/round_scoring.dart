import 'dart:math';

import 'package:guessthegyarados/shared/data/entities/pokemon_entity.dart';

/// All of a round's odds and payouts in one place. Every step (clue tap, right
/// or wrong pick, name guess) drains the [meter]; the meter is both what the
/// HUD shows and what scales the points a catch is worth, so using clues has a
/// visible, real cost.
class RoundScoring {
  const RoundScoring._();

  /// The daily challenge pays half as much again as a regular round.
  static const dailyDifficulty = 1.5;

  /// Catch chance lost per step.
  static const stepCost = 3.0;

  /// The meter never drops below this, so a long round is still catchable.
  static const meterFloor = 10.0;

  /// The chance (0-100) shown on the HUD after [steps] steps. Deliberately
  /// leaves out the Pokemon's own modifiers ([catchChance]) — showing those
  /// would give away whether it is legendary or fully evolved.
  static double meter(int steps) =>
      max(meterFloor, 100 - steps * stepCost);

  /// The real chance (0-100) the ball holds: the meter, made harder for
  /// legendaries and late evolutions. Arceus almost never stays in.
  static double catchChance({
    required int steps,
    required PokemonEntity pokemon,
  }) {
    if (pokemon.name.toLowerCase() == 'arceus') return 1;

    var chance = meter(steps);
    if (pokemon.isLegendary || pokemon.isMythical) chance /= 2;
    switch (pokemon.stageOfEvolution) {
      case 2:
        chance -= 5;
      case 3:
        chance -= 10;
    }
    return chance.clamp(1.0, 100.0);
  }

  // A catch is worth 40% of the base-stat total at the meter's floor and all
  // of it at a perfect 100%.
  static double _meterScale(int steps) => 0.4 + 0.6 * meter(steps) / 100;

  static int catchPoints({
    required int steps,
    required PokemonEntity pokemon,
    required bool isShiny,
    double difficulty = 1,
  }) =>
      (pokemon.bst * _meterScale(steps) * (isShiny ? 2 : 1) * difficulty)
          .round();

  /// It was guessed but broke free: half of what the catch would have paid.
  static int missPoints({
    required int steps,
    required PokemonEntity pokemon,
    double difficulty = 1,
  }) =>
      (pokemon.bst * _meterScale(steps) * 0.5 * difficulty).round();

  /// A consolation for letting it go: small, and shrinking the more steps
  /// were spent (it used to grow, which rewarded spamming clues).
  static int forfeitPoints({
    required int steps,
    required PokemonEntity pokemon,
    double difficulty = 1,
  }) =>
      max(1, (pokemon.bst * 0.1 * meter(steps) / 100 * difficulty).round());

  /// Extra for a round with no wrong picks at all: thinking over guessing.
  static int perfectBonus(int basePoints) => (basePoints * 0.25).round();

  /// Each catch in a row adds 20% to the next one's points, up to double.
  /// [streakBefore] is the number of catches in a row going into the round.
  static double streakMultiplier(int streakBefore) =>
      min(2.0, 1 + 0.2 * streakBefore);

  /// Coins are a tenth of the round's points.
  static int coinsFor(int totalPoints) => (totalPoints * 0.1).round();
}

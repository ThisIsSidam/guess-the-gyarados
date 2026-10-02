import 'dart:math';

import 'package:guessthegyarados/core/di/injection.dart';
import 'package:guessthegyarados/features/play/domain/models/round_outcome.dart';
import 'package:guessthegyarados/features/play/domain/models/round_scoring.dart';
import 'package:guessthegyarados/features/profile/data/repositories/user_profile_repository.dart';
import 'package:guessthegyarados/shared/data/entities/pokemon_entity.dart';
import 'package:guessthegyarados/shared/data/entities/pokemon_interaction_entity.dart';
import 'package:guessthegyarados/shared/data/repositories/user_pokemon_repository.dart';

/// Rolls and records the end of a round: the catch roll, the interaction
/// history, the streak, and the points and coins. Runs the moment the
/// end-of-round animation starts, so leaving mid-animation can't lose the
/// result.
class RoundSettler {
  const RoundSettler._();

  /// The Pokemon was guessed; rolls whether the ball holds.
  static RoundOutcome settleGuess({
    required PokemonEntity pokemon,
    required bool isShiny,
    required int steps,
    required int wrongPicks,
    required double difficulty,
  }) {
    final pokemonRepo = getIt<UserPokemonRepository>();
    final profileRepo = getIt<UserProfileRepository>();

    final streakBefore = profileRepo.getProfile().catchStreak;
    final chance = RoundScoring.catchChance(steps: steps, pokemon: pokemon);
    final caught = Random().nextDouble() * 100 < chance;

    if (!caught) {
      pokemonRepo.recordInteraction(
          pokemon.id, PokemonInteractionType.catchFailed);
      profileRepo.recordStreak(caught: false);
      final base = RoundScoring.missPoints(
          steps: steps, pokemon: pokemon, difficulty: difficulty);
      final coins = RoundScoring.coinsFor(base);
      profileRepo.addCoins(coins);
      final award = profileRepo.addPoints(base);
      return RoundOutcome(
        caught: false,
        basePoints: base,
        perfectBonus: 0,
        streakLost: streakBefore > 0,
        coins: coins,
        isNewCatch: false,
        levelBefore: award.levelBefore,
        levelAfter: award.levelAfter,
      );
    }

    final isNew = !pokemonRepo.getCaughtPokemonIds().contains(pokemon.id);
    pokemonRepo.recordInteraction(
      pokemon.id,
      isShiny
          ? PokemonInteractionType.caughtShiny
          : PokemonInteractionType.caughtNormal,
    );
    profileRepo.recordFirstCatch(pokemon.id, pokemon.types.first);
    final streak = profileRepo.recordStreak(caught: true);

    final base = RoundScoring.catchPoints(
        steps: steps,
        pokemon: pokemon,
        isShiny: isShiny,
        difficulty: difficulty);
    final perfect = wrongPicks == 0 ? RoundScoring.perfectBonus(base) : 0;
    final multiplier = RoundScoring.streakMultiplier(streakBefore);
    final streakBonus = ((base + perfect) * (multiplier - 1)).round();
    final total = base + perfect + streakBonus;
    final coins = max(1, RoundScoring.coinsFor(total));

    profileRepo.addCoins(coins);
    final award = profileRepo.addPoints(total);
    return RoundOutcome(
      caught: true,
      basePoints: base,
      perfectBonus: perfect,
      streakBonus: streakBonus,
      streak: streak,
      multiplier: multiplier,
      coins: coins,
      isNewCatch: isNew,
      levelBefore: award.levelBefore,
      levelAfter: award.levelAfter,
    );
  }

  /// The player let the Pokemon go.
  static RoundOutcome settleForfeit({
    required PokemonEntity pokemon,
    required int steps,
    required double difficulty,
  }) {
    final profileRepo = getIt<UserProfileRepository>();
    getIt<UserPokemonRepository>()
        .recordInteraction(pokemon.id, PokemonInteractionType.couldNotGuess);

    final streakBefore = profileRepo.getProfile().catchStreak;
    profileRepo.recordStreak(caught: false);

    final base = RoundScoring.forfeitPoints(
        steps: steps, pokemon: pokemon, difficulty: difficulty);
    final coins = RoundScoring.coinsFor(base);
    profileRepo.addCoins(coins);
    final award = profileRepo.addPoints(base);
    return RoundOutcome(
      caught: false,
      basePoints: base,
      perfectBonus: 0,
      streakLost: streakBefore > 0,
      coins: coins,
      isNewCatch: false,
      levelBefore: award.levelBefore,
      levelAfter: award.levelAfter,
    );
  }

  /// Records a finished daily challenge on top of its normal [outcome]:
  /// solving it extends the daily streak, which pays a few extra coins.
  static RoundOutcome settleDaily(
    RoundOutcome outcome, {
    required int epochDay,
    required bool solved,
    required String trail,
    required int steps,
  }) {
    final profileRepo = getIt<UserProfileRepository>();
    final streak = profileRepo.recordDaily(
      epochDay: epochDay,
      solved: solved,
      caught: outcome.caught,
      steps: steps,
      trail: trail,
    );
    final bonus = solved ? min(50, streak * 10) : 0;
    profileRepo.addCoins(bonus);
    return outcome.withDaily(streak: streak, bonusCoins: bonus);
  }
}

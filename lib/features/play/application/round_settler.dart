import 'dart:math';

import 'package:guessthegyarados/core/di/injection.dart';
import 'package:guessthegyarados/features/play/domain/models/round_outcome.dart';
import 'package:guessthegyarados/features/play/domain/models/round_scoring.dart';
import 'package:guessthegyarados/features/profile/data/repositories/user_profile_repository.dart';
import 'package:guessthegyarados/shared/data/entities/pokemon_entity.dart';
import 'package:guessthegyarados/shared/data/entities/pokemon_interaction_entity.dart';
import 'package:guessthegyarados/shared/data/repositories/user_pokemon_repository.dart';

/// Rolls and records the end of a round: the catch roll, the interaction
/// history and the points. Runs the moment the end-of-round animation starts,
/// so leaving mid-animation can't lose the result.
class RoundSettler {
  const RoundSettler._();

  /// The Pokemon was guessed; rolls whether the ball holds.
  static RoundOutcome settleGuess({
    required PokemonEntity pokemon,
    required bool isShiny,
    required int steps,
    required int wrongPicks,
  }) {
    final pokemonRepo = getIt<UserPokemonRepository>();
    final profileRepo = getIt<UserProfileRepository>();

    final chance = RoundScoring.catchChance(steps: steps, pokemon: pokemon);
    final caught = Random().nextDouble() * 100 < chance;

    if (!caught) {
      pokemonRepo.recordInteraction(
          pokemon.id, PokemonInteractionType.catchFailed);
      final base = RoundScoring.missPoints(steps: steps, pokemon: pokemon);
      final award = profileRepo.addPoints(base);
      return RoundOutcome(
        caught: false,
        basePoints: base,
        perfectBonus: 0,
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

    final base = RoundScoring.catchPoints(
        steps: steps, pokemon: pokemon, isShiny: isShiny);
    final bonus = wrongPicks == 0 ? RoundScoring.perfectBonus(base) : 0;
    final award = profileRepo.addPoints(base + bonus);
    return RoundOutcome(
      caught: true,
      basePoints: base,
      perfectBonus: bonus,
      isNewCatch: isNew,
      levelBefore: award.levelBefore,
      levelAfter: award.levelAfter,
    );
  }

  /// The player let the Pokemon go.
  static RoundOutcome settleForfeit({
    required PokemonEntity pokemon,
    required int steps,
  }) {
    getIt<UserPokemonRepository>()
        .recordInteraction(pokemon.id, PokemonInteractionType.couldNotGuess);
    final base = RoundScoring.forfeitPoints(steps: steps, pokemon: pokemon);
    final award = getIt<UserProfileRepository>().addPoints(base);
    return RoundOutcome(
      caught: false,
      basePoints: base,
      perfectBonus: 0,
      isNewCatch: false,
      levelBefore: award.levelBefore,
      levelAfter: award.levelAfter,
    );
  }
}

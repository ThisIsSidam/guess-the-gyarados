import 'package:guessthegyarados/core/di/injection.dart';
import 'package:guessthegyarados/data/repositories/achievement_repository.dart';
import 'package:guessthegyarados/data/repositories/user_pokemon_repository.dart';
import 'package:guessthegyarados/data/repositories/user_profile_repository.dart';
import 'package:guessthegyarados/domain/achievements/achievement.dart';
import 'package:guessthegyarados/domain/achievements/achievement_catalog.dart';
import 'package:guessthegyarados/domain/models/user_pokemon_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/caught_pokemon_provider.g.dart';

@riverpod
class CaughtPokemon extends _$CaughtPokemon {
  @override
  UserPokemonState build() => _computeState();

  /// Recomputes state from the repositories. Called after a game round ends
  /// (catch/miss) so the caught-ids/achievements state picks up the change.
  void refresh() => state = _computeState();

  UserPokemonState _computeState() {
    final userPokemonRepository = getIt<UserPokemonRepository>();
    final achievementRepository = getIt<AchievementRepository>();
    final userProfileRepository = getIt<UserProfileRepository>();

    final caughtPokemonIds = userPokemonRepository.getCaughtPokemonIds();
    final receivedAchievementIds = achievementRepository.getReceivedIds();

    final received = <Achievement>[];
    final upcoming = <Achievement>[];
    final newlyReceived = <Achievement>[];

    for (final achievement in achievementCatalog) {
      if (receivedAchievementIds.contains(achievement.id)) {
        received.add(achievement);
        continue;
      }

      if (achievement is ExistenceAchievement) {
        if (achievement.pokemonIds.every(caughtPokemonIds.contains)) {
          received.add(achievement);
          newlyReceived.add(achievement);
          userProfileRepository.addPoints(achievement.points);
        } else {
          upcoming.add(achievement);
        }
      } else if (achievement is MethodAchievement) {
        if (achievement.achievementMethod(userPokemonRepository)) {
          received.add(achievement);
          newlyReceived.add(achievement);
        } else {
          upcoming.add(achievement);
        }
      }
    }

    for (final achievement in newlyReceived) {
      achievementRepository.markReceived(achievement.id);
    }

    return UserPokemonState(
      caughtPokemonIds: caughtPokemonIds,
      receivedAchievements: received,
      upcomingAchievements: upcoming,
      newlyReceivedAchievements: newlyReceived,
    );
  }
}

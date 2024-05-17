import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/database/achievements_db.dart';
import 'package:guessthegyarados/database/user_pokemon_db.dart';
import 'package:guessthegyarados/database/user_data.dart';
import 'package:guessthegyarados/utils/achivement_utils/achievement_classes.dart';
import 'package:guessthegyarados/utils/achivement_utils/achievements.dart';

final userPokemonProvider = StateNotifierProvider<CaughtPokemonNotifier, UserPokemonState>((ref) {
  return CaughtPokemonNotifier();
});

class UserPokemonState {
  final Map<int, Map<String, int>> caughtDetails;
  final List<Achievement> receivedAchievements;
  final List<Achievement> upcomingAchievements;
  final List<Achievement> newlyReceivedAchievements;

  UserPokemonState({
    required this.caughtDetails,
    required this.receivedAchievements,
    required this.upcomingAchievements,
    required this.newlyReceivedAchievements,
  });
}

class CaughtPokemonNotifier extends StateNotifier<UserPokemonState> {
  CaughtPokemonNotifier() : super(_getCaughtPokemonState());

  static UserPokemonState _getCaughtPokemonState() {

    final caughtDetails = UserPokemonDB.getData;

    final achievementDetails = _getAchievements(caughtDetails);
    return UserPokemonState(
      caughtDetails: caughtDetails,
      receivedAchievements: achievementDetails['received'] ?? [],
      upcomingAchievements: achievementDetails['upcoming'] ?? [],
      newlyReceivedAchievements: achievementDetails['newly'] ?? []
    );
  }

  void updateData() {
    state = _getCaughtPokemonState();
  }

  static Map<String, List<Achievement>> _getAchievements(Map<int, Map<String, int>> caughtDetails) {
    final caughtPokemonIds = UserPokemonDB.getCaughtPokemonIDs();
    final List<Achievement> receivedAchievements = [];
    final List<Achievement> upcomingAchievements = [];
    final List<Achievement> newlyReceivedAchievements = [];
    final Set<int> receivedAchievementIDs = AchievementDB.getList;

    for(final achievement in achievements)
    {
      if (receivedAchievementIDs.contains(achievement.id))
      {
        receivedAchievements.add(achievement);
        continue;
      }

      if (achievement is ExistenceAchievement)
      {
        if (achievement.pokemonIds.every((element) => caughtPokemonIds.contains(element)))
        {
          receivedAchievements.add(achievement);
          newlyReceivedAchievements.add(achievement);
          UserDB.addPoints(achievement.points);
        }
        else 
        {
          upcomingAchievements.add(achievement);
        }
      }
      else if (achievement is MethodAchievement) 
      {
        if (achievement.achievementMethod(caughtDetails))
        {
          receivedAchievements.add(achievement);
          newlyReceivedAchievements.add(achievement);
        }
        else 
        {
          upcomingAchievements.add(achievement);
        }
      }
      else 
      {
        throw "[AchPage-B] Unknown Achievement";
      }

    }
    for (final achievement in newlyReceivedAchievements) 
    {
      AchievementDB.update(achievement.id);
    }

    return {
      "received" : receivedAchievements,
      "upcoming" : upcomingAchievements,
      "newly" : newlyReceivedAchievements
    };
  }
}
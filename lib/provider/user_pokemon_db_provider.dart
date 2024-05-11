import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/database/achievements_db.dart';
import 'package:guessthegyarados/database/pokemon_db.dart';
import 'package:guessthegyarados/utils/achivement_utils/achievement_classes.dart';
import 'package:guessthegyarados/utils/achivement_utils/achievements.dart';

final caughtPokemonProvider = StateNotifierProvider<CaughtPokemonNotifier, CaughtPokemonState>((ref) {
  return CaughtPokemonNotifier();
});

class CaughtPokemonState {
  final Map<int, Map<String, int>> caughtDetails;
  final List<Achievement> receivedAchievements;
  final List<Achievement> upcomingAchievements;
  final List<Achievement> newlyReceivedAchievements;

  CaughtPokemonState({
    required this.caughtDetails,
    required this.receivedAchievements,
    required this.upcomingAchievements,
    required this.newlyReceivedAchievements,
  });
}

class CaughtPokemonNotifier extends StateNotifier<CaughtPokemonState> {
  CaughtPokemonNotifier() : super(_getCaughtPokemonState());

  static CaughtPokemonState _getCaughtPokemonState() {

    final caughtDetails = CaughtPokemonDB.getData;

    final achievementDetails = _getAchievements(caughtDetails);
    return CaughtPokemonState(
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
    final caughtPokemonIds = CaughtPokemonDB.getCaughtPokemonIDs();
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
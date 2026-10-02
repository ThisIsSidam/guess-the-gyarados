import 'package:guessthegyarados/shared/data/repositories/user_pokemon_repository.dart';
import 'package:guessthegyarados/shared/domain/models/region.dart';

abstract class Achievement {
  const Achievement({
    required this.id,
    required this.name,
    required this.points,
    required this.badgeImageID,
  });

  final int id;
  final String name;
  final int points;
  final int badgeImageID;
}

class ExistenceAchievement extends Achievement {
  const ExistenceAchievement({
    required super.id,
    required super.name,
    required super.points,
    required super.badgeImageID,
    required this.pokemonIds,
  });

  final List<int> pokemonIds;
}

class MethodAchievement extends Achievement {
  const MethodAchievement({
    required super.id,
    required super.name,
    required super.points,
    required super.badgeImageID,
    required this.achievementMethod,
  });

  final bool Function(UserPokemonRepository) achievementMethod;
}

/// "Catch [target] Pokemon from [region]". Shows progress while locked.
/// [badgeImageID] is unused (0): these badges show the region, not a Pokemon.
class RegionAchievement extends Achievement {
  const RegionAchievement({
    required super.id,
    required super.name,
    required super.points,
    required this.region,
    required this.target,
  }) : super(badgeImageID: 0);

  final Region region;
  final int target;

  int progress(Set<int> caughtIds) =>
      region.countCaught(caughtIds).clamp(0, target);

  bool isMet(Set<int> caughtIds) => progress(caughtIds) >= target;

  String get description => target >= region.size
      ? 'Catch every Pokemon in ${region.name}'
      : 'Catch $target in ${region.name}';
}

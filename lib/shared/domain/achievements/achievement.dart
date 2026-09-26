import 'package:guessthegyarados/shared/data/repositories/user_pokemon_repository.dart';

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

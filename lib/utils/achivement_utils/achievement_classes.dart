import 'package:flutter/material.dart';
import 'package:guessthegyarados/consts/asset_paths.dart';
import 'package:guessthegyarados/database/achievements_db.dart';
import 'package:guessthegyarados/database/pokemon_data_db.dart';
import 'package:guessthegyarados/database/user_data.dart';
import 'package:guessthegyarados/utils/get_image.dart';
import 'package:guessthegyarados/utils/misc_methods.dart';

abstract class Achievement {
  final int id;
  final String name;
  final int points;
  final int badgeImageID;

  Achievement({
    required this.id,
    required this.name,
    required this.points,
    required this.badgeImageID,
  });

  Widget get achievementBadge {
    final receivedAchievements = AchievementDB.getList;
    if (!receivedAchievements.contains(id))
    {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(15)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Image(
              image: AssetImage(pokeballIcon),
              color: Colors.grey,
            ),
          const SizedBox(height: 8.0),
          Text(
            name,
            textAlign: TextAlign.center,
          ),
          ],
        ),
      );
    }

    final pokemon = PokemonDB.getData(badgeImageID);
    if (pokemon == null) throw "[AchievementBadge] Error Getting Pokemon Data";
    final color1 = getColorFromString(pokemon.types.first);
    final type2 = pokemon.types.length > 1 ? pokemon.types[1] : null;
    final color2 = getColorFromString(
      type2 ?? UserDB.getData(UserDetails.userColorString)!
    );

    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [color1, color2, Colors.black12],
          radius: 2,
          center: Alignment.topLeft
        ),
        borderRadius: BorderRadius.circular(15)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: FutureBuilder(
              future: getPokemonImage(badgeImageID),
              initialData: const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                ),
              ),
              builder: (context, snapshot) => snapshot.data!
            ),
          ),
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),
        ],
      ),
    );
  }
}

class ExistenceAchievement extends Achievement {
  final List<int> pokemonIds;

  ExistenceAchievement({
    required super.id,
    required super.name,
    required super.points,
    required super.badgeImageID,
    required this.pokemonIds,
  });
}

class MethodAchievement extends Achievement {
  final bool Function(Map<int, Map<String, int>>) achievementMethod;

  MethodAchievement({
    required super.id,
    required super.name,
    required super.points,
    required super.badgeImageID,
    required this.achievementMethod,
  });
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/consts/strings.dart';
import 'package:guessthegyarados/database/pokemon_db.dart';
import 'package:guessthegyarados/provider/user_pokemon_db_provider.dart';
import 'package:guessthegyarados/utils/achivement_utils/methods.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemonData = CaughtPokemonDB.getData;
    final receivedAchievements =
        ref.read(caughtPokemonProvider).receivedAchievements;

    int totalGuesses = 0;
    int totalAppeared = 0;
    int totalCaught = 0;
    int totalCaughtShiny = 0;
    int totalSpeciesCaught = 0;

    for (var pokemonEntry in pokemonData.values) {
      final catchFailed = pokemonEntry['catchFailed'] ?? 0;
      final caughtNormal = pokemonEntry['caughtNormal'] ?? 0;
      final caughtShiny = pokemonEntry['caughtShiny'] ?? 0;
      final couldNotGuess = pokemonEntry['couldNotGuess'] ?? 0;

      totalCaught += caughtNormal + caughtShiny;
      totalGuesses += catchFailed + caughtNormal + caughtShiny;
      totalAppeared += couldNotGuess + catchFailed + caughtNormal + caughtShiny;
      totalCaughtShiny += caughtShiny;
      if (pokemonEntry['caughtNormal']! > 0 || pokemonEntry['caughtShiny']! > 0) {
        totalSpeciesCaught++;
      }
    }

    double guessRate = totalGuesses > 0 ? (totalGuesses / totalAppeared) * 100 : 0.0;
    double catchRate = totalCaught > 0 ? (totalCaught / totalGuesses) * 100 : 0.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.red,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _userNameWidget(context, catchRate, guessRate),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: _statTile('${catchRate.toStringAsFixed(0)}%', "Catch Rate", context)),
                  const SizedBox(width: 20,),
                  Expanded(child: _statTile('${guessRate.toStringAsFixed(0)}%', "Guess Rate", context))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: _statTile('$totalCaught', 'Pokemon Caught', context)),
                  const SizedBox(width: 10,),
                  Expanded(child: _statTile('$totalSpeciesCaught', 'Species Caught', context)),
                  const SizedBox(width: 10,),
                  Expanded(child: _statTile('$totalCaughtShiny', 'Shinies Caught', context)),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Received Achievements',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    receivedAchievements.isNotEmpty
                        ? buildAchievementGrid(receivedAchievements)
                        : const Center(
                            child: Text("Kid, you ain't got no achievements. Play more."),
                          )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userNameWidget(BuildContext context, double catchRate, double guessRate) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            pokeballIcon,
            width: 40.0,
            height: 40.0,
          ),
          const SizedBox(width: 20,),
          Text(
            'missingUser',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.white
            ),
          ),
          const SizedBox(width: 8.0),
          IconButton(
            icon: const Icon(Icons.edit),
            color: Colors.white,
            onPressed: () {
              // Implement edit functionality
            },
          ),
        ],
      ),
    );
  }

  Widget _statTile(String value, String label, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.white,
            ),
          ),
          Text(
            label,
            softWrap: false,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Colors.white,
              fontSize: 8
            ),
          ),
        ],
      ),
    );
  }
}
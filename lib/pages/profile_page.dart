import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/consts/strings.dart';
import 'package:guessthegyarados/database/pokemon_db.dart';
import 'package:guessthegyarados/database/user_data.dart';
import 'package:guessthegyarados/pages/achievements_page.dart';
import 'package:guessthegyarados/provider/user_pokemon_db_provider.dart';
import 'package:guessthegyarados/utils/achivement_utils/achievement_classes.dart';
import 'package:guessthegyarados/utils/achivement_utils/methods.dart';

class ProfilePage extends ConsumerStatefulWidget {

  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final userNameController = TextEditingController();
  bool isEditingUsername = false;

  @override
  void initState() {
    super.initState();
    userNameController.text = UserDB.getData(UserDetails.username) ?? 'missingUser';
  }

  @override
  Widget build(BuildContext context) {
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
      resizeToAvoidBottomInset: false,
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
            _userNameWidget(context),
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
              child: _achievementsSection(receivedAchievements),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userNameWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            "Hello,",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.white
            ),
          ),
          const SizedBox(width: 10,),
          isEditingUsername
          ? SizedBox(
              width: 200,
              child: TextField(
                controller: userNameController,
                autofocus: true,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Colors.white
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8.0,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onSubmitted: (value) {
                  UserDB.addData(
                    UserDetails.username,
                    value,
                  );

                  setState(() {
                    isEditingUsername = false;
                  });
                },
              ),
            )
          : Text(
              userNameController.text,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Colors.white
              ),
            ),
          const SizedBox(width: 8.0),
          IconButton(
            icon: const Icon(Icons.edit),
            iconSize: 20,
            color: Colors.white,
            onPressed: () {
              setState(() {
                isEditingUsername = true;
              });
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

  Widget _achievementsSection(List<Achievement> receivedAchievements) {
    return Container(
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Achievements',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const AchievementPage()));
                  }, 
                  icon: const Icon(Icons.chevron_right)
                )
              ],
            ),
          ),
          receivedAchievements.isNotEmpty
              ? buildAchievementGrid(receivedAchievements)
              : const Center(
                  child: Text("Kid, you ain't got no achievements. Play more."),
                )
        ],
      ),
    );
  }
}
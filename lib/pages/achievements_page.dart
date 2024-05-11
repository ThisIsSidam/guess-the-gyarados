import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/consts/strings.dart';
import 'package:guessthegyarados/database/achievements_db.dart';
import 'package:guessthegyarados/provider/user_pokemon_db_provider.dart';
import 'package:guessthegyarados/utils/achivement_utils/achievement_classes.dart';

class AchievementPage extends ConsumerStatefulWidget {
  const AchievementPage({super.key});

  @override
  ConsumerState<AchievementPage> createState() => _AchievementPageState();
}

class _AchievementPageState extends ConsumerState<AchievementPage> {

  @override
  Widget build(BuildContext context) {
    final receivedAchievements = ref.read(caughtPokemonProvider).receivedAchievements;
    final upcomingAchievements = ref.read(caughtPokemonProvider).upcomingAchievements;
    

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: const Text('Achievements'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (receivedAchievements.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Received Achievements',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              buildAchievementGrid(receivedAchievements),
              if (upcomingAchievements.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Upcoming Achievements',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              buildAchievementGrid(upcomingAchievements),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAchievementGrid(List<Achievement> list) {
    final receivedAchievementIDs = AchievementDB.getList;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return buildAchievementTile(list[index], receivedAchievementIDs.contains(list[index].id));
      },
    ); 
  }

  Widget buildAchievementTile(Achievement achievement, bool received) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: received ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 8.0),
          Expanded(
            flex: 2,
            child: FutureBuilder(
              future: achievement.showPiece,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Icon(Icons.error);
                } else {
                  return SizedBox(
                    child: received
                    ? snapshot.data
                    : const Image(
                      image: AssetImage(pokeballIcon),
                      color: Colors.grey,
                    ),
                  );
                }
              }
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: Text(
              achievement.name,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }  
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/provider/user_pokemon_db_provider.dart';
import 'package:guessthegyarados/utils/achivement_utils/widgets.dart';

class AchievementPage extends ConsumerStatefulWidget {
  const AchievementPage({super.key});

  @override
  ConsumerState<AchievementPage> createState() => _AchievementPageState();
}

class _AchievementPageState extends ConsumerState<AchievementPage> {

  @override
  Widget build(BuildContext context) {
    // Get the list of achievements. 
    final receivedAchievements = ref.read(userPokemonProvider).receivedAchievements;
    final upcomingAchievements = ref.read(userPokemonProvider).upcomingAchievements;
    
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
              if (receivedAchievements.isNotEmpty) // Show section only when list is not empty.
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
              if (receivedAchievements.isNotEmpty)
                buildAchievementGrid(receivedAchievements),
              if (upcomingAchievements.isNotEmpty) // Show section only when list is not empty.
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
              if (upcomingAchievements.isNotEmpty)
                buildAchievementGrid(upcomingAchievements),
            ],
          ),
        ),
      ),
    );
  }

    
}
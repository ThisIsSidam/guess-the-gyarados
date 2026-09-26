import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/application/providers/caught_pokemon_provider.dart';
import 'package:guessthegyarados/presentation/widgets/achievement_grid.dart';

class AchievementPage extends ConsumerWidget {
  const AchievementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(caughtPokemonProvider);
    final receivedAchievements = state.receivedAchievements;
    final upcomingAchievements = state.upcomingAchievements;

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
                buildAchievementGrid(upcomingAchievements, isReceived: false),
            ],
          ),
        ),
      ),
    );
  }
}

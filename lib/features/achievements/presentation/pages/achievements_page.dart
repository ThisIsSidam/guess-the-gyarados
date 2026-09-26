import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/shared/application/providers/caught_pokemon_provider.dart';
import 'package:guessthegyarados/shared/presentation/widgets/achievement_grid.dart';

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
      body: CustomScrollView(
        slivers: [
          const SliverPadding(padding: EdgeInsets.only(top: 16.0)),
          if (receivedAchievements.isNotEmpty) // Show section only when list is not empty.
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Received Achievements',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
          if (receivedAchievements.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: buildAchievementGridSliver(receivedAchievements),
            ),
          if (upcomingAchievements.isNotEmpty) // Show section only when list is not empty.
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Upcoming Achievements',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
          if (upcomingAchievements.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              sliver: buildAchievementGridSliver(upcomingAchievements, isReceived: false),
            ),
        ],
      ),
    );
  }
}

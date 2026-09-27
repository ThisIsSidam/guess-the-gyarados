import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/shared/application/providers/caught_pokemon_provider.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';
import 'package:guessthegyarados/shared/presentation/widgets/achievement_grid.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/animated_backdrop.dart';

class AchievementPage extends ConsumerWidget {
  const AchievementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(caughtPokemonProvider);
    final receivedAchievements = state.receivedAchievements;
    final upcomingAchievements = state.upcomingAchievements;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: const Text('ACHIEVEMENTS'),
      ),
      body: AnimatedBackdrop(
        accentColor: GameColors.gold,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight + 8)),
            if (receivedAchievements.isNotEmpty) // Show section only when list is not empty.
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '★ Received',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: GameColors.gold,
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
                    'Locked',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: GameColors.textMuted,
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
      ),
    );
  }
}

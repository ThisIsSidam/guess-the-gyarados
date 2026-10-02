import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/shared/application/providers/caught_pokemon_provider.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';
import 'package:guessthegyarados/shared/presentation/widgets/achievement_grid.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/folded_backdrop.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/game_page_header.dart';

class AchievementPage extends ConsumerWidget {
  const AchievementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(caughtPokemonProvider);
    final receivedAchievements = state.receivedAchievements;
    final upcomingAchievements = state.upcomingAchievements;

    return Scaffold(
      body: FoldedBackdrop(
        accentColor: GameColors.gold,
        pattern: FoldPattern.steepRising,
        child: SafeArea(
          child: Column(
            children: [
              const GamePageHeader(title: 'ACHIEVEMENTS'),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    if (receivedAchievements
                        .isNotEmpty) // Show section only when list is not empty.
                      const SliverToBoxAdapter(
                        child: _SectionLabel(
                          icon: Icons.star,
                          label: 'Received',
                          color: GameColors.goldDeep,
                        ),
                      ),
                    if (receivedAchievements.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        sliver:
                            buildAchievementGridSliver(receivedAchievements),
                      ),
                    if (upcomingAchievements
                        .isNotEmpty) // Show section only when list is not empty.
                      const SliverToBoxAdapter(
                        child: _SectionLabel(
                          icon: Icons.lock,
                          label: 'Locked',
                          color: GameColors.textMuted,
                        ),
                      ),
                    if (upcomingAchievements.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                        sliver: buildAchievementGridSliver(upcomingAchievements,
                            isReceived: false),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Section heading: an icon plus a label, so received vs. locked is carried by
// shape and text as well as color.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(
      {required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
          ),
        ],
      ),
    );
  }
}

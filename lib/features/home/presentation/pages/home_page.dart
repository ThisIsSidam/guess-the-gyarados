import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/shared/application/providers/caught_pokemon_provider.dart';
import 'package:guessthegyarados/shared/application/providers/pokemon_names_provider.dart';
import 'package:guessthegyarados/shared/application/providers/steps_provider.dart';
import 'package:guessthegyarados/core/constants/asset_paths.dart';
import 'package:guessthegyarados/core/constants/game_constants.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';
import 'package:guessthegyarados/features/achievements/presentation/pages/achievements_page.dart';
import 'package:guessthegyarados/features/caught/presentation/pages/caught_page.dart';
import 'package:guessthegyarados/features/play/presentation/pages/play_page.dart';
import 'package:guessthegyarados/features/pokedex/presentation/pages/pokedex_page.dart';
import 'package:guessthegyarados/features/profile/presentation/pages/profile_page.dart';
import 'package:guessthegyarados/features/home/presentation/widgets/daily_button.dart';
import 'package:guessthegyarados/features/home/presentation/widgets/pool_selector.dart';
import 'package:guessthegyarados/features/settings/presentation/pages/settings_page.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/folded_backdrop.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/game_button.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/outlined_text.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/tap_bounce.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  void _navigateToPlayPage(BuildContext context, WidgetRef ref) {
    ref.read(stepsCounterProvider.notifier).reborn();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PlayPage(),
      ),
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemonNamesFuture = ref.watch(pokemonNamesProvider);
    ref.watch(caughtPokemonProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: FoldedBackdrop(
        accentColor: GameColors.primary,
        pattern: FoldPattern.rising,
        child: SafeArea(
          child: Column(
            children: [
              hudRow(context),
              Expanded(
                child: pokemonNamesFuture.when(
                  data: (pokemonNames) => hero(context, ref),
                  error: (error, stackTrace) => Center(
                    child: Text(
                      'Error: $error',
                      style: const TextStyle(color: GameColors.textOnLight),
                    ),
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                        color: GameColors.backgroundDeep),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Replaces the old AppBar — plain icons laid straight onto the backdrop,
  // profile on the left and the collection screens grouped on the right.
  Widget hudRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          GameIconBadge(
            // Profile Page
            color: GameColors.gold,
            semanticLabel: 'Profile',
            onPressed: () => _open(context, const ProfilePage()),
            child: Image.asset(profileIconPath, width: 26, height: 26),
          ),
          const SizedBox(width: 12),
          GameIconBadge(
            semanticLabel: 'Settings',
            onPressed: () => _open(context, const SettingsPage()),
            child: const Icon(Icons.settings_rounded,
                color: GameColors.textOnLight, size: 28),
          ),
          const Spacer(),
          GameIconBadge(
            // Achievement Page
            semanticLabel: 'Achievements',
            onPressed: () => _open(context, const AchievementPage()),
            child: Image.asset(achievementsIconPath, width: 26, height: 26),
          ),
          const SizedBox(width: 12),
          GameIconBadge(
            // Caught Page; shows mons caught by user.
            semanticLabel: 'Caught Pokemon',
            onPressed: () => _open(context, const CaughtPage()),
            child: Image.asset(pokeballIcon, width: 26, height: 26),
          ),
          const SizedBox(width: 12),
          GameIconBadge(
            // Pokedex
            semanticLabel: 'Pokedex',
            onPressed: () => _open(context, const PokedexPage()),
            child: Image.asset(pokedexIconPath, width: 26, height: 26),
          ),
        ],
      ),
    );
  }

  Widget hero(BuildContext context, WidgetRef ref) {
    final titleStyle = Theme.of(context).textTheme.titleLarge!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Text(
              'GUESS THE',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: GameColors.backgroundDeep,
                    letterSpacing: 4,
                  ),
            ),
            OutlinedText(
              'GYARADOS',
              style: titleStyle.copyWith(fontSize: 44, letterSpacing: 1),
            ),
          ],
        ),
        // Still until touched: poking Arceus squashes and springs it back.
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TapBounce(
              pressedScale: 0.9,
              onTap: () {},
              child: Image.asset(
                arceusImagePath,
                fit: BoxFit.contain,
                height: 200,
                width: 200,
              ),
            ),
            const SizedBox(height: 16),
            caughtCounter(ref),
          ],
        ),
        const PoolSelector(),
        playButton(context, ref),
        const DailyButton(),
      ],
    );
  }

  // How far through the Pokedex the player is.
  Widget caughtCounter(WidgetRef ref) {
    final caught = ref.watch(caughtPokemonProvider).caughtPokemonIds.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 18, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(pokeballIcon, width: 28, height: 28),
          const SizedBox(width: 8),
          Text(
            '$caught / $totalPokemon caught',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: GameColors.textOnLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget playButton(BuildContext context, WidgetRef ref) {
    return GameButton(
      color: GameColors.primary,
      borderRadius: 24,
      depth: 10,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 64),
      onPressed: () => _navigateToPlayPage(context, ref),
      child: Text(
        'PLAY',
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: GameColors.backgroundDeep,
              letterSpacing: 2,
            ),
      ),
    );
  }
}

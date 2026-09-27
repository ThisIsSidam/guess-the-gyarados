import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/shared/application/providers/caught_pokemon_provider.dart';
import 'package:guessthegyarados/shared/application/providers/pokemon_names_provider.dart';
import 'package:guessthegyarados/shared/application/providers/steps_provider.dart';
import 'package:guessthegyarados/core/constants/asset_paths.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';
import 'package:guessthegyarados/features/achievements/presentation/pages/achievements_page.dart';
import 'package:guessthegyarados/features/caught/presentation/pages/caught_page.dart';
import 'package:guessthegyarados/features/play/presentation/pages/play_page.dart';
import 'package:guessthegyarados/features/pokedex/presentation/pages/pokedex_page.dart';
import 'package:guessthegyarados/features/profile/presentation/pages/profile_page.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/animated_backdrop.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/game_button.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemonNamesFuture = ref.watch(pokemonNamesProvider);
    ref.watch(caughtPokemonProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: topBar(context),
      body: AnimatedBackdrop(
        child: pokemonNamesFuture.when(
          data: (pokemonNames) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        'GUESS THE',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: GameColors.textMuted,
                          letterSpacing: 4,
                        ),
                      ),
                      Text(
                        'GYARADOS',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 34,
                          color: GameColors.gold,
                          shadows: [
                            Shadow(color: GameColors.gold.withValues(alpha: 0.6), blurRadius: 24),
                          ],
                        ),
                      ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(
                            duration: const Duration(seconds: 2),
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                    ],
                  ),
                  Image.asset(
                    arceusImagePath,
                    fit: BoxFit.cover,
                    height: 200,
                    width: 200,
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(
                        begin: -8,
                        end: 8,
                        duration: const Duration(seconds: 2),
                        curve: Curves.easeInOut,
                      ),
                  playButton(context, ref),
                ],
              ),
            );
          },
          error: (error, stackTrace) {
            return Center(
              child: Text('Error: $error'),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: GameColors.primary),
          ),
        ),
      ),
    );
  }

  AppBar topBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      leadingWidth: 76,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: GameIconBadge( // Profile Page
          color: GameColors.gold,
          onPressed: ()  {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage())
            );
          },
          child: Image.asset(profileIconPath, width: 26, height: 26),
        ),
      ),
      actions: [
        GameIconBadge( // Achievement Page
          onPressed: ()  {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AchievementPage())
            );
          },
          child: Image.asset(achievementsIconPath, width: 26, height: 26),
        ),
        const SizedBox(width: 12),
        GameIconBadge( // Caught Page; shows mons caught by user.
          onPressed: ()  {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CaughtPage())
            );
          },
          child: Image.asset(pokeballIcon, width: 26, height: 26),
        ),
        const SizedBox(width: 12),
        GameIconBadge( // Pokedex
          onPressed: ()  {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PokedexPage())
            );
          },
          child: Image.asset(pokedexIconPath, width: 26, height: 26),
        ),
        const SizedBox(width: 16),
      ],
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
    ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(
          begin: 1,
          end: 1.04,
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOut,
        );
  }
}

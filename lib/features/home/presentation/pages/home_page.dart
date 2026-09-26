import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/shared/application/providers/caught_pokemon_provider.dart';
import 'package:guessthegyarados/shared/application/providers/pokemon_names_provider.dart';
import 'package:guessthegyarados/shared/application/providers/steps_provider.dart';
import 'package:guessthegyarados/core/constants/asset_paths.dart';
import 'package:guessthegyarados/features/achievements/presentation/pages/achievements_page.dart';
import 'package:guessthegyarados/features/caught/presentation/pages/caught_page.dart';
import 'package:guessthegyarados/features/play/presentation/pages/play_page.dart';
import 'package:guessthegyarados/features/pokedex/presentation/pages/pokedex_page.dart';
import 'package:guessthegyarados/features/profile/presentation/pages/profile_page.dart';

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
      appBar: topBar(context),
      body: pokemonNamesFuture.when(
          data: (pokemonNames) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset(
                    arceusImagePath,
                    fit: BoxFit.cover,
                    height: 200,
                    width: 200,
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
            child: CircularProgressIndicator(),
          ),
        ),
    );
  }

  AppBar topBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: IconButton( // Profile Page
          onPressed: ()  {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage())
            );
          },
          icon: Image.asset(profileIconPath)
        ),
      actions: [
        IconButton( // Achievement Page
          onPressed: ()  {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AchievementPage())
            );
          },
          icon: Image.asset(achievementsIconPath)
        ),
        IconButton( // Caught Page; shows mons caught by user.
          onPressed: ()  {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CaughtPage())
            );
          },
          icon: Image.asset(pokeballIcon)
        ),
        IconButton( // Pokedex
          onPressed: ()  {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PokedexPage())
            );
          },
          icon: Image.asset(pokedexIconPath)
        )
      ],
    );
  }

  Widget playButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 200,
      width: 200,
      child: Material(
        elevation: 5,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        child: ElevatedButton(
          onPressed: () => _navigateToPlayPage(context, ref),
          style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
            backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.primary),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: const BorderSide(
                color: Colors.black,
                width: 7
              )
            ))
          ),
          child: Text(
            'Play',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/pages/caught_page.dart';
import 'package:guessthegyarados/pages/play_page.dart';
import 'package:guessthegyarados/provider/pokemon_provider.dart';
import 'package:guessthegyarados/provider/provider.dart';
import 'package:guessthegyarados/theme/theme.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  void _navigateToPlayPage(BuildContext context, WidgetRef ref) {

    ref.read(counterProvider.notifier).reborn();

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

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: ()  {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CaughtPage())
              );
            }, 
            icon: const Icon(Icons.catching_pokemon)
          )
        ],
      ),
      body: pokemonNamesFuture.when(
          data: (pokemonNames) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/mc_gyarados/homePageIcon.png",
                    fit: BoxFit.cover,
                    height: 300,
                    width: 300,
                  ),
                  const SizedBox(height: 20.0),
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () => _navigateToPlayPage(context, ref),
                      style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                        backgroundColor: const MaterialStatePropertyAll(completionPill)
                        
                      ),
                      child: const Text('Play'),
                    ),
                  ),
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
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/consts/strings.dart';
import 'package:guessthegyarados/pages/caught_page.dart';
import 'package:guessthegyarados/pages/play_page.dart';
import 'package:guessthegyarados/provider/pokemon_names_provider.dart';
import 'package:guessthegyarados/provider/steps_provider.dart';

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
      body: pokemonNamesFuture.when(
          data: (pokemonNames) {
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 40,),
                  topBar(context),
                  const SizedBox(height: 30,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/mc_gyarados/homePageIcon.png",
                        fit: BoxFit.cover,
                        height: 400,
                        width: 400,
                      ),
                      playButton(context, ref),
                    ],
                  ),
                  const SizedBox(),
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

  Widget topBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: ()  {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CaughtPage())
            );
          }, 
          icon: Image.asset(pokeballIcon)
        ),
        // IconButton(
        //   onPressed: ()  {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (context) => const SettingsPage())
        //     );
        //   }, 
        //   icon: const Icon(Icons.settings)
        // ),
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
            backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.primary),
            shape: MaterialStatePropertyAll(RoundedRectangleBorder(
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
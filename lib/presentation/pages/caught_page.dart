import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/application/providers/caught_pokemon_provider.dart';
import 'package:guessthegyarados/core/constants/asset_paths.dart';
import 'package:guessthegyarados/core/di/injection.dart';
import 'package:guessthegyarados/data/local/entities/pokemon_interaction_entity.dart';
import 'package:guessthegyarados/data/repositories/pokemon_repository.dart';
import 'package:guessthegyarados/data/repositories/user_pokemon_repository.dart';
import 'package:guessthegyarados/presentation/widgets/pokedex/individual_mon_dialog.dart';
import 'package:guessthegyarados/presentation/widgets/pokemon_sprite_image.dart';

class CaughtPage extends ConsumerWidget {
  const CaughtPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(caughtPokemonProvider);
    final caughtIds = getIt<UserPokemonRepository>().getCaughtPokemonIds().reversed.toList();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: topBar(context),
      body: Column(
        children: [
          caughtIds.isEmpty
          ? Expanded(child: emptyPage(context))
          : Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
              child: pokemonGridView(caughtIds),
            ),
          ),
        ],
      )
    );
  }

  // Bar includes step count and type widgets
  AppBar topBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Pokemon',
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.bold
        ),
      ),
      centerTitle: true,
      leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {Navigator.pop(context);},
        ),
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
    );
  }

  // In case there are no caught pokemons
  Widget emptyPage(BuildContext context) {
    int chance = Random().nextInt(1000);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            arceusImagePath,
            height: 150,
            width: 150,
            fit: BoxFit.contain,
          ),
          Text(
            chance == 7
            ?"Really bro? 0? \nGo catch some."
            :"Whoso doth not captureth \npokemon shall perish",
            style: Theme.of(context).textTheme.titleSmall,
            softWrap: true,
          )
        ],
      ),
    );
  }

  Widget pokemonGridView(List<int> caughtIds) {
    final userPokemonRepository = getIt<UserPokemonRepository>();

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: caughtIds.length > 10 ? 3 : 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: caughtIds.length,
      itemBuilder: (BuildContext context, int index) {
        final id = caughtIds[index];
        final interaction = userPokemonRepository.getForId(id);

        if (interaction == null) throw StateError("Catch Data Not Found for ID:$id");

        return GestureDetector(
          onTap: () {

            final pokemonData = getIt<PokemonRepository>().getCached(id);
            if (pokemonData == null) throw StateError("[pokemonGridView] pokemon Data not found");

            showDialog( // Show Pokemon's individual section when tapped
              context: context,
              barrierColor: Colors.black.withValues(alpha: 0.7),
              builder: (context) => PokemonDetailsSection(
                variantIds: pokemonData.variantIDs,
                firstCaughtVariant: id,
                firstGuessedVariant: null,
              ),
            );
          },
          child: imageDisplayTile(context, id, interaction),
        );
      },
    );
  }

  Widget imageDisplayTile(BuildContext context, int id, PokemonInteractionEntity interaction) {
    final pokemon = getIt<PokemonRepository>().getCached(id);

    return Container(
      width: 200,
      height: 200,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(15)
      ),
      child: Center(
        child: SizedBox(
          height: 100,
          width: 100,
          child: pokemon == null
          ? const Center(child: Text("⍰"))
          : PokemonSpriteImage(
              pokemonId: id,
              pokemonName: pokemon.name,
              isShiny: interaction.caughtShiny > 0,
            ),
        )
      ),
    );
  }
}

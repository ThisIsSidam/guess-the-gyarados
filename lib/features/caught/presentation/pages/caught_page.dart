import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/shared/application/providers/caught_pokemon_provider.dart';
import 'package:guessthegyarados/core/di/injection.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';
import 'package:guessthegyarados/shared/data/entities/pokemon_interaction_entity.dart';
import 'package:guessthegyarados/shared/data/repositories/pokemon_repository.dart';
import 'package:guessthegyarados/shared/data/repositories/user_pokemon_repository.dart';
import 'package:guessthegyarados/features/pokedex/presentation/widgets/individual_mon_dialog.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/folded_backdrop.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/game_page_header.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/tilt_card.dart';
import 'package:guessthegyarados/shared/presentation/widgets/pokemon_sprite_image.dart';
import 'package:guessthegyarados/shared/presentation/widgets/screens/message_of_god.dart';

class CaughtPage extends ConsumerWidget {
  const CaughtPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(caughtPokemonProvider);
    final caughtIds =
        getIt<UserPokemonRepository>().getCaughtPokemonIds().reversed.toList();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: FoldedBackdrop(
        accentColor: GameColors.primary,
        pattern: FoldPattern.steep,
        child: SafeArea(
          child: Column(
            children: [
              const GamePageHeader(title: 'MY POKEMON', backIcon: Icons.home),
              Expanded(
                child: caughtIds.isEmpty
                    ? emptyPage()
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: pokemonGridView(caughtIds),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // In case there are no caught pokemons
  Widget emptyPage() {
    int chance = Random().nextInt(1000);
    return MessageOfGod(
      message: chance == 7
          ? "Really bro? 0? \nGo catch some."
          : "Whoso doth not captureth \npokemon shall perish",
    );
  }

  Widget pokemonGridView(List<int> caughtIds) {
    final userPokemonRepository = getIt<UserPokemonRepository>();

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: caughtIds.length > 10 ? 3 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 14,
      ),
      itemCount: caughtIds.length,
      itemBuilder: (BuildContext context, int index) {
        final id = caughtIds[index];
        final interaction = userPokemonRepository.getForId(id);

        if (interaction == null) throw StateError("Catch Data Not Found for ID:$id");

        return TiltCard(
          maxTilt: 0.25,
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

  Widget imageDisplayTile(
      BuildContext context, int id, PokemonInteractionEntity interaction) {
    final pokemon = getIt<PokemonRepository>().getCached(id);
    final isShiny = interaction.caughtShiny > 0;

    // Shiny catches are marked with a star as well as the gold edge, so the
    // distinction never rests on color alone.
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: GameColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isShiny ? GameColors.goldDeep : GameColors.primaryDeep,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              height: 100,
              width: 100,
              child: pokemon == null
                  ? const Center(
                      child: Text("⍰",
                          style: TextStyle(color: GameColors.textOnLight)))
                  : PokemonSpriteImage(
                      pokemonId: id,
                      pokemonName: pokemon.name,
                      isShiny: isShiny,
                    ),
            ),
          ),
          if (isShiny)
            const Positioned(
              top: 0,
              right: 0,
              child: Icon(Icons.auto_awesome,
                  size: 20, color: GameColors.goldDeep),
            ),
        ],
      ),
    );
  }
}

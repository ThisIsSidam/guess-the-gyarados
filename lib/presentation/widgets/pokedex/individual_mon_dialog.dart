import 'package:flutter/material.dart';
import 'package:guessthegyarados/core/constants/asset_paths.dart';
import 'package:guessthegyarados/core/di/injection.dart';
import 'package:guessthegyarados/core/extensions/string_extensions.dart';
import 'package:guessthegyarados/core/theme/pokemon_type_colors.dart';
import 'package:guessthegyarados/data/local/entities/pokemon_entity.dart';
import 'package:guessthegyarados/data/repositories/pokemon_repository.dart';
import 'package:guessthegyarados/data/repositories/user_pokemon_repository.dart';
import 'package:guessthegyarados/domain/models/pokemon_variant_stats.dart';
import 'package:guessthegyarados/presentation/widgets/pokemon_sprite_image.dart';

class PokemonDetailsSection extends StatefulWidget {
  final List<int> variantIds;
  final int? firstCaughtVariant;
  final int? firstGuessedVariant;

  const PokemonDetailsSection({
    super.key,
    required this.variantIds,
    required this.firstCaughtVariant,
    required this.firstGuessedVariant
  });

  @override
  State<PokemonDetailsSection> createState() => _PokemonDetailsSectionState();
}

class _PokemonDetailsSectionState extends State<PokemonDetailsSection> {
  late int _currentVariantIndex;
  PokemonEntity? _currentPokemon;
  PokemonVariantStats? _currentVariantData;
  final Map<int, PokemonVariantStats?> variantData = {};

  @override
  void initState() {
    super.initState();

    if (widget.firstCaughtVariant == null && widget.firstGuessedVariant == null)
    {
      throw StateError("[PokemonDetailsSection] No Guessed Variant Found");
    }
    final chosenIndex = widget.variantIds.indexOf(widget.firstCaughtVariant ?? widget.firstGuessedVariant!);

    _currentVariantIndex = chosenIndex;

    final pokemonRepository = getIt<PokemonRepository>();
    final userPokemonRepository = getIt<UserPokemonRepository>();

    _currentPokemon = pokemonRepository.getCached(widget.variantIds[_currentVariantIndex]);

    for (final id in widget.variantIds) {
      variantData[id] = userPokemonRepository.getVariantStats(id);
    }

    _currentVariantData = variantData[widget.variantIds[_currentVariantIndex]];
  }

  void _changeVariant(int index) {
    final data = variantData[widget.variantIds[index]];

    if (data != null && data.guessed > 0) {
      setState(() {
        _currentVariantIndex = index;

        _currentPokemon = getIt<PokemonRepository>().getCached(widget.variantIds[index]);

        _currentVariantData = variantData[widget.variantIds[_currentVariantIndex]];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final variantStats = _currentVariantData;
    if (variantStats == null) {
      return const Center(child: Text("No variant is guessed"));
    }

    final pokemon = _currentPokemon;
    if (pokemon == null || variantStats.guessed == 0) {
      return const Center(child: Text("Pokemon Data Not Found"));
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPokemonImage(pokemon, variantStats),
          _buildVariantDots(),
          _buildDetailsContainer(pokemon, variantStats),
        ],
      ),
    );
  }

  Widget _buildPokemonImage(PokemonEntity pokemon, PokemonVariantStats variantStats) {
    final image = PokemonSpriteImage(
      pokemonId: widget.variantIds[_currentVariantIndex],
      pokemonName: pokemon.name,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
      child: variantStats.caughtTotal == 0
          ? ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcATop,
              ),
              child: image,
            )
          : image,
    );
  }

  Widget _buildVariantDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.variantIds.length,
        (index) {
          final data = variantData[widget.variantIds[index]];

          return Flexible(
            child: GestureDetector(
              onTap: () => _changeVariant(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 24),
                child: Opacity(
                  opacity: data == null ? 0.5 : data.guessed == 0 ? 0.5 : 1.0,
                  child: ColorFiltered(
                    colorFilter:  ColorFilter.mode(
                      data == null
                          ? Colors.black.withValues(alpha: 0.9)
                          : data.guessed == 0
                              ? Colors.grey.withValues(alpha: 0.9)
                              : Colors.transparent,
                      BlendMode.srcATop,
                    ),
                    child: Image.asset(
                      pokeballIcon,
                      width: index == _currentVariantIndex ? 24.0 : 16.0,
                      height: index == _currentVariantIndex ? 24.0 : 16.0,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailsContainer(PokemonEntity pokemon, PokemonVariantStats variantStats) {
    final primaryType = pokemon.types.first.capitalize;
    final secondaryType =
        pokemon.types.length > 1 ? pokemon.types[1].capitalize : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Material( // Had to add Material for Chip widgets.
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPokemonName(pokemon, primaryType, secondaryType),
                const SizedBox(height: 8.0),
                _buildStatsRow(variantStats),
                const SizedBox(height: 16.0),
                // Add more details about the Pokemon here
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPokemonName(PokemonEntity pokemon, String primaryType, String? secondaryType) {
    return Wrap(
      children: [
        Text(
          pokemon.name,
          softWrap: true,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Row(
          children: [
            Chip(
              label: Text(
                primaryType,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              backgroundColor: getColorFromString(primaryType),
            ),
            if (secondaryType != null)
              const SizedBox(width: 8.0),
            if (secondaryType != null)
              Chip(
                label: Text(
                  secondaryType,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                backgroundColor: getColorFromString(secondaryType),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow(PokemonVariantStats stats) {
    Text statText(String str) {
      return Text(
        str,
        style: Theme.of(context).textTheme.bodySmall,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        statText("Appeared: ${stats.appeared}"),
        statText("Guessed: ${stats.guessed}"),
        statText("Caught: ${stats.caughtTotal}"),
        statText("Shiny: ${stats.caughtShiny}")
      ],
    );
  }

}

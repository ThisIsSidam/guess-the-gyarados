import 'package:flutter/material.dart';
import 'package:guessthegyarados/consts/asset_paths.dart';
import 'package:guessthegyarados/database/pokemon_data_db.dart';
import 'package:guessthegyarados/database/user_pokemon_db.dart';
import 'package:guessthegyarados/pokemon_class/pokemon.dart';
import 'package:guessthegyarados/utils/get_image.dart';
import 'package:guessthegyarados/utils/misc_methods.dart';

enum PokemonDetailType {appeared, guessed, caughtTotal, caughtShiny}

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
  late Pokemon? _currentPokemon;
  late Map<PokemonDetailType, int>? _currentVariantData;
  final Map<int, Map<PokemonDetailType, int>?> variantData = {};

  @override
  void initState() {
    super.initState();

    if (widget.firstCaughtVariant == null && widget.firstGuessedVariant == null)
    {
      throw "[PokemonDetailsSection] No Guessed Variant Found";
    }
    final chosenIndex = widget.variantIds.indexOf(widget.firstCaughtVariant ?? widget.firstGuessedVariant!);

    _currentVariantIndex = chosenIndex;
    _currentPokemon = PokemonDB.getData(widget.variantIds[_currentVariantIndex]);

    for (final id in widget.variantIds) {
      final data = UserPokemonDB.getDataForId(id);
      variantData[id] = data != null ? _getVariantStats(data) : null;
    }

    _currentVariantData = variantData[widget.variantIds[_currentVariantIndex]];
  }

  void _changeVariant(int index) {
    final data = variantData[widget.variantIds[index]];

    if (data != null && data[PokemonDetailType.guessed]! > 0) {
      setState(() {
        _currentVariantIndex = index;

        _currentPokemon = PokemonDB.getData(widget.variantIds[index]);

        _currentVariantData = variantData[widget.variantIds[_currentVariantIndex]];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentVariantData == null) {
      return const Center(child: Text("No variant is guessed"));
    }

    final guessedCount = _currentVariantData![PokemonDetailType.guessed];

    if (_currentPokemon == null || guessedCount == 0) {
      return const Center(child: Text("Pokemon Data Not Found"));
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPokemonImage(),
          _buildVariantDots(),
          _buildDetailsContainer(),
        ],
      ),
    );
  }

  Widget _buildPokemonImage() {
    final caughtTotal = _currentVariantData![PokemonDetailType.caughtTotal];

    return Padding(
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
      child: FutureBuilder(
        future: getPokemonImage(widget.variantIds[_currentVariantIndex]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Image.asset(pokeballIcon);
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return caughtTotal == 0
                ? ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      Colors.black,
                      BlendMode.srcATop,
                    ),
                    child: snapshot.data,
                  )
                : snapshot.data!;
          }
        },
      ),
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
                  opacity: data == null ? 0.5 : data[PokemonDetailType.guessed] == 0 ? 0.5 : 1.0,
                  child: ColorFiltered(
                    colorFilter:  ColorFilter.mode(
                      data == null
                          ? Colors.black.withOpacity(0.9)
                          : data[PokemonDetailType.guessed] == 0
                              ? Colors.grey.withOpacity(0.9)
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

  Widget _buildDetailsContainer() {
    if (_currentPokemon == null) {
      return const Center(child: Text("Pokemon Data Not Found"));
    }

    final primaryType = _currentPokemon!.types.first.capitalize;
    final secondaryType =
        _currentPokemon!.types.length > 1 ? _currentPokemon!.types[1].capitalize : null;

    final variantStats = _currentVariantData;
    final appeared = variantStats![PokemonDetailType.appeared] ?? 0;
    final caughtTotal = variantStats[PokemonDetailType.caughtTotal] ?? 0;
    final guessedCount = variantStats[PokemonDetailType.guessed] ?? 0;
    final caughtShiny = variantStats[PokemonDetailType.caughtShiny] ?? 0;

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
                _buildPokemonName(primaryType, secondaryType),
                const SizedBox(height: 8.0),
                _buildStatsRow(appeared, guessedCount, caughtTotal, caughtShiny),
                const SizedBox(height: 16.0),
                // Add more details about the Pokemon here
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPokemonName(String primaryType, String? secondaryType) {
    return Wrap(
      children: [
        Text(
          _currentPokemon!.name,
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

  Widget _buildStatsRow(int appeared, int guessedCount, int caughtTotal, int caughtShiny) {
    Text statText(String str) {
      return Text(
        str,
        style: Theme.of(context).textTheme.bodySmall,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        statText("Appeared: $appeared"),
        statText("Guessed: $guessedCount"),
        statText("Caught: $caughtTotal"),
        statText("Shiny: $caughtShiny")
      ],
    );
  }

  Map<PokemonDetailType, int> _getVariantStats(Map<PokemonUpdateType, int> variantData) {
    final guessed = (variantData[PokemonUpdateType.catchFailed] ?? 0).toInt() +
        (variantData[PokemonUpdateType.caughtNormal] ?? 0).toInt() +
        (variantData[PokemonUpdateType.caughtShiny] ?? 0).toInt();
    final caughtTotal = (variantData[PokemonUpdateType.caughtNormal] ?? 0).toInt() +
        (variantData[PokemonUpdateType.caughtShiny] ?? 0).toInt();
    final appeared = (variantData[PokemonUpdateType.couldNotGuess] ?? 0).toInt() + guessed;
    final caughtShiny = variantData[PokemonUpdateType.caughtShiny] ?? 0;

    return {
      PokemonDetailType.appeared : appeared,
      PokemonDetailType.guessed : guessed,
      PokemonDetailType.caughtTotal : caughtTotal,
      PokemonDetailType.caughtShiny : caughtShiny
    };
  }
}
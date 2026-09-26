import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/application/providers/caught_pokemon_provider.dart';
import 'package:guessthegyarados/core/di/injection.dart';
import 'package:guessthegyarados/data/repositories/pokemon_repository.dart';
import 'package:guessthegyarados/data/repositories/user_pokemon_repository.dart';
import 'package:guessthegyarados/presentation/widgets/pokedex/individual_mon_dialog.dart';
import 'package:guessthegyarados/presentation/widgets/pokemon_sprite_image.dart';

class PokedexPage extends ConsumerStatefulWidget {
  const PokedexPage({super.key});

  @override
  ConsumerState<PokedexPage> createState() => _PokedexPageState();
}

class _PokedexPageState extends ConsumerState<PokedexPage> {
  late List<int> _regionStartIds;
  late List<String> _regionNames;
  int _currentRegionIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize _regionStartIds with the start IDs of each region
    _regionStartIds = [1, 152, 252, 387, 494, 650, 722, 810, 906];
    // Initialize _regionNames with the names of each region
    _regionNames = [
      'Kanto',
      'Johto',
      'Hoenn',
      'Sinnoh',
      'Unova',
      'Kalos',
      'Alola',
      'Galar+',
      'Paldea'
    ];
  }

  int _getRegionEndId(int index) {
    return index < _regionStartIds.length - 1
        ? _regionStartIds[index + 1] - 1
        : 1025; // Assuming 1025 is the last Pokemon ID
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(caughtPokemonProvider);

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: const Text('Pokedex'),
      ),
      body: Column(
        children: [
          regionBar(),
          Expanded(
            child: pokemonGrid(),
          ),
        ],
      ),
    );
  }

  // This bar is horizontally scrollable and shows all regions. Tapping them opens their page.
  Widget regionBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            _regionStartIds.length,
            (index) => GestureDetector(
              onTap: () {
                setState(() {
                  _currentRegionIndex = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Text(
                      _regionNames[index],
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentRegionIndex
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Grid of the pokemon from the currently selected region.
  Widget pokemonGrid() {
    final regionStartId = _regionStartIds[_currentRegionIndex];
    final regionEndId = _getRegionEndId(_currentRegionIndex);
    final pokemonRepository = getIt<PokemonRepository>();
    final userPokemonRepository = getIt<UserPokemonRepository>();

    return Padding(
      padding: const EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
      ),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          childAspectRatio: 1.0,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
        ),
        itemCount: regionEndId - regionStartId + 1,
        itemBuilder: (context, index) {
          final pokemonId = regionStartId + index;
          final pokemon = pokemonRepository.getCached(pokemonId);

          if (pokemon == null)
          {
            return gridViewElementWidget(null, null, pokemonId, null, null);
          }

          final variantIds = pokemon.variantIDs;
          int? firstCaughtVariant;
          int? firstGuessedVariant;

          for (final variantId in variantIds) {
            final interaction = userPokemonRepository.getForId(variantId);
            final isCaught = (interaction?.caughtNormal ?? 0) > 0 || (interaction?.caughtShiny ?? 0) > 0;
            final isVariantGuessed = (interaction?.catchFailed ?? 0) > 0;

            if (isCaught)
            {
              firstCaughtVariant = variantId;
              break;
            }
            else if (firstGuessedVariant == null && isVariantGuessed)
            {
              firstGuessedVariant = variantId;
            }
          }

          final imageId = firstCaughtVariant ?? firstGuessedVariant;
          final imagePokemon = imageId == null ? null : pokemonRepository.getCached(imageId);

          return gridViewElementWidget(firstCaughtVariant, firstGuessedVariant, pokemonId, variantIds, imagePokemon?.name);
        },
      ),
    );
  }

  Widget? getCenterWidget(int? firstCaughtVariant, int? firstGuessedVariant, int? imageId, String? imageName)
  {
    if (imageId == null || imageName == null) return null;

    final image = PokemonSpriteImage(pokemonId: imageId, pokemonName: imageName);

    /// [showPiece] the widget shown in the center of the tile: image/silouhette/id.
    if (firstCaughtVariant != null) return image;

    if (firstGuessedVariant != null) {
      return ColorFiltered(
        colorFilter: const ColorFilter.mode(
          Colors.black,
          BlendMode.srcATop,
        ),
        child: image,
      );
    }

    return null;
  }

  Widget gridViewElementWidget(
    int? firstCaughtVariant,
    int? firstGuessedVariant,
    int pokemonId,
    List<int>? variantIds,
    String? imageName,
  ) {

    final imageId = firstCaughtVariant ?? firstGuessedVariant;
    final child = getCenterWidget(firstCaughtVariant, firstGuessedVariant, imageId, imageName);

    return GestureDetector(
      onTap: () {

        if (firstCaughtVariant != null || firstGuessedVariant != null)
        {
          if (variantIds == null)
          {
            debugPrint("[gridViewElementWidget] variantids is null");
          }
          else
          {
            showDialog(
              context: context,
              barrierColor: Colors.black.withValues(alpha: 0.7),
              builder: (context) => PokemonDetailsSection(
                variantIds: variantIds,
                firstCaughtVariant: firstCaughtVariant,
                firstGuessedVariant: firstGuessedVariant,
              ),
            );

          }
        }

      },
      child: Container(
        decoration: child == null
        ? BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(8),
        ) : null,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Center(
            child: child ?? Text(
              '$pokemonId',
              style: Theme.of(context).textTheme.bodySmall,
            )
          ),
        ),
      ),
    );
  }
}

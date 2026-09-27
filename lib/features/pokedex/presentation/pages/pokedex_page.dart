import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/shared/application/providers/caught_pokemon_provider.dart';
import 'package:guessthegyarados/core/di/injection.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';
import 'package:guessthegyarados/shared/data/repositories/pokemon_repository.dart';
import 'package:guessthegyarados/shared/data/repositories/user_pokemon_repository.dart';
import 'package:guessthegyarados/features/pokedex/presentation/widgets/individual_mon_dialog.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/animated_backdrop.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/tilt_card.dart';
import 'package:guessthegyarados/shared/presentation/widgets/pokemon_sprite_image.dart';

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: const Text('POKÉDEX'),
      ),
      body: AnimatedBackdrop(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight)),
            SliverToBoxAdapter(child: regionBar()),
            pokemonGrid(),
          ],
        ),
      ),
    );
  }

  // This bar is horizontally scrollable and shows all regions. Tapping them opens their page.
  Widget regionBar() {
    return SizedBox(
      height: 56,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        scrollDirection: Axis.horizontal,
        itemCount: _regionStartIds.length,
        itemBuilder: (context, index) {
          final isSelected = index == _currentRegionIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  setState(() {
                    _currentRegionIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? GameColors.primary : GameColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isSelected
                        ? [BoxShadow(color: GameColors.primary.withValues(alpha: 0.5), blurRadius: 12)]
                        : null,
                  ),
                  child: Text(
                    _regionNames[index],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? GameColors.backgroundDeep : GameColors.textMuted,
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

  // Grid of the pokemon from the currently selected region, as a sliver so it
  // shares the page's single scroll position with the region bar above it
  // instead of owning a separate nested scrollable.
  Widget pokemonGrid() {
    final regionStartId = _regionStartIds[_currentRegionIndex];
    final regionEndId = _getRegionEndId(_currentRegionIndex);
    final pokemonRepository = getIt<PokemonRepository>();
    final userPokemonRepository = getIt<UserPokemonRepository>();

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          childAspectRatio: 1.0,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
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
          childCount: regionEndId - regionStartId + 1,
        ),
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
    final isKnown = child != null;

    return TiltCard(
      maxTilt: 0.25,
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
        decoration: BoxDecoration(
          color: isKnown ? GameColors.surfaceRaised : GameColors.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isKnown ? GameColors.primary.withValues(alpha: 0.5) : Colors.white12,
          ),
          boxShadow: isKnown
              ? [BoxShadow(color: GameColors.primary.withValues(alpha: 0.25), blurRadius: 10)]
              : null,
        ),
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

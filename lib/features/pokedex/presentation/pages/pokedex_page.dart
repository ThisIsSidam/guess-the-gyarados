import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/shared/application/providers/caught_pokemon_provider.dart';
import 'package:guessthegyarados/core/di/injection.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';
import 'package:guessthegyarados/shared/data/repositories/pokemon_repository.dart';
import 'package:guessthegyarados/shared/data/repositories/user_pokemon_repository.dart';
import 'package:guessthegyarados/features/pokedex/presentation/widgets/individual_mon_dialog.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/folded_backdrop.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/game_page_header.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/tap_bounce.dart';
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
      body: FoldedBackdrop(
        accentColor: GameColors.primary,
        pattern: FoldPattern.shallow,
        child: SafeArea(
          child: Column(
            children: [
              const GamePageHeader(title: 'POKÉDEX'),
              regionBar(),
              // Switching region fades the new grid in; keyed so it also
              // starts back at the top of the list.
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: CustomScrollView(
                    key: ValueKey(_currentRegionIndex),
                    primary: false,
                    slivers: [pokemonGrid()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // This bar is horizontally scrollable and shows all regions. Tapping them opens their page.
  Widget regionBar() {
    return SizedBox(
      height: 64,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
        scrollDirection: Axis.horizontal,
        itemCount: _regionStartIds.length,
        itemBuilder: (context, index) {
          final isSelected = index == _currentRegionIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TapBounce(
              onTap: () => setState(() => _currentRegionIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? GameColors.backgroundDeep
                      : GameColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? Color.lerp(
                              GameColors.backgroundDeep, Colors.black, 0.4)!
                          : const Color(0xFFC9CEDB),
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  _regionNames[index],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? GameColors.textOnDark
                        : GameColors.textMuted,
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          childAspectRatio: 1.0,
          crossAxisSpacing: 6,
          mainAxisSpacing: 8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final pokemonId = regionStartId + index;
            final pokemon = pokemonRepository.getCached(pokemonId);

            if (pokemon == null) {
              return gridViewElementWidget(null, null, pokemonId, null, null);
            }

            final variantIds = pokemon.variantIDs;
            int? firstCaughtVariant;
            int? firstGuessedVariant;

            for (final variantId in variantIds) {
              final interaction = userPokemonRepository.getForId(variantId);
              final isCaught = (interaction?.caughtNormal ?? 0) > 0 ||
                  (interaction?.caughtShiny ?? 0) > 0;
              final isVariantGuessed = (interaction?.catchFailed ?? 0) > 0;

              if (isCaught) {
                firstCaughtVariant = variantId;
                break;
              } else if (firstGuessedVariant == null && isVariantGuessed) {
                firstGuessedVariant = variantId;
              }
            }

            final imageId = firstCaughtVariant ?? firstGuessedVariant;
            final imagePokemon =
                imageId == null ? null : pokemonRepository.getCached(imageId);

            return gridViewElementWidget(firstCaughtVariant,
                firstGuessedVariant, pokemonId, variantIds, imagePokemon?.name);
          },
          childCount: regionEndId - regionStartId + 1,
        ),
      ),
    );
  }

  Widget? getCenterWidget(int? firstCaughtVariant, int? firstGuessedVariant,
      int? imageId, String? imageName) {
    if (imageId == null || imageName == null) return null;

    final image =
        PokemonSpriteImage(pokemonId: imageId, pokemonName: imageName);

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
    final child = getCenterWidget(
        firstCaughtVariant, firstGuessedVariant, imageId, imageName);
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
          color: isKnown
              ? GameColors.surface
              : GameColors.surface.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isKnown
              ? const [
                  BoxShadow(color: GameColors.primaryDeep, offset: Offset(0, 3))
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Center(
              child: child ??
                  Text(
                    '$pokemonId',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: GameColors.textMuted,
                    ),
                  )),
        ),
      ),
    );
  }
}

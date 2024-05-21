import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/database/pokemon_data_db.dart';
import 'package:guessthegyarados/provider/user_pokemon_db_provider.dart';
import 'package:guessthegyarados/utils/get_image.dart';
import 'package:guessthegyarados/utils/pokedex_widgets.dart/individual_mon_dialog.dart';

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
  final caughtData = ref.read(userPokemonProvider).caughtDetails;

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
        final pokemon = PokemonDB.getData(pokemonId);

        if (pokemon == null) 
        {
          return gridViewElementWidget(null, null, pokemonId, null);
        }


        final variantIds = pokemon.variantIDs;
        int? firstCaughtVariant;
        int? firstGuessedVariant;

        for (final variantId in variantIds) {
          final variantDetails = caughtData[variantId] ?? {};
          final isCaughtNormal = (variantDetails['caughtNormal'] ?? 0) > 0;
          final isCaughtShiny = (variantDetails['caughtShiny'] ?? 0) > 0;
          final isCaught = isCaughtNormal || isCaughtShiny;
          final isVariantGuessed = (variantDetails['catchFailed'] ?? 0) > 0;

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

        return gridViewElementWidget(firstCaughtVariant, firstGuessedVariant, pokemonId, variantIds);
      },
    ),
  );
}

  Widget? getCenterWidget(int? firstCaughtVariant, int? firstGuessedVariant, int pokemonId)
  { 

    int? imageId = firstCaughtVariant ?? firstGuessedVariant;
        
    late Widget image;
    if (imageId != null) {
      image = FutureBuilder(
        initialData: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CircularProgressIndicator(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
        future: getPokemonImage(imageId),
        builder: (context, snapshot) {
          return snapshot.data!;
        },
      );
    }

    /// [centerWidget] the widget shown in the center of the time: image/silouhette/id.
    final Widget? showPiece = firstCaughtVariant != null
      ? image 
      : firstGuessedVariant != null
        ? ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Colors.black,
            BlendMode.srcATop,
          ),
          child: image,
        )
        : null;


    return showPiece;
  }

  Widget gridViewElementWidget(
    int? firstCaughtVariant,
    int? firstGuessedVariant,
    int pokemonId,
    List<int>? variantIds
  ) {

    final child = getCenterWidget(firstCaughtVariant, firstGuessedVariant, pokemonId);

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
            debugPrint("[gridViewElementWidget] opening page");
            showDialog(
              context: context,
              barrierColor: Colors.black.withOpacity(0.7),
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
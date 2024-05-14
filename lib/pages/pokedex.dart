import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    _regionStartIds = [1, 152, 252, 387, 495, 650, 722, 810, 905];
    // Initialize _regionNames with the names of each region
    _regionNames = [
      'Kanto',
      'Johto',
      'Hoenn',
      'Sinnoh',
      'Unova',
      'Kalos',
      'Alola',
      'Galar',
      'Paldea'
    ];
  }

  int _getRegionEndId(int index) {
    return index < _regionStartIds.length - 1
        ? _regionStartIds[index + 1] - 1
        : 1010; // Assuming 1010 is the last Pokemon ID
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
            child: pokemonList(),
          ),
        ],
      ),
    );
  }

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

  Widget pokemonList() {
    final regionStartId = _regionStartIds[_currentRegionIndex];
    final regionEndId = _getRegionEndId(_currentRegionIndex);

    final caughtData = ref.read(caughtPokemonProvider).caughtDetails;


    return Padding(
      padding: const EdgeInsets.only(
        top: 16, left: 16, right: 16
      ),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          childAspectRatio: 1.0,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5
        ),
        itemCount: regionEndId - regionStartId + 1,
        itemBuilder: (context, index) {
          final pokemonId = regionStartId + index;
          final details = caughtData[pokemonId] ?? {};
          final isGuessed = 
              (details['caughtNormal'] ?? 0) > 0 ||
              (details['caughtShiny'] ?? 0) > 0 ||
              (details['catchFailed'] ?? 0) > 0;
          final isCaught = (details['caughtNormal'] ?? 0) > 0 ||
              ((details['caughtShiny'] ?? 0) > 0);
 
          late Widget image;
          if (isGuessed)
          {
            image = FutureBuilder(
              initialData: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  color: Theme.of(context).scaffoldBackgroundColor
                ),
              ),
              future: getPokemonImage(pokemonId), 
              builder: (context, snapshot) {
                return snapshot.data!;
              }
            );
            debugPrint("$pokemonId $details");
          }

            
          return GestureDetector(
            onTap: () {
              if (isCaught) showPokemonDetailsDialog(context, pokemonId);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Center(
                  child: isGuessed
                      ? isCaught
                          ? image
                          : ColorFiltered(
                              colorFilter: const ColorFilter.mode(
                                Colors.black,
                                BlendMode.srcATop,
                              ),
                              child: image,
                            )
                      : Text(
                          '$pokemonId',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
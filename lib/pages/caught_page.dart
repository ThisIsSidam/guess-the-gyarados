import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/consts/strings.dart';
import 'package:guessthegyarados/database/images_db.dart';
import 'package:guessthegyarados/database/pokemon_db.dart';
import 'package:guessthegyarados/provider/user_pokemon_db_provider.dart';
import 'package:guessthegyarados/utils/get_image.dart';

class CaughtPage extends ConsumerWidget {
  const CaughtPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<int, Map<String, int>> idList = ref.read(caughtPokemonProvider).caughtDetails;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: topBar(context),
      body: Column(
        children: [
          idList.isEmpty
          ? Expanded(child: emptyPage(context))
          : Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
              child: pokemonGridView(idList),
            ),
          ),
        ],
      )
    );
  }

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

  Widget pokemonGridView(Map<int, Map<String, int>> idMap) {

    final caughtIds = CaughtPokemonDB.getCaughtPokemonIDs().reversed;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: idMap.length > 10 ? 3 : 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: caughtIds.length,
      itemBuilder: (BuildContext context, int index) {
        int id = caughtIds.elementAt(index);
        final catchData = idMap[id];

        if (catchData == null) throw "Catch Data Not Found for ID:$id";

        int numberOfNormal = catchData[PokemonUpdateType.caughtNormal.name] ?? 0; 
        int numberOfShiny = catchData[PokemonUpdateType.caughtShiny.name] ?? 0; 
        return imageDisplayTile(
          context,
          id, 
          ImagesDB.getImage(id, isShiny: numberOfShiny > 0), 
          numberOfNormal, 
          numberOfShiny
        );
      },
    );
  }

  Widget imageDisplayTile(
    BuildContext context,
    int id, 
    Widget? image, 
    int normalCatch, 
    int shinyCatch
  ) {

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
          child: image ?? FutureBuilder(
            future: getPokemonImage(id,), 
            builder: (context, snapshot) {
              return snapshot.data ?? const Center(child: Text("⍰"));
            },
            initialData: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  color: Theme.of(context).scaffoldBackgroundColor
                ),
              ),
          ),
        )
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:guessthegyarados/database/images_db.dart';
import 'package:guessthegyarados/database/pokemon_db.dart';
import 'package:guessthegyarados/utils/get_image.dart';

class CaughtPage extends StatefulWidget {
  const CaughtPage({super.key});

  @override
  State<CaughtPage> createState() => _CaughtPageState();
}

class _CaughtPageState extends State<CaughtPage> {
  late Map<int, List<int>> idList = PokemonDB.idList;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 50,),
          topBar(),
          idList.isEmpty
          ? Expanded(child: emptyPage())
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

  Widget topBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Center(
            child: Text(
              'Caught Pokemon',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {Navigator.pop(context);},
          ),
        ],
      ),
    );
  }

  Widget emptyPage() {
    return Center(
      child: SizedBox(
        height: 150,
        width: 300,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/other_images/MissingNo.png",
              height: 150,
              width: 150,
              fit: BoxFit.contain,
            ),
            Expanded(
              child: Text(
                "No Pokemons? Fake fan.",
                style: Theme.of(context).textTheme.titleMedium,
                softWrap: true,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget pokemonGridView(Map<int ,List<int>> idMap) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: idMap.length,
      itemBuilder: (BuildContext context, int index) {
        final id = idMap.keys.toList()[index];
        int numberOfNormal = 0; 
        int numberOfShiny = 0; 
        for (var element in idMap[id]!) {
          if(element == 0) 
          {
            numberOfNormal++;
          } 
          else if (element == 1) 
          {
            numberOfShiny++;
          }
        }
        return imageDisplayTile(
          id, 
          ImagesDB.getImage(id, isShiny: numberOfShiny > 0), 
          numberOfNormal, 
          numberOfShiny
        );
      },
    );
  }

  Widget imageDisplayTile(
    int id, 
    Widget? image, 
    int normalCatch, 
    int shinyCatch
  ) {

    Widget circledNumber(int num, Color color) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: color
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(" $num "),
        ),
      );
    }

    return Stack(
      children: [
        Container(
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
                future: getPokemonImage(id, "null-name"), 
                builder: (context, snapshot) {
                  return snapshot.data!;
                }
              ),
            )
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            children: [
              if (normalCatch > 1)
                circledNumber(normalCatch, Theme.of(context).colorScheme.secondary),
              const SizedBox(width: 4,),
              if (shinyCatch > 0)
                circledNumber(shinyCatch, Theme.of(context).colorScheme.primary)
            ],
          )
        )
      ],
    );
  }
}
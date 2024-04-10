import 'package:flutter/material.dart';
import 'package:guessthegyarados/database/db.dart';
import 'package:guessthegyarados/pokemon_class/pokemon.dart';
import 'package:guessthegyarados/utils/fetch_data.dart';
import 'package:guessthegyarados/utils/get_image.dart';

class CaughtPage extends StatefulWidget {
  const CaughtPage({super.key});

  @override
  State<CaughtPage> createState() => _CaughtPageState();
}

class _CaughtPageState extends State<CaughtPage> {
  late List<int> idList;
  late Future<List<Pokemon>> _pokemonFuture;

  @override
  void initState() {
    super.initState();
    idList = HiveHelper.idList;
    _pokemonFuture = loadPokemonData();
  }

  Future<List<Pokemon>> loadPokemonData() async {
    List<Pokemon> tempPokemonList = [];
    for (int id in idList) {
      final pokemon = await fetchPokemonData(id);
      tempPokemonList.add(pokemon);
    }
    return tempPokemonList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Caught Pokemon'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {Navigator.pop(context);},
        ),
      ),
      body: FutureBuilder<List<Pokemon>>(
        future: _pokemonFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) 
          {
            return loadingPage();
          } 
          else if (snapshot.hasError) 
          {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } 
          else 
          {
            final pokemonList = snapshot.data!;
            return pokemonList.isEmpty
            ? emptyPage()
            : pokemonGridView(pokemonList);
          }
        },
      ),
    );
  }

  Widget loadingPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16.0),
          SizedBox(
            width: 200,
            child: Text(
              "Wait, your pokemons must be rushing here any moment.",
              softWrap: true,
              style: Theme.of(context).textTheme.titleSmall
            ),
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

  Widget pokemonGridView(List<Pokemon> pokemonList) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: pokemonList.length,
      itemBuilder: (BuildContext context, int index) {
        final pokemon = pokemonList[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 150,
            height: 150,
            child: FutureBuilder<Widget>(
                future: getPokemonImage(pokemon.id, pokemon.spriteUrl),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    debugPrint("[playPage] ${snapshot.error}");
                    return const Center(child: Text('[playPage] Failed to load image'));
                  } else {
                    return snapshot.data!;
                  }
                },
                
            ),
          ),
        );
      },
    );
  }
}
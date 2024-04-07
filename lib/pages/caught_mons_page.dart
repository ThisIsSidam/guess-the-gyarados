import 'package:flutter/material.dart';
import 'package:guessthegyarados/database/db.dart';
import 'package:guessthegyarados/pokemon_class/pokemon.dart';
import 'package:guessthegyarados/utils/fetch_data.dart';

class CaughtPage extends StatefulWidget {

  const CaughtPage({super.key});

  @override
  State<CaughtPage> createState() => _CaughtPageState();
}

class _CaughtPageState extends State<CaughtPage> {
  late List<int> idList;
  late List<Pokemon> pokemonList;

  @override
  void initState() {
    super.initState();
    idList = HiveHelper.idList;
    loadPokemonData();
  }

  Future<void> loadPokemonData() async {
    List<Pokemon> tempPokemonList = [];
    for (int id in idList) {
      final pokemon = await fetchPokemonData(id);
      tempPokemonList.add(pokemon);
    }
    setState(() {
      pokemonList = tempPokemonList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokémon Grid'),
      ),
      body: pokemonList != null
          ? GridView.builder(
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
                    child: Image.network(
                      pokemon.spriteUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:guessthegyarados/database/pokemon_data_db.dart';
import 'package:guessthegyarados/database/pokemon_db.dart';
import 'package:guessthegyarados/utils/get_image.dart';
import 'package:guessthegyarados/utils/misc_methods.dart';

Future<void> showPokemonDetailsDialog(BuildContext context, int pokemonId) async {
  final pokemon = PokemonDB.getData(pokemonId);
  final pokemonGameData = CaughtPokemonDB.getDataForId(pokemonId);

  if (pokemonGameData == null) throw "[showPokemonDetailsPage] PokemonGameData Not Found";
  if (pokemon == null) throw "[showPokemonDetailsDialog] Detail Retrieval Failed";

  final primaryType = pokemon.types.first.capitalize();
  final secondaryType = pokemon.types.length > 1 ? pokemon.types[1].capitalize() : null;

  final caughtShiny = pokemonGameData[PokemonUpdateType.caughtShiny] ?? 0;
  final caughtTotal = pokemonGameData[PokemonUpdateType.caughtNormal] ?? 0 + caughtShiny;
  final guessed = (pokemonGameData[PokemonUpdateType.catchFailed] ?? 0).toInt() + caughtTotal;
  final appeared = (pokemonGameData[PokemonUpdateType.couldNotGuess] ?? 0).toInt() + guessed;

  Text statText(String str) {
    return Text(
      str,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }

  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.7), // Dim the background
    builder: (BuildContext context) {
      return AlertDialog(
        surfaceTintColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent, // Set background color to transparent
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FutureBuilder(
              future: getPokemonImage(pokemonId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return snapshot.data!;
                }
              },
            ),
            const SizedBox(height: 16.0), // Add spacing between image and white section
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0), // Rounded corners
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          pokemon.name,
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
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        statText("Appeared: $appeared"),
                        statText("Guessed: $guessed"),
                        statText("Caught: $caughtTotal"),
                        statText("Shiny: $caughtShiny")
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    // Add more details about the Pokemon here
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
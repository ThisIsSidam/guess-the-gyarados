import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:guessthegyarados/consts/strings.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ImagesDB {
  static final _imagesBox = Hive.box(pokemonImagesBox);

  // Box has two compartments: one for normal images, second for shiny. They both store 
  // Maps of int(id) and image(Uint8List) in them.
  static Future<void> addImage(int pokemonId, Uint8List image, {bool isShiny = false}) async {
    try {
      final imagesMap = _getImagesMap(isShiny);
      imagesMap[pokemonId.toString()] = image;
      await _imagesBox.put(isShiny ? shinyImagesBoxKey : normalImagesBoxKey, imagesMap);
    } catch (e) {
      debugPrint('Failed to add image: $e');
    }
  }

  static Image? getImage(int pokemonId, {bool isShiny = false}) {
    final imagesMap = _getImagesMap(isShiny);
    final Uint8List? imageData = imagesMap[pokemonId.toString()];
    if (imageData != null) {
      return Image.memory( // because imageData is of type Uint8List
        imageData,
        errorBuilder: (context, error, stackTrace) {
          debugPrint("[gPI error] $error");
          debugPrint("[gPI error] $stackTrace");
          return const Center(child: Text('[getPokemonImage] Failed to load image'));
        },
        fit: BoxFit.contain,
      );
    } else {
      debugPrint('Image not found for Pokemon ID: $pokemonId');
      return null;
    }
  }

  static Map<String, Uint8List> _getImagesMap(bool isShiny) {
    final key = isShiny ? shinyImagesBoxKey : normalImagesBoxKey;
    final imagesMap = _imagesBox.get(key) ?? <String, Uint8List>{};
    return imagesMap.cast<String, Uint8List>();
  }
}
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ImagesDB {
  static final _imageBox = Hive.box('pokemon_images');


static Future<void> addImage(int pokemonId, Uint8List image) async {
    try {
      _imageBox.put(pokemonId.toString(), image);
    } catch (e) {
      debugPrint('Failed to add image: $e');
    }
  }

  // Retrieve an image from the _imageBox
  static Image? getImage(int pokemonId) {
    Uint8List? imageData = _imageBox.get(pokemonId.toString());
    if (imageData != null) 
    {
      return Image.memory(
        imageData,
        errorBuilder: (context, error, stackTrace) {
          debugPrint("[gPI error] $error");
          debugPrint("[gPI error] $stackTrace");
          return const Center(child: Text('[getPokemonImage] Failed to load image'));
        },
      fit: BoxFit.contain,
      );
    } 
    else 
    {
      debugPrint('Image not found for Pokemon ID: $pokemonId');
      return null;
    }
  }
}
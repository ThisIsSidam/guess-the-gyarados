import 'package:flutter/material.dart';

Widget getPokemonImage(String imageUrl) {
  return Image.network(
    imageUrl,
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) {
        return child;
      }
      return const Center(child: CircularProgressIndicator(
        backgroundColor: Color.fromARGB(255, 43, 173, 225),
      ));
    },
    errorBuilder: (context, error, stackTrace) {
      return const Center(child: Text('Failed to load image'));
    },
    fit: BoxFit.contain,
  );
}
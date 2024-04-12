// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';

Color getColorFromString(String input) {

  // Define a map of Pokémon types and their corresponding colors
  Map<String, Color> pokemonTypes = {
    'Fire': Colors.red.shade400,
    'Water': Colors.blue.shade300,
    'Grass': Colors.green.shade400,
    'Electric': Colors.yellow.shade600,
    'Normal': Colors.grey.shade400,
    'Fighting': Colors.orange.shade500,
    'Flying': Colors.indigo.shade200,
    'Poison': Colors.purple.shade400,
    'Ground': Colors.brown.shade400,
    'Rock': Colors.grey.shade600,
    'Bug': Colors.lightGreen.shade500,
    'Ghost': Colors.deepPurple.shade300,
    'Steel': Colors.grey.shade500,
    'Dragon': Colors.indigo.shade400,
    'Dark': Colors.grey.shade600,
    'Fairy': Colors.pink.shade200,
    'Psychic': Colors.pink.shade400,
    'Ice': Colors.lightBlue.shade300,
  };

  // Convert the input string to lowercase for case-insensitive matching
  input = input.toLowerCase();

  // Check if the input string matches a Pokémon type
  if (pokemonTypes.containsKey(input)) {
    return pokemonTypes[input]!;
  }

  // If not a Pokémon type, check for close resemblance
  for (String type in pokemonTypes.keys) {
    if (input.contains(type.toLowerCase())) {
      return pokemonTypes[type]!;
    }
  }

  // If no close resemblance found, assign a color based on the first character
  switch (input[0]) {
    case 'a':
    case 'e':
    case 'i':
    case 'o':
    case 'u':
      return Colors.pink.shade300;
    case 'b':
    case 'c':
    case 'd':
    case 'f':
    case 'g':
      return Colors.teal.shade400;
    case 'h':
    case 'j':
    case 'k':
    case 'l':
      return Colors.lime.shade400;
    case 'm':
    case 'n':
    case 'p':
    case 'q':
      return Colors.purple.shade400;
    case 'r':
    case 's':
    case 't':
    case 'v':
    case 'w':
    case 'x':
    case 'y':
    case 'z':
      return Colors.orange.shade400;
    default:
      return Colors.grey.shade400;
  }
}

String capitalizeString(String input) {
  // Split the input string by the hyphen
  List<String> parts = input.split('-');

  // Initialize an empty string to store the formatted string
  String formattedString = '';

  // Iterate over the parts
  for (int i = 0; i < parts.length; i++) {
    // Get the current part
    String part = parts[i];

    // Capitalize the first letter of the part
    String capitalizedPart = part[0].toUpperCase() + part.substring(1);

    // Append the capitalized part to the formatted string
    formattedString += capitalizedPart;

    // If it's not the last part, add a hyphen
    if (i < parts.length - 1) {
      formattedString += '-';
    }
  }

  return formattedString;
}

bool excludePokemon(String name) {
  if (name.contains("-mega")) return true;
  if (name.contains("-gmax")) return true;
  if (name.contains("-totem")) return true;
  if (name.startsWith("pikachu-")) return true;

  return false;
}

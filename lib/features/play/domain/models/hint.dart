import 'package:flutter/material.dart';

/// Things the player can buy with coins during a round. Hints don't cost
/// catch chance — the coins are the price — but a stronger hint costs more.
enum Hint {
  cry(
    label: 'Cry',
    description: 'Tap the Pokemon to hear it',
    icon: Icons.volume_up_rounded,
    cost: 20,
  ),
  firstLetter(
    label: 'First letter',
    description: 'Its first letter and how long the name is',
    icon: Icons.abc_rounded,
    cost: 40,
  ),
  silhouette(
    label: 'Silhouette',
    description: 'See its shape in the dark',
    icon: Icons.person_rounded,
    cost: 60,
  );

  const Hint({
    required this.label,
    required this.description,
    required this.icon,
    required this.cost,
  });

  final String label;
  final String description;
  final IconData icon;
  final int cost;

  /// "G _ _ _ _ _ _ _": the first letter with the rest hidden. Hyphens,
  /// spaces and dots in names like "mr-mime" are kept so the shape is right.
  static String maskName(String name) {
    final shown = <String>[];
    for (var i = 0; i < name.length; i++) {
      final c = name[i];
      if (i == 0) {
        shown.add(c.toUpperCase());
      } else if (c == '-' || c == ' ' || c == '.' || c == "'") {
        shown.add(c);
      } else {
        shown.add('_');
      }
    }
    return shown.join(' ');
  }
}

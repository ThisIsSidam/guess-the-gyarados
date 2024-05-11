import 'package:flutter/material.dart';

abstract class Achievement {
  final int id;
  final String name;
  final int points;
  final Future<Widget> showPiece;

  Achievement({
    required this.id,
    required this.name,
    required this.points,
    required this.showPiece,
  });
}

class ExistenceAchievement extends Achievement {
  final List<int> pokemonIds;

  ExistenceAchievement({
    required super.id,
    required super.name,
    required super.points,
    required super.showPiece,
    required this.pokemonIds,
  });
}

class MethodAchievement extends Achievement {
  final bool Function(Map<int, Map<String, int>>) achievementMethod;

  MethodAchievement({
    required super.id,
    required super.name,
    required super.points,
    required super.showPiece,
    required this.achievementMethod,
  });
}
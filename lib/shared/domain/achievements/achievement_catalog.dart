import 'package:guessthegyarados/shared/domain/achievements/achievement.dart';
import 'package:guessthegyarados/shared/domain/models/region.dart';

final List<Achievement> achievementCatalog = [
  ...legendAchievements,
  ...regionAchievements,
];

/// Three tiers per region: a first taste, a real collection, and the lot.
/// Ids start at 100 so they never collide with the legend achievements.
final List<Achievement> regionAchievements = [
  for (var i = 0; i < regions.length; i++) ...[
    RegionAchievement(
      id: 100 + i * 3,
      name: '${regions[i].name} Rookie',
      points: 200,
      region: regions[i],
      target: 10,
    ),
    RegionAchievement(
      id: 101 + i * 3,
      name: '${regions[i].name} Veteran',
      points: 600,
      region: regions[i],
      target: 25,
    ),
    RegionAchievement(
      id: 102 + i * 3,
      name: '${regions[i].name} Master',
      points: regions[i].size * 30,
      region: regions[i],
      target: regions[i].size,
    ),
  ],
];

final List<Achievement> legendAchievements = [
  ExistenceAchievement(
    id: 0,
    name: "Gen1 Legends",
    points: 5000,
    badgeImageID: 151,
    pokemonIds: [144, 145, 146, 150, 151],
  ),
  ExistenceAchievement(
    id: 1,
    name: "Gen2 Legends",
    points: 6000,
    badgeImageID: 251,
    pokemonIds: [243, 244, 245, 249, 250, 251],
  ),
  ExistenceAchievement(
    id: 2,
    name: "Gen3 Legends",
    points: 8000,
    badgeImageID: 384,
    pokemonIds: [377, 378, 379, 380, 381, 382, 383, 384],
  ),
  ExistenceAchievement(
    id: 3,
    name: "Gen4 Legends",
    points: 14000,
    badgeImageID: 493,
    pokemonIds: [480, 481, 482, 483, 484, 485, 486, 487, 488, 489, 490, 491, 492, 493],
  ),
  ExistenceAchievement(
    id: 4,
    name: "Gen5 Legends",
    points: 13000,
    badgeImageID: 649,
    pokemonIds: [494, 638, 639, 640, 641, 642, 643, 644, 645, 646, 647, 648, 649],
  ),
  ExistenceAchievement(
    id: 5,
    name: "Gen6 Legends",
    points: 6000,
    badgeImageID: 721,
    pokemonIds: [716, 717, 718, 719, 720, 721],
  ),
  ExistenceAchievement(
    id: 6,
    name: "Gen7 Legends",
    points: 25000,
    badgeImageID: 809,
    pokemonIds: List.generate(25, (index) => 785+index),
  ),
  ExistenceAchievement(
    id: 7,
    name: "Gen8 Legends",
    points: 12000,
    badgeImageID: 900,
    pokemonIds: List.generate(12, (index) => 888+index),
  ),
  ExistenceAchievement(
    id: 8,
    name: "Gen9 Legends",
    points: 22000,
    badgeImageID: 1020,
    pokemonIds: List.generate(12, (index) => 984+index) + List.generate(20, (index) => 1001+index),
  ),
  ExistenceAchievement(
    id: 9,
    name: "Eevee Family",
    points: 9999,
    badgeImageID: 133,
    pokemonIds: [133, 134, 135, 136, 196, 197, 470, 471, 700]
  ),
  ExistenceAchievement(
    id: 10,
    name: "Meteor Shower",
    points: 14141,
    badgeImageID: 774,
    pokemonIds: [774] + List.generate(13, (index) => 10130+index))
];

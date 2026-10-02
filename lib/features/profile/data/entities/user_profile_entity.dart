import 'package:objectbox/objectbox.dart';

/// Single-row entity — always fetched/stored under id 1 by
/// [UserProfileRepository].
@Entity()
class UserProfileEntity {
  UserProfileEntity({
    this.id = 1,
    this.username = 'missingUser',
    this.firstCatchPokemonId,
    this.userColorString,
    this.points = 0,
    this.level = 0,
    this.coins = 0,
    this.catchStreak = 0,
    this.bestStreak = 0,
    this.lastDailyDay = 0,
    this.dailyStreak = 0,
    this.bestDailyStreak = 0,
    this.lastDailyTrail = '',
    this.lastDailySteps = 0,
    this.lastDailySolved = false,
    this.lastDailyCaught = false,
  });

  /// Always 1 (single-row profile) — self-assigned, never auto-incremented.
  @Id(assignable: true)
  int id;

  String username;
  int? firstCatchPokemonId;

  /// A pokemon type name (the primary type of the user's first catch),
  /// reused as a color seed for profile theming.
  String? userColorString;

  int points;
  int level;

  /// Spendable currency for hints; earned alongside points on every round.
  int coins;

  /// Consecutive catches; a miss or forfeit resets it to 0.
  int catchStreak;
  int bestStreak;

  /// The last UTC epoch day a daily challenge was finished (0 = never), the
  /// consecutive days solved, and the last result's details for sharing.
  int lastDailyDay;
  int dailyStreak;
  int bestDailyStreak;

  /// The last daily's steps, one letter each (see `DailyStep`).
  String lastDailyTrail;
  int lastDailySteps;
  bool lastDailySolved;
  bool lastDailyCaught;
}

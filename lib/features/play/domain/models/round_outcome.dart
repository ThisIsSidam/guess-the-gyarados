/// What a finished round was worth, for the result popups on the play page.
class RoundOutcome {
  const RoundOutcome({
    required this.caught,
    required this.basePoints,
    required this.perfectBonus,
    this.streakBonus = 0,
    this.streak = 0,
    this.multiplier = 1,
    this.streakLost = false,
    this.coins = 0,
    this.dailyStreak = 0,
    this.dailyBonusCoins = 0,
    required this.isNewCatch,
    required this.levelBefore,
    required this.levelAfter,
  });

  /// The ball held. False for a broken ball and for a forfeit.
  final bool caught;
  final int basePoints;

  /// Zero unless the round had no wrong picks (and was caught).
  final int perfectBonus;

  /// Extra from catching several in a row (zero for the first).
  final int streakBonus;

  /// The catch streak after this round, and the multiplier this round used.
  final int streak;
  final double multiplier;

  /// A streak of one or more was broken by this round.
  final bool streakLost;
  final int coins;

  /// Set for a daily challenge: the consecutive days solved after it, and the
  /// coins that streak paid.
  final int dailyStreak;
  final int dailyBonusCoins;

  /// The first time this Pokemon was ever caught.
  final bool isNewCatch;
  final int levelBefore;
  final int levelAfter;

  RoundOutcome withDaily({required int streak, required int bonusCoins}) =>
      RoundOutcome(
        caught: caught,
        basePoints: basePoints,
        perfectBonus: perfectBonus,
        streakBonus: streakBonus,
        streak: this.streak,
        multiplier: multiplier,
        streakLost: streakLost,
        coins: coins,
        dailyStreak: streak,
        dailyBonusCoins: bonusCoins,
        isNewCatch: isNewCatch,
        levelBefore: levelBefore,
        levelAfter: levelAfter,
      );

  int get totalPoints => basePoints + perfectBonus + streakBonus;
  bool get leveledUp => levelAfter > levelBefore;
}

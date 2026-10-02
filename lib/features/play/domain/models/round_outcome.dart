/// What a finished round was worth, for the result popups on the play page.
class RoundOutcome {
  const RoundOutcome({
    required this.caught,
    required this.basePoints,
    required this.perfectBonus,
    required this.isNewCatch,
    required this.levelBefore,
    required this.levelAfter,
  });

  /// The ball held. False for a broken ball and for a forfeit.
  final bool caught;
  final int basePoints;

  /// Zero unless the round had no wrong picks (and was caught).
  final int perfectBonus;

  /// The first time this Pokemon was ever caught.
  final bool isNewCatch;
  final int levelBefore;
  final int levelAfter;

  int get totalPoints => basePoints + perfectBonus;
  bool get leveledUp => levelAfter > levelBefore;
}

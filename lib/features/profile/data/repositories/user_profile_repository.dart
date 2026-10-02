import 'package:guessthegyarados/features/profile/domain/daily_streak.dart';
import 'package:guessthegyarados/features/profile/domain/level_math.dart';
import 'package:guessthegyarados/features/profile/data/entities/user_profile_entity.dart';
import 'package:objectbox/objectbox.dart';

/// What an [UserProfileRepository.addPoints] call did to the player's level.
class PointsAward {
  const PointsAward({
    required this.points,
    required this.levelBefore,
    required this.levelAfter,
  });

  /// Progress into the current level after the award.
  final int points;
  final int levelBefore;
  final int levelAfter;

  bool get leveledUp => levelAfter > levelBefore;
}

class UserProfileRepository {
  UserProfileRepository(Store store) : _box = store.box<UserProfileEntity>();

  static const _profileId = 1;

  final Box<UserProfileEntity> _box;

  UserProfileEntity getProfile() {
    return _box.get(_profileId) ?? UserProfileEntity(id: _profileId);
  }

  Future<void> updateUsername(String username) async {
    final profile = getProfile();
    profile.username = username;
    _box.put(profile);
  }

  /// No-op if a first catch is already recorded.
  Future<void> recordFirstCatch(int pokemonId, String typeColorString) async {
    final profile = getProfile();
    if (profile.firstCatchPokemonId != null) return;

    profile.firstCatchPokemonId = pokemonId;
    profile.userColorString = typeColorString;
    _box.put(profile);
  }

  PointsAward addPoints(int addition) {
    final profile = getProfile();
    final levelBefore = profile.level;
    var finalPoints = profile.points + addition;
    var currentLevel = profile.level;
    var nextLevelPointThreshold = calculateLevelThreshold(currentLevel + 1);

    while (finalPoints > nextLevelPointThreshold) {
      currentLevel++;
      finalPoints -= nextLevelPointThreshold;
      nextLevelPointThreshold = calculateLevelThreshold(currentLevel + 1);
    }

    profile.points = finalPoints;
    profile.level = currentLevel;
    _box.put(profile);

    return PointsAward(
      points: finalPoints,
      levelBefore: levelBefore,
      levelAfter: currentLevel,
    );
  }

  void addCoins(int amount) {
    if (amount <= 0) return;
    final profile = getProfile();
    profile.coins += amount;
    _box.put(profile);
  }

  /// Takes [amount] coins if the player has them; false (and no change) if not.
  bool spendCoins(int amount) {
    final profile = getProfile();
    if (profile.coins < amount) return false;
    profile.coins -= amount;
    _box.put(profile);
    return true;
  }

  /// A catch extends the streak; anything else (miss, forfeit) resets it.
  /// Returns the streak after the update.
  int recordStreak({required bool caught}) {
    final profile = getProfile();
    if (caught) {
      profile.catchStreak++;
      if (profile.catchStreak > profile.bestStreak) {
        profile.bestStreak = profile.catchStreak;
      }
    } else {
      profile.catchStreak = 0;
    }
    _box.put(profile);
    return profile.catchStreak;
  }

  bool hasPlayedDaily(int epochDay) => getProfile().lastDailyDay == epochDay;

  /// Records a finished daily. Solving extends the streak (a single missed
  /// day in between is forgiven); not solving it resets the streak. Returns
  /// the streak after the update.
  int recordDaily({
    required int epochDay,
    required bool solved,
    required bool caught,
    required int steps,
    required String trail,
  }) {
    final profile = getProfile();
    profile.dailyStreak = nextDailyStreak(
      current: profile.dailyStreak,
      lastDay: profile.lastDailyDay,
      epochDay: epochDay,
      solved: solved,
    );
    if (profile.dailyStreak > profile.bestDailyStreak) {
      profile.bestDailyStreak = profile.dailyStreak;
    }

    profile.lastDailyDay = epochDay;
    profile.lastDailyTrail = trail;
    profile.lastDailySteps = steps;
    profile.lastDailySolved = solved;
    profile.lastDailyCaught = caught;
    _box.put(profile);
    return profile.dailyStreak;
  }
}

import 'package:guessthegyarados/core/utils/level_math.dart';
import 'package:guessthegyarados/data/local/entities/user_profile_entity.dart';
import 'package:objectbox/objectbox.dart';

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

  int addPoints(int addition) {
    final profile = getProfile();
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

    return finalPoints;
  }
}

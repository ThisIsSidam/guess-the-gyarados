import 'package:guessthegyarados/data/local/entities/received_achievement_entity.dart';
import 'package:guessthegyarados/objectbox.g.dart';

class AchievementRepository {
  AchievementRepository(Store store) : _box = store.box<ReceivedAchievementEntity>();

  final Box<ReceivedAchievementEntity> _box;

  void markReceived(int achievementId) {
    if (isReceived(achievementId)) return;
    _box.put(ReceivedAchievementEntity(
      achievementId: achievementId,
      receivedAt: DateTime.now(),
    ));
  }

  bool isReceived(int achievementId) {
    final query =
        _box.query(ReceivedAchievementEntity_.achievementId.equals(achievementId)).build();
    try {
      return query.count() > 0;
    } finally {
      query.close();
    }
  }

  Set<int> getReceivedIds() {
    return _box.getAll().map((e) => e.achievementId).toSet();
  }
}

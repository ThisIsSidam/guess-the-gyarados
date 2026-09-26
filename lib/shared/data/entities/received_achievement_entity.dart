import 'package:objectbox/objectbox.dart';

@Entity()
class ReceivedAchievementEntity {
  ReceivedAchievementEntity({
    this.id = 0,
    required this.achievementId,
    required this.receivedAt,
  });

  @Id()
  int id;

  @Unique()
  int achievementId;

  @Property(type: PropertyType.date)
  DateTime receivedAt;
}

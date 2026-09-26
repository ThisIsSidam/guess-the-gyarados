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
}

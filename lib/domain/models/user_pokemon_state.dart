import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:guessthegyarados/domain/achievements/achievement.dart';

part 'generated/user_pokemon_state.freezed.dart';

@freezed
abstract class UserPokemonState with _$UserPokemonState {
  const factory UserPokemonState({
    required List<int> caughtPokemonIds,
    required List<Achievement> receivedAchievements,
    required List<Achievement> upcomingAchievements,
    required List<Achievement> newlyReceivedAchievements,
  }) = _UserPokemonState;
}

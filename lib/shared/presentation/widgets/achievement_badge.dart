import 'package:flutter/material.dart';
import 'package:guessthegyarados/core/constants/asset_paths.dart';
import 'package:guessthegyarados/core/di/injection.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';
import 'package:guessthegyarados/core/theme/pokemon_type_colors.dart';
import 'package:guessthegyarados/shared/data/repositories/pokemon_repository.dart';
import 'package:guessthegyarados/features/profile/data/repositories/user_profile_repository.dart';
import 'package:guessthegyarados/shared/domain/achievements/achievement.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/tilt_card.dart';
import 'package:guessthegyarados/shared/presentation/widgets/pokemon_sprite_image.dart';

class AchievementBadge extends StatelessWidget {
  const AchievementBadge({
    super.key,
    required this.achievement,
    required this.isReceived,
  });

  final Achievement achievement;
  final bool isReceived;

  @override
  Widget build(BuildContext context) {
    if (!isReceived) {
      return Container(
        decoration: BoxDecoration(
          color: GameColors.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                const Image(image: AssetImage(pokeballIcon), color: Colors.grey, height: 40),
                const Icon(Icons.lock, color: GameColors.textMuted, size: 18),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              achievement.name,
              textAlign: TextAlign.center,
              style: const TextStyle(color: GameColors.textMuted),
            ),
          ],
        ),
      );
    }

    // Every current achievement's badgeImageID is included in its own
    // pokemonIds, so the pokemon must already be cached by the time the
    // achievement is received.
    final pokemon = getIt<PokemonRepository>().getCached(achievement.badgeImageID);
    if (pokemon == null) {
      throw StateError(
        '[AchievementBadge] Pokemon data not cached for id ${achievement.badgeImageID}',
      );
    }

    final color1 = getColorFromString(pokemon.types.first);
    final secondaryType = pokemon.types.length > 1 ? pokemon.types[1] : null;
    final userColorString = getIt<UserProfileRepository>().getProfile().userColorString;
    final color2 = getColorFromString(secondaryType ?? userColorString ?? 'Normal');

    return TiltCard(
      maxTilt: 0.25,
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [color1, color2, GameColors.backgroundDeep],
            radius: 2,
            center: Alignment.topLeft,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: GameColors.gold.withValues(alpha: 0.7), width: 2),
          boxShadow: [
            BoxShadow(color: GameColors.gold.withValues(alpha: 0.4), blurRadius: 16),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: PokemonSpriteImage(
                pokemonId: achievement.badgeImageID,
                pokemonName: pokemon.name,
              ),
            ),
            Text(
              achievement.name,
              style: const TextStyle(fontWeight: FontWeight.bold, color: GameColors.textOnDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }
}

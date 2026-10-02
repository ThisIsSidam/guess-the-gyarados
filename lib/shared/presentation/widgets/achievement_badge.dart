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
    this.caughtIds = const {},
  });

  final Achievement achievement;
  final bool isReceived;

  /// Used by region achievements to show progress while locked.
  final Set<int> caughtIds;

  @override
  Widget build(BuildContext context) {
    final achievement = this.achievement;
    if (achievement is RegionAchievement) {
      return isReceived
          ? _RegionReceivedTile(achievement: achievement)
          : _RegionLockedTile(achievement: achievement, caughtIds: caughtIds);
    }

    if (!isReceived) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE4E7EF),
          borderRadius: BorderRadius.circular(18),
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
              style: const TextStyle(color: GameColors.textMuted, fontWeight: FontWeight.w600),
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
          border: Border.all(color: GameColors.gold, width: 2),
          boxShadow: const [
            BoxShadow(color: GameColors.goldDeep, offset: Offset(0, 4)),
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

/// A region badge in progress: the name, what it asks for, and a progress bar.
class _RegionLockedTile extends StatelessWidget {
  const _RegionLockedTile({required this.achievement, required this.caughtIds});

  final RegionAchievement achievement;
  final Set<int> caughtIds;

  @override
  Widget build(BuildContext context) {
    final have = achievement.progress(caughtIds);
    final target = achievement.target;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE4E7EF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              const Image(
                  image: AssetImage(pokeballIcon),
                  color: Colors.grey,
                  height: 30),
              const Icon(Icons.lock, color: GameColors.textMuted, size: 14),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              achievement.name,
              style: const TextStyle(
                  color: GameColors.textOnLight, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: have / target,
              minHeight: 8,
              backgroundColor: Colors.white,
              color: GameColors.primaryDeep,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$have / $target',
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: GameColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _RegionReceivedTile extends StatelessWidget {
  const _RegionReceivedTile({required this.achievement});

  final RegionAchievement achievement;

  @override
  Widget build(BuildContext context) {
    return TiltCard(
      maxTilt: 0.25,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: const RadialGradient(
            colors: [
              GameColors.primaryDeep,
              GameColors.backgroundDeep,
            ],
            radius: 1.6,
            center: Alignment.topLeft,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: GameColors.gold, width: 2),
          boxShadow: const [
            BoxShadow(color: GameColors.goldDeep, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(pokeballIcon, height: 36),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                achievement.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: GameColors.textOnDark,
                    fontSize: 16),
              ),
            ),
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 13,
                  height: 1.1,
                  fontWeight: FontWeight.w600,
                  color: GameColors.textOnDark),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/shared/application/providers/caught_pokemon_provider.dart';
import 'package:guessthegyarados/core/di/injection.dart';
import 'package:guessthegyarados/core/extensions/color_extensions.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';
import 'package:guessthegyarados/core/theme/pokemon_type_colors.dart';
import 'package:guessthegyarados/shared/data/repositories/user_pokemon_repository.dart';
import 'package:guessthegyarados/features/profile/data/repositories/user_profile_repository.dart';
import 'package:guessthegyarados/shared/domain/achievements/achievement.dart';
import 'package:guessthegyarados/features/achievements/presentation/pages/achievements_page.dart';
import 'package:guessthegyarados/shared/presentation/widgets/achievement_grid.dart';
import 'package:guessthegyarados/features/profile/presentation/widgets/level_bar.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/folded_backdrop.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/game_button.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/game_page_header.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/tilt_card.dart';
import 'package:guessthegyarados/shared/presentation/widgets/screens/message_of_god.dart';

class ProfilePage extends ConsumerStatefulWidget {

  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final userNameController = TextEditingController();
  bool isEditingUsername = false;

  @override
  void initState() {
    super.initState();
    userNameController.text =
        getIt<UserProfileRepository>().getProfile().username;
  }

  @override
  Widget build(BuildContext context) {
    final profile = getIt<UserProfileRepository>().getProfile();
    final userColor =
        getColorFromString(profile.userColorString ?? "Normal").darken(0.2);

    final interactions = getIt<UserPokemonRepository>().getAll();
    final receivedAchievements =
        ref.watch(caughtPokemonProvider).receivedAchievements;

    int totalGuesses = 0;
    int totalAppeared = 0;
    int totalCaught = 0;
    int totalCaughtShiny = 0;
    int totalSpeciesCaught = 0;

    for (final interaction in interactions) {
      final caughtNormal = interaction.caughtNormal;
      final caughtShiny = interaction.caughtShiny;

      totalCaught += caughtNormal + caughtShiny;
      totalGuesses += interaction.catchFailed + caughtNormal + caughtShiny;
      totalAppeared += interaction.couldNotGuess +
          interaction.catchFailed +
          caughtNormal +
          caughtShiny;
      totalCaughtShiny += caughtShiny;
      if (caughtNormal > 0 || caughtShiny > 0) {
        totalSpeciesCaught++;
      }
    }

    double guessRate =
        totalGuesses > 0 ? (totalGuesses / totalAppeared) * 100 : 0.0;
    double catchRate =
        totalCaught > 0 ? (totalCaught / totalGuesses) * 100 : 0.0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: FoldedBackdrop(
        accentColor: userColor,
        pattern: FoldPattern.layered,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GamePageHeader(title: 'PROFILE'),
              _userNameRowWidget(context),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: LevelProgressBar(
                  currentPoints: profile.points,
                  currentLevel: profile.level,
                  levelBarColor: userColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        child: _statTile('${catchRate.toStringAsFixed(0)}%',
                            "Catch Rate", context)),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                        child: _statTile('${guessRate.toStringAsFixed(0)}%',
                            "Guess Rate", context))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        child: _statTile(
                            '$totalCaught', 'Pokemon Caught', context)),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: _statTile(
                            '$totalSpeciesCaught', 'Species Caught', context)),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: _statTile(
                            '$totalCaughtShiny', 'Shinies Caught', context)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                        child: _statTile('${profile.coins}', 'Coins', context)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _statTile(
                            '${profile.bestStreak}', 'Best Streak', context)),
                  ],
                ),
              ),
              Expanded(
                child: _achievementsSection(receivedAchievements),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _userNameRowWidget(BuildContext context) {
    final nameStyle = Theme.of(context).textTheme.titleLarge!.copyWith(
          color: GameColors.textOnLight,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Hello,", style: nameStyle),
          const SizedBox(
            width: 10,
          ),
          Flexible(
            child: isEditingUsername
                ? SizedBox(
                    width: 200,
                    child: TextField(
                      controller: userNameController,
                      autofocus: true,
                      style: nameStyle,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: GameColors.backgroundDeep, width: 2.0),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: GameColors.backgroundDeep, width: 2.0),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      onSubmitted: (value) {
                        getIt<UserProfileRepository>().updateUsername(value);

                        setState(() {
                          isEditingUsername = false;
                        });
                      },
                    ),
                  )
                : Text(
                    userNameController.text,
                    overflow: TextOverflow.ellipsis,
                    style: nameStyle,
                  ),
          ),
          const SizedBox(width: 12.0),
          if (!isEditingUsername)
            GameIconBadge(
              size: 44,
              semanticLabel: 'Edit username',
              onPressed: () {
                setState(() {
                  isEditingUsername = true;
                });
              },
              child: const Icon(Icons.edit,
                  size: 20, color: GameColors.textOnLight),
            ),
        ],
      ),
    );
  }

  Widget _statTile(String value, String label, BuildContext context) {
    return TiltCard(
      maxTilt: 0.2,
      child: Container(
        decoration: BoxDecoration(
          color: GameColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: GameColors.goldDeep, offset: Offset(0, 4)),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: GameColors.backgroundDeep,
                  ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: GameColors.textMuted,
                    fontSize: 14,
                    height: 1.1,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _achievementsSection(List<Achievement> receivedAchievements) {
    return Container(
      decoration: const BoxDecoration(
        color: GameColors.surface,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Achievements',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: GameColors.textOnLight),
                ),
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AchievementPage()));
                    },
                    icon: const Icon(Icons.chevron_right,
                        color: GameColors.textOnLight))
              ],
            ),
          ),
          Expanded(
            child: receivedAchievements.isNotEmpty
                ? buildAchievementGrid(receivedAchievements)
                : const MessageOfGod(
                    message: "No Achievements. Play More. Catch More."),
          ),
        ],
      ),
    );
  }
}

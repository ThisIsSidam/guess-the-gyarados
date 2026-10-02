import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guessthegyarados/core/di/injection.dart';
import 'package:guessthegyarados/core/settings/haptics.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';
import 'package:guessthegyarados/features/play/domain/models/daily_challenge.dart';
import 'package:guessthegyarados/features/play/presentation/pages/play_page.dart';
import 'package:guessthegyarados/features/profile/data/repositories/user_profile_repository.dart';
import 'package:guessthegyarados/shared/application/providers/steps_provider.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/game_button.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/tap_bounce.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Today's challenge: gold and inviting until it's played, then a quiet white
/// "done" chip that opens the result to share. The same Pokemon for everyone,
/// one try a day.
class DailyButton extends ConsumerStatefulWidget {
  const DailyButton({super.key});

  @override
  ConsumerState<DailyButton> createState() => _DailyButtonState();
}

class _DailyButtonState extends ConsumerState<DailyButton> {
  final _repo = getIt<UserProfileRepository>();

  DailyChallenge get _today => DailyChallenge.today();
  bool get _done => _repo.hasPlayedDaily(_today.epochDay);

  Future<void> _onTap() async {
    if (_done) {
      await showDailyResultSheet(context, _today);
      return;
    }
    ref.read(stepsCounterProvider.notifier).reborn();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PlayPage(daily: true)),
    );
    // Back from the round: the button now shows the day as done.
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final today = _today;
    final done = _repo.hasPlayedDaily(today.epochDay);
    final streak = _repo.getProfile().dailyStreak;

    return TapBounce(
      onTap: _onTap,
      semanticLabel:
          'Daily challenge number ${today.number}${done ? ', done' : ''}',
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 8, 18, 8),
        decoration: BoxDecoration(
          color: done ? Colors.white : GameColors.gold,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: done ? Colors.transparent : GameColors.goldDeep,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: done ? const Color(0x33000000) : GameColors.goldDeep,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              done ? Icons.check_circle_rounded : Icons.calendar_month_rounded,
              size: 30,
              color: done ? GameColors.success : GameColors.textOnLight,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DAILY #${today.number}',
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    color: GameColors.textOnLight,
                  ),
                ),
                Text(
                  done
                      ? 'Done${streak > 1 ? ' · $streak-day streak' : ''}. Tap to share'
                      : streak > 0
                          ? 'New today · $streak-day streak'
                          : 'A new Pokemon every day',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                    color: done ? GameColors.textMuted : GameColors.textOnLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Today's finished daily: the result grid, a copy button, and the wait for
/// the next one.
Future<void> showDailyResultSheet(BuildContext context, DailyChallenge today) {
  final profile = getIt<UserProfileRepository>().getProfile();
  final text = dailyShareText(
    number: today.number,
    trail: profile.lastDailyTrail.split(''),
    solved: profile.lastDailySolved,
    caught: profile.lastDailyCaught,
    steps: profile.lastDailySteps,
    streak: profile.dailyStreak,
  );
  final wait = today.untilNext();

  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: GameColors.surfaceRaised,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's daily",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: GameColors.textOnLight,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: GameColors.textOnLight,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Next one in ${wait.inHours}h ${wait.inMinutes % 60}m',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: GameColors.textMuted,
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: GameButton(
                color: GameColors.primary,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 36),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: text));
                  Haptics.selection();
                  if (sheetContext.mounted) {
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Result copied. Paste it anywhere!')),
                    );
                  }
                },
                child: const Text(
                  'COPY RESULT',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: GameColors.textOnLight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

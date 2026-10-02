import 'package:flutter/material.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/game_button.dart';

/// Asks whether to give up on the current round. Resolves to true only when
/// the player picks "Let it go"; dismissing the dialog (barrier tap, system
/// back) counts as staying in the round.
Future<bool> showForfeitDialog(BuildContext context) async {
  final letGo = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (dialogContext) => const _ForfeitDialog(),
  );
  return letGo ?? false;
}

class _ForfeitDialog extends StatelessWidget {
  const _ForfeitDialog();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: GameColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.flag_rounded, size: 40, color: GameColors.danger),
            const SizedBox(height: 8),
            Text(
              'Let it go?',
              style: textTheme.titleLarge?.copyWith(color: GameColors.textOnLight),
            ),
            const SizedBox(height: 6),
            Text(
              "Can't find it? This Pokemon will count as a miss, and we'll show you who it was.",
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(color: GameColors.textMuted),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GameButton(
                    color: GameColors.primary,
                    onPressed: () => Navigator.pop(context, false),
                    child: const _ButtonLabel('Keep guessing'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GameButton(
                    color: GameColors.danger,
                    onPressed: () => Navigator.pop(context, true),
                    child: const _ButtonLabel('Let it go'),
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

class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: GameColors.textOnLight,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:guessthegyarados/core/extensions/string_extensions.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';
import 'package:guessthegyarados/features/play/domain/models/guess_feedback.dart';
import 'package:guessthegyarados/shared/data/entities/pokemon_entity.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/game_button.dart';
import 'package:guessthegyarados/shared/presentation/widgets/pokemon_sprite_image.dart';

/// A wrong name the player tried; [data] resolves to that Pokemon's real
/// stats (fetched from the API if it isn't cached) so it can be compared with
/// the mystery Pokemon.
class GuessEntry {
  const GuessEntry({required this.id, required this.name, required this.data});

  final int id;
  final String name;
  final Future<PokemonEntity> data;
}

/// Every wrong guess so far, newest first, each answered attribute by
/// attribute. [justMissed] is the "Not it!" view straight after a wrong pick;
/// otherwise it's the plain history.
Future<void> showGuessLogSheet({
  required BuildContext context,
  required List<GuessEntry> entries,
  required PokemonEntity answer,
  required bool justMissed,
  VoidCallback? onGuessAgain,
}) {
  final left = (maxNameGuesses - entries.length).clamp(0, maxNameGuesses);
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
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
            _Header(left: left, justMissed: justMissed),
            const SizedBox(height: 4),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final entry in entries.reversed)
                    _GuessRow(entry: entry, answer: answer),
                ],
              ),
            ),
            if (onGuessAgain != null && left > 0) ...[
              const SizedBox(height: 14),
              Center(
                child: GameButton(
                  color: GameColors.primary,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 36),
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    onGuessAgain();
                  },
                  child: const Text(
                    'GUESS AGAIN',
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
          ],
        ),
      ),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.left, required this.justMissed});

  final int left;
  final bool justMissed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            justMissed ? 'Not it!' : 'Your guesses',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: GameColors.textOnLight,
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < maxNameGuesses; i++)
                  Icon(
                    i < left ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                    color: i < left ? GameColors.danger : GameColors.textMuted,
                  ),
              ],
            ),
            Text(
              left == 0
                  ? 'No guesses left'
                  : '$left ${left == 1 ? 'guess' : 'guesses'} left',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: left == 0 ? GameColors.danger : GameColors.textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GuessRow extends StatelessWidget {
  const _GuessRow({required this.entry, required this.answer});

  final GuessEntry entry;
  final PokemonEntity answer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: GameColors.primaryDeep, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 52,
                  height: 52,
                  child: PokemonSpriteImage(
                    pokemonId: entry.id,
                    pokemonName: entry.name,
                    showLoadingIndicator: false,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.name.capitalize,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: GameColors.textOnLight,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FutureBuilder<PokemonEntity>(
              future: entry.data,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text(
                    "Couldn't look that one up.",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: GameColors.textMuted,
                    ),
                  );
                }
                final guess = snapshot.data;
                if (guess == null) {
                  return const Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Comparing...',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: GameColors.textMuted,
                        ),
                      ),
                    ],
                  );
                }
                return _Chips(
                  guess: guess,
                  feedback:
                      GuessFeedback.compare(guess: guess, answer: answer),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Chips extends StatelessWidget {
  const _Chips({required this.guess, required this.feedback});

  final PokemonEntity guess;
  final GuessFeedback feedback;

  @override
  Widget build(BuildContext context) {
    String type(int i) =>
        guess.types.length > i ? guess.types[i].capitalize : 'None';

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _HitChip('Gen', '${guess.generation}', feedback.generation),
        _HitChip('Type 1', type(0), feedback.type1),
        _HitChip('Type 2', type(1), feedback.type2),
        _HitChip('Stage', '${guess.stageOfEvolution}', feedback.stage),
        _HitChip('Total', '${guess.bst}', feedback.bst),
      ],
    );
  }
}

/// One attribute of a guess: the value guessed, with an icon (and color) for
/// how it compares. Arrows point to where the answer lies.
class _HitChip extends StatelessWidget {
  const _HitChip(this.label, this.value, this.hit);

  final String label;
  final String value;
  final Hit hit;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color, String word) = switch (hit) {
      Hit.exact => (Icons.check_rounded, const Color(0xFFBFF0D2), 'match'),
      Hit.partial =>
        (Icons.swap_horiz_rounded, const Color(0xFFFFE9A8), 'other slot'),
      Hit.miss => (Icons.close_rounded, const Color(0xFFE4E7EF), 'no match'),
      Hit.higher =>
        (Icons.arrow_upward_rounded, const Color(0xFFCFE4FF), 'higher'),
      Hit.lower =>
        (Icons.arrow_downward_rounded, const Color(0xFFCFE4FF), 'lower'),
    };

    return Semantics(
      label: '$label $value: $word',
      child: Container(
        constraints: const BoxConstraints(minWidth: 86),
        padding: const EdgeInsets.fromLTRB(10, 6, 8, 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                    color: GameColors.textMuted,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    color: GameColors.textOnLight,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            Icon(icon, size: 22, color: GameColors.textOnLight),
          ],
        ),
      ),
    );
  }
}

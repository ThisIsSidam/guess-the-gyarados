import 'package:flutter/material.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';
import 'package:guessthegyarados/features/play/domain/models/clue_attempts.dart';
import 'package:guessthegyarados/features/play/presentation/widgets/question/inline_answer_panel.dart';

/// Opens the shared answer picker (grid of options, or a search field for
/// long lists) as a modal bottom sheet. The base page stays exactly as it
/// is underneath; only the sheet appears on top, and it closes itself the
/// [closeDelay] after a correct answer is picked, so the success state is
/// seen (a wrong one just reports via [onAttempt] and leaves the sheet open).
/// With [attempts], tries are limited — see [InlineAnswerPanel].
///
/// `showModalBottomSheet` resolves through the `Navigator`, not
/// `Scaffold.of`, so the [context] passed in doesn't need a `Scaffold`
/// ancestor — the caller's own `build` context works fine.
Future<void> showAnswerSheet({
  required BuildContext context,
  required String question,
  required List<String> options,
  required String correctAnswer,
  bool coloredOptions = false,
  Color accentColor = GameColors.primary,
  ClueAttempts? attempts,
  Duration closeDelay = const Duration(milliseconds: 750),
  required void Function(bool correct, String value) onAttempt,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          top: 8,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
        ),
        child: InlineAnswerPanel(
          question: question,
          options: options,
          coloredOptions: coloredOptions,
          accentColor: accentColor,
          attempts: attempts,
          closeDelay: closeDelay,
          onSelect: (value) {
            final correct = value.toLowerCase() == correctAnswer.toLowerCase();
            onAttempt(correct, value);
            return correct;
          },
          // The delayed auto-close can fire after the player already closed
          // the sheet by hand; popping then would pop the page underneath.
          onClose: () {
            if (ModalRoute.of(sheetContext)?.isCurrent ?? false) {
              Navigator.pop(sheetContext);
            }
          },
        ),
      );
    },
  );
}

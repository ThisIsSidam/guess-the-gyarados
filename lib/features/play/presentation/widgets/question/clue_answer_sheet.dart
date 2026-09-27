import 'package:flutter/material.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';
import 'package:guessthegyarados/features/play/presentation/widgets/question/inline_answer_panel.dart';

/// Opens the shared answer picker (grid of options, or a search field for
/// long lists) as a modal bottom sheet. The base page stays exactly as it
/// is underneath; only the sheet appears on top, and it closes itself the
/// moment a correct answer is picked (a wrong one just increments the step
/// counter via [onAttempt] and leaves the sheet open to try again).
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
          onSelect: (value) {
            final correct = value.toLowerCase() == correctAnswer.toLowerCase();
            onAttempt(correct, value);
            if (correct) Navigator.pop(sheetContext);
          },
          onClose: () => Navigator.pop(sheetContext),
        ),
      );
    },
  );
}

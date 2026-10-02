import 'package:flutter/foundation.dart';

/// The tries a player has spent on one choice clue this round. Lives for the
/// whole round (not the dialog), so closing and reopening a clue never hands
/// back tries or un-wrongs an option; it's a [Listenable] so an open dialog
/// updates the moment a wrong pick is recorded.
class ClueAttempts extends ChangeNotifier {
  ClueAttempts(this.maxAttempts);

  final int maxAttempts;

  final Set<String> _wrong = {};

  int get used => _wrong.length;
  int get left => maxAttempts - used;
  bool get exhausted => used >= maxAttempts;

  bool isWrong(String option) => _wrong.contains(option.toLowerCase());

  void recordWrong(String option) {
    if (_wrong.add(option.toLowerCase())) notifyListeners();
  }
}

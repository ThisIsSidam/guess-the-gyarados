import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/steps_provider.g.dart';

/// Tracks the guess-attempt counter for the current game round.
@riverpod
class StepsCounter extends _$StepsCounter {
  @override
  int build() => 0;

  void increment() => state++;

  void reborn() => state = 0;
}

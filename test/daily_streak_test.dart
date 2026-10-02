import 'package:flutter_test/flutter_test.dart';
import 'package:guessthegyarados/features/profile/domain/daily_streak.dart';

void main() {
  int next(int current, int lastDay, int day, {bool solved = true}) =>
      nextDailyStreak(
          current: current, lastDay: lastDay, epochDay: day, solved: solved);

  test('the first daily starts a streak of one', () {
    expect(next(0, 0, 20000), 1);
  });

  test('consecutive days extend it', () {
    expect(next(4, 20000, 20001), 5);
  });

  test('one missed day is forgiven, two are not', () {
    expect(next(4, 20000, 20002), 5);
    expect(next(4, 20000, 20003), 1);
  });

  test('failing resets the streak', () {
    expect(next(7, 20000, 20001, solved: false), 0);
  });
}

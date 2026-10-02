import 'package:flutter_test/flutter_test.dart';
import 'package:guessthegyarados/core/constants/game_constants.dart';
import 'package:guessthegyarados/features/play/domain/models/daily_challenge.dart';

void main() {
  test('every instant in a UTC day gets the same challenge', () {
    final morning = DailyChallenge.today(DateTime.utc(2026, 10, 2, 0, 0, 1));
    final night = DailyChallenge.today(DateTime.utc(2026, 10, 2, 23, 59, 59));
    expect(morning.epochDay, night.epochDay);
    expect(morning.pokemonId, night.pokemonId);
  });

  test('numbering starts at 1 on launch day and counts up daily', () {
    expect(DailyChallenge.today(DateTime.utc(2026, 10, 1)).number, 1);
    expect(DailyChallenge.today(DateTime.utc(2026, 10, 2)).number, 2);
    expect(DailyChallenge.today(DateTime.utc(2026, 12, 31)).number, 92);
  });

  test('the pokemon is stable, in range, and varies day to day', () {
    final ids = <int>{};
    for (var d = 0; d < 400; d++) {
      final id = DailyChallenge(20000 + d).pokemonId;
      expect(id, inInclusiveRange(1, totalPokemon));
      expect(id, DailyChallenge(20000 + d).pokemonId);
      ids.add(id);
    }
    // 400 days should hit a healthy spread of the dex, not a handful.
    expect(ids.length, greaterThan(250));
  });

  test('time until the next challenge is measured to UTC midnight', () {
    final d = DailyChallenge.today(DateTime.utc(2026, 10, 2, 22, 30));
    expect(d.untilNext(DateTime.utc(2026, 10, 2, 22, 30)),
        const Duration(hours: 1, minutes: 30));
  });

  test('share text is a spoiler-free grid', () {
    final text = dailyShareText(
      number: 12,
      trail: const ['y', 'g', 'r', 'g'],
      solved: true,
      caught: true,
      steps: 5,
      streak: 3,
    );
    expect(text, '''Guess The Gyarados Daily #12
\u{1F7E8}\u{1F7E9}\u{1F7E5}\u{1F7E9}\u{1F3AF}
Caught in 5 steps · \u{1F525} 3-day streak''');

    final lost = dailyShareText(
      number: 3,
      trail: const ['r'],
      solved: false,
      caught: false,
      steps: 1,
      streak: 0,
    );
    expect(lost.split('\n').last, 'Got away');
    expect(lost, contains('\u{1F4A8}'));
  });

  test('a long trail wraps at ten squares', () {
    final text = dailyShareText(
      number: 1,
      trail: List.filled(14, 'g'),
      solved: true,
      caught: false,
      steps: 15,
      streak: 1,
    );
    final lines = text.split('\n');
    expect(lines.length, 4); // title, two grid rows, summary
    expect(lines[3], 'Found in 15 steps, it broke free');
  });
}

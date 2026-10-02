import 'package:guessthegyarados/core/constants/game_constants.dart';

/// The daily Pokemon: one per UTC day, the same for everybody, picked by a
/// date-seeded hash (no server involved). A day is an "epoch day": whole days
/// since 1970-01-01 UTC.
class DailyChallenge {
  const DailyChallenge(this.epochDay);

  /// The challenge for the UTC day containing [now] (default: right now).
  factory DailyChallenge.today([DateTime? now]) {
    final utc = (now ?? DateTime.now()).toUtc();
    final midnight = DateTime.utc(utc.year, utc.month, utc.day);
    return DailyChallenge(midnight.millisecondsSinceEpoch ~/ _msPerDay);
  }

  static const _msPerDay = 24 * 60 * 60 * 1000;

  /// Daily #1.
  static final _launchEpochDay =
      DateTime.utc(2026, 10, 1).millisecondsSinceEpoch ~/ _msPerDay;

  final int epochDay;

  /// "Guess The Gyarados Daily #N".
  int get number => epochDay - _launchEpochDay + 1;

  /// A 32-bit integer hash of the day, folded into the national dex. Written
  /// out by hand (not `Random(seed)`) so every platform and release agrees.
  int get pokemonId {
    var x = (epochDay * 2654435761 + 0x9E3779B9) & 0xFFFFFFFF;
    x ^= x >> 16;
    x = (x * 0x45D9F3B) & 0xFFFFFFFF;
    x ^= x >> 16;
    x = (x * 0x45D9F3B) & 0xFFFFFFFF;
    x ^= x >> 16;
    return x % totalPokemon + 1;
  }

  /// Time left until the next UTC midnight.
  Duration untilNext([DateTime? now]) {
    final current = (now ?? DateTime.now()).toUtc();
    final next = DateTime.utc(current.year, current.month, current.day + 1);
    return next.difference(current);
  }
}

/// One step of a round as the share grid shows it.
class DailyStep {
  const DailyStep._();

  /// A yes/no clue revealed.
  static const revealed = 'y';

  /// A right pick.
  static const right = 'g';

  /// A wrong pick or name.
  static const wrong = 'r';
}

/// The spoiler-free result to paste somewhere: a row of colored squares for
/// the steps taken, ending in a target (found) or a puff of smoke (didn't).
String dailyShareText({
  required int number,
  required List<String> trail,
  required bool solved,
  required bool caught,
  required int steps,
  required int streak,
}) {
  const square = {
    DailyStep.revealed: '\u{1F7E8}',
    DailyStep.right: '\u{1F7E9}',
    DailyStep.wrong: '\u{1F7E5}',
  };
  final marks = [
    for (final step in trail) square[step] ?? '⬜',
    solved ? '\u{1F3AF}' : '\u{1F4A8}',
  ];

  final rows = [
    for (var i = 0; i < marks.length; i += 10)
      marks.sublist(i, i + 10 > marks.length ? marks.length : i + 10).join(),
  ];

  final summary = !solved
      ? 'Got away'
      : caught
          ? 'Caught in $steps ${steps == 1 ? 'step' : 'steps'}'
          : 'Found in $steps ${steps == 1 ? 'step' : 'steps'}, it broke free';

  return [
    'Guess The Gyarados Daily #$number',
    ...rows,
    if (streak > 1) '$summary · \u{1F525} $streak-day streak' else summary,
  ].join('\n');
}

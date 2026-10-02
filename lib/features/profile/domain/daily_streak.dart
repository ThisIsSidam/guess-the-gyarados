/// The daily-challenge streak after a daily finished on [epochDay].
///
/// Solving extends the streak when the last daily was yesterday, or the day
/// before (one missed day is forgiven); a longer gap, or a first-ever daily,
/// starts again at 1. Failing resets it to 0.
int nextDailyStreak({
  required int current,
  required int lastDay,
  required int epochDay,
  required bool solved,
}) {
  if (!solved) return 0;
  final gap = epochDay - lastDay;
  if (lastDay != 0 && gap >= 1 && gap <= 2) return current + 1;
  return 1;
}

/// Which Pokemon a round can pick from. Smaller pools are easier (more
/// familiar), so they pay a smaller share of the points.
enum PlayPool {
  kanto('Kanto', 151, 0.7),
  gens1to3('Gens 1-3', 386, 0.85),
  all('All', 1025, 1.0);

  const PlayPool(this.label, this.maxId, this.difficulty);

  final String label;

  /// Pokemon ids 1..[maxId] are in the pool.
  final int maxId;

  /// Multiplier on every point payout from the pool's rounds.
  final double difficulty;

  static PlayPool byName(String? name) =>
      PlayPool.values.firstWhere((p) => p.name == name, orElse: () => all);
}

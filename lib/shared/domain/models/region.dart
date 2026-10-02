/// A region's slice of the national Pokedex (one generation's new Pokemon).
class Region {
  const Region(this.name, this.firstId, this.lastId);

  final String name;
  final int firstId;
  final int lastId;

  int get size => lastId - firstId + 1;

  /// How many of [caughtIds] belong to this region.
  int countCaught(Set<int> caughtIds) =>
      caughtIds.where((id) => id >= firstId && id <= lastId).length;
}

/// In generation order (index 0 = generation 1).
const regions = [
  Region('Kanto', 1, 151),
  Region('Johto', 152, 251),
  Region('Hoenn', 252, 386),
  Region('Sinnoh', 387, 493),
  Region('Unova', 494, 649),
  Region('Kalos', 650, 721),
  Region('Alola', 722, 809),
  Region('Galar', 810, 905),
  Region('Paldea', 906, 1025),
];

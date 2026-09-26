import 'package:guessthegyarados/data/local/entities/pokemon_interaction_entity.dart';
import 'package:guessthegyarados/domain/models/pokemon_variant_stats.dart';
import 'package:guessthegyarados/objectbox.g.dart';

class UserPokemonRepository {
  UserPokemonRepository(Store store) : _box = store.box<PokemonInteractionEntity>();

  final Box<PokemonInteractionEntity> _box;

  PokemonInteractionEntity? getForId(int pokemonId) {
    final query = _box.query(PokemonInteractionEntity_.pokemonId.equals(pokemonId)).build();
    try {
      return query.findFirst();
    } finally {
      query.close();
    }
  }

  List<PokemonInteractionEntity> getAll() => _box.getAll();

  List<int> getCaughtPokemonIds() {
    return getAll()
        .where((e) => e.caughtNormal > 0 || e.caughtShiny > 0)
        .map((e) => e.pokemonId)
        .toList();
  }

  void recordInteraction(int pokemonId, PokemonInteractionType type) {
    final existing = getForId(pokemonId) ?? PokemonInteractionEntity(pokemonId: pokemonId);
    existing.increment(type);
    _box.put(existing);
  }

  PokemonVariantStats? getVariantStats(int pokemonId) {
    final data = getForId(pokemonId);
    if (data == null) return null;

    final guessed = data.catchFailed + data.caughtNormal + data.caughtShiny;
    final caughtTotal = data.caughtNormal + data.caughtShiny;
    final appeared = data.couldNotGuess + guessed;

    return PokemonVariantStats(
      appeared: appeared,
      guessed: guessed,
      caughtTotal: caughtTotal,
      caughtShiny: data.caughtShiny,
    );
  }
}

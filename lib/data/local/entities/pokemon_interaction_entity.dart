import 'package:objectbox/objectbox.dart';

enum PokemonInteractionType { couldNotGuess, catchFailed, caughtNormal, caughtShiny }

/// One row per Pokemon id, replacing the old `Map<int, Map<String,int>>`
/// nested-map structure with a flat, typed entity.
@Entity()
class PokemonInteractionEntity {
  PokemonInteractionEntity({
    this.id = 0,
    required this.pokemonId,
    this.couldNotGuess = 0,
    this.catchFailed = 0,
    this.caughtNormal = 0,
    this.caughtShiny = 0,
  });

  @Id()
  int id;

  @Unique()
  int pokemonId;

  int couldNotGuess;
  int catchFailed;
  int caughtNormal;
  int caughtShiny;

  void increment(PokemonInteractionType type) {
    switch (type) {
      case PokemonInteractionType.couldNotGuess:
        couldNotGuess++;
        break;
      case PokemonInteractionType.catchFailed:
        catchFailed++;
        break;
      case PokemonInteractionType.caughtNormal:
        caughtNormal++;
        break;
      case PokemonInteractionType.caughtShiny:
        caughtShiny++;
        break;
    }
  }
}

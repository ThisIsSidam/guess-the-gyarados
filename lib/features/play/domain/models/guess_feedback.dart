import 'package:guessthegyarados/shared/data/entities/pokemon_entity.dart';

/// Wrong names a round allows before the Pokemon flees.
const maxNameGuesses = 5;

/// How one attribute of a wrong guess compares with the mystery Pokemon.
enum Hit {
  /// Same value.
  exact,

  /// Right type, wrong slot.
  partial,

  /// No match.
  miss,

  /// The mystery Pokemon's value is higher than the guess's.
  higher,

  /// ...lower than the guess's.
  lower,
}

/// A wrong name guess, answered attribute by attribute (Pokedle style) so the
/// next guess can be reasoned out instead of picked blindly.
class GuessFeedback {
  const GuessFeedback({
    required this.generation,
    required this.type1,
    required this.type2,
    required this.stage,
    required this.bst,
  });

  final Hit generation;
  final Hit type1;
  final Hit type2;
  final Hit stage;
  final Hit bst;

  factory GuessFeedback.compare({
    required PokemonEntity guess,
    required PokemonEntity answer,
  }) {
    return GuessFeedback(
      generation: _number(guess.generation, answer.generation),
      type1: _type(_slot(guess, 0), _slot(answer, 0), _slot(answer, 1)),
      type2: _type(_slot(guess, 1), _slot(answer, 1), _slot(answer, 0)),
      stage: _number(guess.stageOfEvolution, answer.stageOfEvolution),
      bst: _number(guess.bst, answer.bst),
    );
  }

  static String? _slot(PokemonEntity p, int i) =>
      p.types.length > i ? p.types[i].toLowerCase() : null;

  static Hit _number(int guess, int answer) {
    if (guess == answer) return Hit.exact;
    return answer > guess ? Hit.higher : Hit.lower;
  }

  // [guess] in its own slot against the answer's same slot and other slot.
  // A missing second type matches a missing second type.
  static Hit _type(String? guess, String? same, String? other) {
    if (guess == same) return Hit.exact;
    if (guess != null && guess == other) return Hit.partial;
    return Hit.miss;
  }
}

import 'package:guessthegyarados/core/di/injection.dart';
import 'package:guessthegyarados/shared/data/repositories/pokemon_names_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/pokemon_names_provider.g.dart';

@riverpod
Future<Map<int, String>> pokemonNames(Ref ref) {
  return getIt<PokemonNamesService>().loadNames();
}

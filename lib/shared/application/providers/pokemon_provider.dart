import 'dart:math';

import 'package:guessthegyarados/core/di/injection.dart';
import 'package:guessthegyarados/shared/data/entities/pokemon_entity.dart';
import 'package:guessthegyarados/shared/data/repositories/pokemon_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/pokemon_provider.g.dart';

@riverpod
Future<PokemonEntity> pokemon(Ref ref, int randomId) async {
  final repository = getIt<PokemonRepository>();
  final baseVariant = await repository.getOrFetch(randomId);

  final variantIds = baseVariant.variantIDs;
  final finalId = variantIds[Random().nextInt(variantIds.length)];

  if (finalId == randomId) return baseVariant;

  return repository.getOrFetch(finalId);
}

/// A species exactly as cataloged, with no random variant (mega, regional
/// form...) swapped in: the daily Pokemon must be the same for everyone.
@riverpod
Future<PokemonEntity> baseSpecies(Ref ref, int id) =>
    getIt<PokemonRepository>().getOrFetch(id);

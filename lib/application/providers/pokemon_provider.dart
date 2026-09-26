import 'dart:math';

import 'package:guessthegyarados/core/di/injection.dart';
import 'package:guessthegyarados/data/local/entities/pokemon_entity.dart';
import 'package:guessthegyarados/data/repositories/pokemon_repository.dart';
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

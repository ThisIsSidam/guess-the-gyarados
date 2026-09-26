import 'package:get_it/get_it.dart';
import 'package:guessthegyarados/core/network/dio_client.dart';
import 'package:guessthegyarados/data/local/objectbox_store.dart';
import 'package:guessthegyarados/data/repositories/achievement_repository.dart';
import 'package:guessthegyarados/data/repositories/pokemon_names_service.dart';
import 'package:guessthegyarados/data/repositories/pokemon_repository.dart';
import 'package:guessthegyarados/data/repositories/user_pokemon_repository.dart';
import 'package:guessthegyarados/data/repositories/user_profile_repository.dart';

final getIt = GetIt.instance;

/// Repositories, the Dio client, and the ObjectBox store are registered here
/// as get_it singletons and pulled directly via `getIt<T>()` wherever needed
/// (inside riverpod providers or widgets) — riverpod is reserved for actual
/// reactive UI/app state, not wrapped around every repository lookup.
Future<void> configureDependencies() async {
  final objectBoxStore = await ObjectBoxStore.create();
  getIt.registerSingleton<ObjectBoxStore>(objectBoxStore);

  getIt.registerLazySingleton<DioClient>(() => DioClient());

  getIt.registerLazySingleton<PokemonRepository>(
    () => PokemonRepository(getIt<ObjectBoxStore>().store, getIt<DioClient>()),
  );
  getIt.registerLazySingleton<UserPokemonRepository>(
    () => UserPokemonRepository(getIt<ObjectBoxStore>().store),
  );
  getIt.registerLazySingleton<AchievementRepository>(
    () => AchievementRepository(getIt<ObjectBoxStore>().store),
  );
  getIt.registerLazySingleton<UserProfileRepository>(
    () => UserProfileRepository(getIt<ObjectBoxStore>().store),
  );
  getIt.registerLazySingleton<PokemonNamesService>(() => PokemonNamesService());
}

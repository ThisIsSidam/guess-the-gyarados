import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guessthegyarados/core/di/injection.dart';
import 'package:guessthegyarados/core/network/dio_client.dart';
import 'package:guessthegyarados/data/local/objectbox_store.dart';
import 'package:guessthegyarados/data/repositories/achievement_repository.dart';
import 'package:guessthegyarados/data/repositories/pokemon_names_service.dart';
import 'package:guessthegyarados/data/repositories/pokemon_repository.dart';
import 'package:guessthegyarados/data/repositories/user_pokemon_repository.dart';
import 'package:guessthegyarados/data/repositories/user_profile_repository.dart';
import 'package:guessthegyarados/my_app.dart';
import 'package:guessthegyarados/objectbox.g.dart';

// The app's bootstrap now opens an ObjectBox store and registers get_it
// singletons before anything can render, so a bare `pumpWidget(MyApp())`
// would throw. This mirrors `configureDependencies()` against a temp-dir
// store instead of the real one.
void main() {
  late Directory tempDir;
  late ObjectBoxStore objectBoxStore;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('guessthegyarados_test_');
    final store = await openStore(directory: '${tempDir.path}/objectbox');
    objectBoxStore = ObjectBoxStore(store);

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
  });

  tearDown(() async {
    objectBoxStore.close();
    await getIt.reset();
    await tempDir.delete(recursive: true);
  });

  testWidgets('home page renders with a Play button', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    expect(find.text('Play'), findsOneWidget);
  });
}

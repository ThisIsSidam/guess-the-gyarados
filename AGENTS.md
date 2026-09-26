# AGENTS.md

Conventions and architecture notes for AI agents (and humans) working on this codebase. This is a small hobby Flutter game ("Guess The Gyarados") that went through a full architecture rewrite in 2026 — this file documents the decisions made during that rewrite and why, so future changes stay consistent with them rather than reinventing the pattern per-file.

## Layering

```
lib/
  core/           cross-cutting, no business logic (constants, theme, extensions, DioClient, get_it wiring)
  data/           local/ (ObjectBox entities + Store), remote/ (API DTO + parser), repositories/
  domain/         achievements (pure data), freezed value objects
  application/    riverpod providers only
  presentation/   pages + widgets
```

Dependency direction: `presentation` → `application`/`domain`/`data` → `core`. Nothing depends on `presentation`.

## State management: get_it + riverpod, deliberately not combined

- **get_it** (`core/di/injection.dart`) registers repositories, `DioClient`, and the `ObjectBoxStore` as singletons/lazy singletons, configured once in `configureDependencies()` before `runApp`.
- Code (provider bodies, widgets) pulls dependencies **directly** via `getIt<T>()`. There is intentionally **no** riverpod provider that just wraps a `getIt<T>()` lookup — that pattern was considered and rejected (more boilerplate, two ways to reach the same thing) in favor of using riverpod only for genuinely reactive state.
- **riverpod** (`riverpod_generator`, `@riverpod`) is reserved for state that actually needs to be watched/rebuilt-on: the current game step counter, the derived caught-pokemon/achievements state, the async pokemon-of-the-round fetch, the app theme, the pokemon-names cache.
- If you're adding a new repository or service: register it in `injection.dart`, call it via `getIt<T>()` where needed. Don't add a provider for it unless something needs to reactively watch it.

## Pokemon model: DTO vs. entity, deliberately two classes

`data/remote/pokemon_dto.dart` (`PokemonDto`, freezed) is the PokeAPI wire format. `data/local/entities/pokemon_entity.dart` (`PokemonEntity`, plain mutable class) is the ObjectBox local cache. They are **not** the same class, and this was a deliberate call, not an oversight:

- `objectbox_generator` needs to detect a usable generative constructor via static analysis; freezed's private `_$PokemonDtoImpl` behind a factory constructor is known to cause friction with that detection.
- The two classes already serve different purposes anyway (wire format vs. local cache) — `PokemonDto.toEntity()` bridges them.
- This is also why the four ObjectBox entities (`PokemonEntity`, `PokemonInteractionEntity`, `ReceivedAchievementEntity`, `UserProfileEntity`) are plain mutable classes, not freezed — that's standard, expected ObjectBox practice, not an inconsistency with the freezed usage elsewhere.

## Freezed / json_serializable

- Freezed is used for `PokemonDto`, `PokemonVariantStats`, and `UserPokemonState` — immutable value objects/DTOs where `copyWith`/equality genuinely help.
- **A freezed class using the factory-constructor pattern must be declared `abstract class`** (freezed 2.x+ requirement) — e.g. `@freezed abstract class Foo with _$Foo { const factory Foo(...) = _Foo; }`. Omitting `abstract` compiles the annotation fine but fails analysis with "Missing concrete implementations" — this bit us once during the rewrite, don't repeat it.
- `Achievement`/`ExistenceAchievement`/`MethodAchievement` are **not** freezed — they're already immutable via `final` fields, and `MethodAchievement.achievementMethod` is a closure whose freezed-generated equality would be meaningless.
- `json_serializable` is a dependency but **no model currently uses its generated `fromJson`/`toJson`**. PokeAPI's response shape needs custom field extraction (ability slot logic, evolution-chain tree walking) that doesn't map to declarative `@JsonKey` mapping, so `PokemonDto.fromPokemonJson` is a hand-written factory instead. If a future model has a JSON shape that genuinely is a flat field-for-field mapping, reach for `@JsonSerializable()` then.

## Pinned package versions — read before bumping riverpod/freezed/objectbox/cached_network_image

These are pinned to specific ranges for real dependency-resolution reasons, not just "latest available at the time":

- **`flutter_riverpod`/`riverpod_annotation`/`riverpod_generator` are all pinned to `3.0.3`.** The riverpod family (`riverpod`, `flutter_riverpod`, `riverpod_annotation`) is released in lockstep with matching version numbers — `riverpod_annotation` pins an *exact* `riverpod` version internally, so these three cannot be bumped independently of each other.
- **`objectbox_generator` (latest, `^5.3.2`) needs `analyzer` in `[8.1.1, 11.0.0)`.** `riverpod_generator`'s newer versions (4.x) need `analyzer [13.0.0, 15.0.0)` — no overlap, hence the older `riverpod_generator 3.0.3`. `freezed` and `json_serializable` are similarly pinned (`freezed ^3.2.1`, `json_serializable ^6.11.2`) to versions whose `analyzer` window overlaps `[8.1.1, 9.0.0)` with the other three. If you bump any one of `riverpod_generator`/`objectbox_generator`/`freezed`/`json_serializable`, re-check this overlap — `dart pub get` will refuse to resolve otherwise, and the actual pub.dev API (`curl https://pub.dev/api/packages/<pkg>/versions/<version>`) is the fastest way to check a version's `analyzer` constraint without trial-and-error.
- **`riverpod_lint`/`custom_lint` are not installed.** Their current versions need Dart SDK `>=3.13.0`; this project's installed SDK is `3.12.0`. Add them once the SDK is upgraded past that.
- **`cached_network_image` is pinned to `^3.4.1`, not the newer `4.x` line.** `cached_network_image` 4.0.0 depends on a separate `material_ui` package (Flutter's Material widgets extracted to pub.dev) whose current version requires a newer Flutter SDK than what's installed here (it uses `@awaitNotRequired`, re-exported through `flutter/foundation.dart`, which this Flutter version's SDK doesn't yet re-export). `cached_network_image` 3.4.1 uses the SDK's bundled Material widgets directly and has no such constraint.

## Testing

- `test/app_smoke_test.dart` replaces the stale default `flutter create` counter-app test. It manually mirrors `configureDependencies()` against a temp-directory ObjectBox store (not the real one) and pumps `MyApp`, checking the home page renders.
- **`flutter test` cannot currently run ObjectBox-backed tests on this host machine**: ObjectBox's native C library is only auto-bundled by `objectbox_flutter_libs` when building/running an actual Flutter app (Android/iOS/desktop target); `flutter test` runs on the host Dart VM directly and needs the native library installed separately. Either install it via ObjectBox's official script (`bash <(curl -s https://raw.githubusercontent.com/objectbox/objectbox-dart/main/install.sh)` — note it may ask for `sudo` to place the library in `/usr/local/lib`), or run tests on a connected device/emulator instead. This does **not** affect `flutter run`/`flutter build` — those work today, this is a host-testing-only gap.
- Codegen command: `dart run build_runner build --delete-conflicting-outputs`. `objectbox-model.json` (at `lib/objectbox-model.json`) must be **committed** — it preserves entity/property UIDs across schema changes; deleting it or letting it drift from `lib/objectbox.g.dart` will make ObjectBox treat entities as new on next generation.

## ObjectBox gotcha: self-assigned IDs need `assignable: true`

`PokemonEntity.id` (the real PokeAPI id) and `UserProfileEntity.id` (always `1`) are both explicitly set by the app rather than left for ObjectBox to auto-increment. By default ObjectBox rejects a `put()` whose id is "higher than or equal to" its internal auto-increment sequence — this threw `OBX_ERROR code 10002` at runtime the first time this was tested end-to-end on a device (`flutter analyze`/`flutter build` don't catch it; it's a runtime-only failure). Fix: annotate the field `@Id(assignable: true)`. Any future entity that reuses an external id as its primary key (rather than letting ObjectBox generate one) needs the same annotation.

## Known pre-existing warts (ported deliberately, not silently fixed)

- The achievement-award side effect (awarding points while computing `newlyReceivedAchievements` in `CaughtPokemon._computeState()`) happens as a side effect of reading state rather than through an explicit action. It's idempotent (guarded by "already received"), so it's harmless, but it's a wart worth cleaning up if this area gets touched again.
- `MethodAchievement` exists as a class but has zero instances in `achievement_catalog.dart` today — all current achievements are `ExistenceAchievement`. Its `achievementMethod` signature was changed from the old `bool Function(Map<int, Map<String, int>>)` (which matched Hive's raw storage shape) to `bool Function(UserPokemonRepository)` during the rewrite, since there were no existing instances to preserve compatibility with.

## Fixed during the rewrite (for context, not to re-litigate)

- `play_page.dart` used to hardcode `pokemonFutureProvider(133)` (Eevee) instead of the page's own randomly-chosen id — every round showed Eevee's evolution line regardless of the actual random pick. Now uses `pokemonProvider(randomId)`.
- Several pages called `ref.read(userPokemonProvider)` inside `build()` instead of `ref.watch`, so they didn't reactively rebuild after achievements/catches changed elsewhere. All now use `ref.watch(caughtPokemonProvider)`.
- The `lib/utils/pokedex_widgets.dart/` directory (literally named with a `.dart` extension) is gone — that content now lives in `presentation/widgets/pokedex/`.

## Not yet needed, but the pattern to reach for when it is

- **`shared_preferences`**: no app setting exists today (theme is a constant, not user-configurable). All current profile fields (username/points/level/first-catch/color) are game-progress domain data in `UserProfileEntity`, not settings. When a real setting appears (e.g. a sound toggle), add a `shared_preferences`-backed `AppPreferences` class registered in `get_it`, following the same direct-`getIt<T>()` pattern as the repositories.
- **Pokemon-names caching**: `PokemonNamesService` re-parses the bundled `assets/data/pokemon_names.json` on first use and memoizes in memory for the process lifetime — no ObjectBox entity, no persistence. This is deliberate: it's static bundled data, so persisting a copy would just be another cache to keep in sync for no benefit.

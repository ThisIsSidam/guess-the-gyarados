import 'package:guessthegyarados/core/constants/api_links.dart';
import 'package:guessthegyarados/core/network/dio_client.dart';
import 'package:guessthegyarados/shared/data/entities/pokemon_entity.dart';
import 'package:guessthegyarados/shared/data/remote/pokemon_api_parser.dart';
import 'package:guessthegyarados/shared/data/remote/pokemon_dto.dart';
import 'package:objectbox/objectbox.dart';

class PokemonRepository {
  PokemonRepository(Store store, this._dio) : _box = store.box<PokemonEntity>();

  final Box<PokemonEntity> _box;
  final DioClient _dio;

  PokemonEntity? getCached(int id) => _box.get(id);

  /// Checks the cache first; fetches and caches on miss. Consolidates what
  /// used to be a cache-check duplicated between the provider and the old
  /// `fetch_data.dart` function.
  Future<PokemonEntity> getOrFetch(int id) async {
    final cached = getCached(id);
    if (cached != null) return cached;

    final json = await _dio.getJson('$pokemonDataApiLink$id');
    var dto = PokemonDto.fromPokemonJson(json);

    final speciesUrl = json['species']['url'] as String;
    final speciesData = await _dio.getJson(speciesUrl);
    final evolutionChainUrl = speciesData['evolution_chain']['url'] as String;
    final evolutionChainJson = await _dio.getJson(evolutionChainUrl);

    final evolutionDetails = PokemonUtils.getEvolutionDetails(evolutionChainJson, dto.name);

    var hasMega = dto.hasMega;
    var hasGmax = dto.hasGmax;
    final varieties = speciesData['varieties'] as List<dynamic>;
    for (final variety in varieties) {
      final varietyName = variety['pokemon']['name'] as String;
      if (varietyName.contains('-mega')) hasMega = true;
      if (varietyName.contains('-gmax')) hasGmax = true;
    }

    dto = dto.copyWith(
      evolutionTreeSize: evolutionDetails['evolutionTreeSize'] as int,
      evolutionItem: evolutionDetails['evolutionItem'] as String?,
      usableEvolutionItems: evolutionDetails['usableEvolutionItems'] as List<String>,
      stageOfEvolution: evolutionDetails['stageOfEvolution'] as int,
      hasMega: hasMega,
      hasGmax: hasGmax,
      isBaby: speciesData['is_baby'] as bool,
      isLegendary: speciesData['is_legendary'] as bool,
      isMythical: speciesData['is_mythical'] as bool,
      speciesID: speciesData['id'] as int,
      variantIDs: PokemonUtils.getVarietyIds(varieties),
    );
    dto = dto.copyWith(generation: PokemonUtils.getGeneration(dto.speciesID));

    final entity = dto.toEntity();
    _box.put(entity);
    return entity;
  }
}

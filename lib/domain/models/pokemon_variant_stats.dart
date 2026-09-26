import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/pokemon_variant_stats.freezed.dart';

@freezed
abstract class PokemonVariantStats with _$PokemonVariantStats {
  const factory PokemonVariantStats({
    required int appeared,
    required int guessed,
    required int caughtTotal,
    required int caughtShiny,
  }) = _PokemonVariantStats;
}

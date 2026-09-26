import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:guessthegyarados/core/constants/asset_paths.dart';
import 'package:guessthegyarados/core/utils/pokemon_image_links.dart';

/// Sprite loading/caching for a Pokemon, fully delegated to
/// `cached_network_image` (disk caching, in-flight de-duplication) — this
/// replaces the old manual `dart:io HttpClient` download + Hive-blob cache.
class PokemonSpriteImage extends StatelessWidget {
  const PokemonSpriteImage({
    super.key,
    required this.pokemonId,
    required this.pokemonName,
    this.isShiny = false,
    this.fit = BoxFit.contain,
  });

  final int pokemonId;
  final String pokemonName;
  final bool isShiny;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final primaryUrl = isShiny ? null : getPokemonImageLink(pokemonId, pokemonName);
    final backupUrl = getPokemonBackupImageLink(pokemonId, isShiny);

    return CachedNetworkImage(
      imageUrl: primaryUrl ?? backupUrl,
      fit: fit,
      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) {
        if (primaryUrl == null) {
          return Image.asset(missingNoIcon, fit: BoxFit.cover);
        }
        // The community-CDN sprite failed — fall back to the PokeAPI one.
        return CachedNetworkImage(
          imageUrl: backupUrl,
          fit: fit,
          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => Image.asset(missingNoIcon, fit: BoxFit.cover),
        );
      },
    );
  }
}

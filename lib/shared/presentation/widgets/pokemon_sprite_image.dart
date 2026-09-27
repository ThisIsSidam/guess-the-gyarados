import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:guessthegyarados/core/constants/asset_paths.dart';
import 'package:guessthegyarados/shared/utils/pokemon_image_links.dart';

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
    this.showLoadingIndicator = true,
  });

  final int pokemonId;
  final String pokemonName;
  final bool isShiny;
  final BoxFit fit;

  /// Set false to keep the space blank (no spinner) while the sprite loads
  /// — for spots like the play page's morph reveal, where a new sprite
  /// loads every couple of seconds and a flickering spinner would be worse
  /// than a brief blank.
  final bool showLoadingIndicator;

  Widget _placeholder(BuildContext context, String url) {
    if (!showLoadingIndicator) return const SizedBox.shrink();
    return const Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
    final primaryUrl = isShiny ? null : getPokemonImageLink(pokemonId, pokemonName);
    final backupUrl = getPokemonBackupImageLink(pokemonId, isShiny);

    return CachedNetworkImage(
      imageUrl: primaryUrl ?? backupUrl,
      fit: fit,
      placeholder: _placeholder,
      errorWidget: (context, url, error) {
        if (primaryUrl == null) {
          return Image.asset(missingNoIcon, fit: BoxFit.cover);
        }
        // The community-CDN sprite failed — fall back to the PokeAPI one.
        return CachedNetworkImage(
          imageUrl: backupUrl,
          fit: fit,
          placeholder: _placeholder,
          errorWidget: (context, url, error) => Image.asset(missingNoIcon, fit: BoxFit.cover),
        );
      },
    );
  }
}

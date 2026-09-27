import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:guessthegyarados/shared/presentation/widgets/pokemon_sprite_image.dart';

/// Stands in for the mystery Pokemon before it's been named: cycles through
/// random, unrelated Pokemon sprites, crossfading and scaling between them
/// — a "morph" rather than a static placeholder — so there's always
/// something alive on screen without hinting at the real answer.
/// [excludeId] (the actual mystery Pokemon) is skipped so the placeholder
/// never accidentally shows the real thing.
class PokemonMorphReveal extends StatefulWidget {
  const PokemonMorphReveal({
    super.key,
    required this.pokemonNames,
    required this.excludeId,
    this.size = 220,
  });

  final Map<int, String> pokemonNames;
  final int excludeId;
  final double size;

  @override
  State<PokemonMorphReveal> createState() => _PokemonMorphRevealState();
}

class _PokemonMorphRevealState extends State<PokemonMorphReveal> {
  late int _currentId = _pickRandomId();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 2600), (_) {
      setState(() => _currentId = _pickRandomId());
    });
  }

  int _pickRandomId() {
    final ids = widget.pokemonNames.keys.toList();
    if (ids.isEmpty) return widget.excludeId == 1 ? 4 : 1;

    var id = ids[Random().nextInt(ids.length)];
    if (id == widget.excludeId && ids.length > 1) {
      ids.remove(widget.excludeId);
      id = ids[Random().nextInt(ids.length)];
    }
    return id;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.pokemonNames[_currentId] ?? '';

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 900),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween(begin: 0.8, end: 1.0).animate(animation),
            child: child,
          ),
        ),
        child: Padding(
          key: ValueKey(_currentId),
          padding: const EdgeInsets.all(16),
          child: PokemonSpriteImage(
            pokemonId: _currentId,
            pokemonName: name,
            showLoadingIndicator: false,
          ),
        ),
      ),
    );
  }
}

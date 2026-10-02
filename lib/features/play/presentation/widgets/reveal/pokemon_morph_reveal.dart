import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:guessthegyarados/shared/presentation/widgets/pokemon_sprite_image.dart';

/// The real Pokemon a [PokemonMorphReveal] can settle on.
class MorphTarget {
  const MorphTarget(
      {required this.id, required this.name, this.isShiny = false});

  final int id;
  final String name;
  final bool isShiny;
}

/// Stands in for the mystery Pokemon before it's been named: cycles through
/// random, unrelated Pokemon sprites, crossfading and scaling between them
/// — a "morph" rather than a static placeholder — so there's always
/// something alive on screen without hinting at the real answer.
/// [excludeId] (the actual mystery Pokemon) is skipped so the placeholder
/// never accidentally shows the real thing.
///
/// Once [resolve] turns true the cycle stops and the very next swap lands on
/// [target], using the same crossfade/scale as every other swap — so giving up
/// on a round reveals the answer without a visible cut. While [target] is
/// set but not yet resolving, its sprite is loaded offstage so it's ready the
/// moment the swap happens.
class PokemonMorphReveal extends StatefulWidget {
  const PokemonMorphReveal({
    super.key,
    required this.pokemonNames,
    required this.excludeId,
    this.size = 220,
    this.target,
    this.resolve = false,
  });

  final Map<int, String> pokemonNames;
  final int excludeId;
  final double size;
  final MorphTarget? target;
  final bool resolve;

  @override
  State<PokemonMorphReveal> createState() => _PokemonMorphRevealState();
}

class _PokemonMorphRevealState extends State<PokemonMorphReveal> {
  late int _currentId = _pickRandomId();
  bool _showingTarget = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 2600), (_) {
      setState(() => _currentId = _pickRandomId());
    });
  }

  @override
  void didUpdateWidget(PokemonMorphReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = widget.target;
    if (widget.resolve && !oldWidget.resolve && target != null) {
      _timer?.cancel();
      setState(() {
        _showingTarget = true;
        _currentId = target.id;
      });
    }
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
    final target = widget.target;
    final name = _showingTarget && target != null
        ? target.name
        : widget.pokemonNames[_currentId] ?? '';

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (target != null && !_showingTarget)
            Offstage(
              child: PokemonSpriteImage(
                pokemonId: target.id,
                pokemonName: target.name,
                isShiny: target.isShiny,
                showLoadingIndicator: false,
              ),
            ),
          AnimatedSwitcher(
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
                isShiny: _showingTarget && (target?.isShiny ?? false),
                showLoadingIndicator: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

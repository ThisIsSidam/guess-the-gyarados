import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:guessthegyarados/core/constants/asset_paths.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/confetti_celebration.dart';

/// A single pokeball that shakes (rocking rotation, like the games) three
/// times, then either bursts into confetti (caught) or slumps and fades
/// (escaped) — replaces the old three-static-balls tally.
class PokeBallCatchAnimation extends StatefulWidget {
  final bool isCaught;

  const PokeBallCatchAnimation({super.key, required this.isCaught});

  @override
  State<PokeBallCatchAnimation> createState() => _PokeBallCatchAnimationState();
}

class _PokeBallCatchAnimationState extends State<PokeBallCatchAnimation> with TickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final ConfettiCelebrationController _confetti = ConfettiCelebrationController();
  int _shakeCount = 0;
  bool _resolved = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );
    _runShakes();
  }

  Future<void> _runShakes() async {
    for (var i = 0; i < 3; i++) {
      await _shakeController.forward(from: 0);
      setState(() => _shakeCount = i + 1);
      await Future.delayed(const Duration(milliseconds: 120));
    }

    setState(() {
      _resolved = true;
      _message = widget.isCaught ? 'Gotcha!' : 'Oh no! It broke free!';
    });

    if (widget.isCaught) _confetti.play();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                final wobble = sin(_shakeController.value * pi * 4) * (1 - _shakeController.value);
                return Transform(
                  alignment: Alignment.bottomCenter,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.002)
                    ..rotateZ(_resolved ? 0 : wobble * 0.35)
                    ..rotateY(_resolved ? 0 : wobble * 0.4),
                  child: child,
                );
              },
              child: !_resolved
                  ? Image.asset(pokeballIcon, width: 96, height: 96)
                  : widget.isCaught
                      ? Image.asset(pokeballIcon, width: 96, height: 96)
                          .animate()
                          .scaleXY(begin: 1, end: 1.3, duration: const Duration(milliseconds: 250))
                          .then()
                          .scaleXY(begin: 1.3, end: 1, duration: const Duration(milliseconds: 250))
                      : ColorFiltered(
                          colorFilter: const ColorFilter.mode(Colors.black54, BlendMode.srcATop),
                          child: Image.asset(pokeballIcon, width: 96, height: 96),
                        ).animate().shake(hz: 2, duration: const Duration(milliseconds: 400)),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final lit = index < _shakeCount;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: lit ? GameColors.gold : Colors.white24,
                      boxShadow: lit
                          ? [BoxShadow(color: GameColors.gold.withValues(alpha: 0.7), blurRadius: 8)]
                          : null,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _message,
                key: ValueKey(_message),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: widget.isCaught ? GameColors.gold : GameColors.danger,
                ),
              ),
            ),
          ],
        ),
        ConfettiCelebration(controller: _confetti),
      ],
    );
  }
}

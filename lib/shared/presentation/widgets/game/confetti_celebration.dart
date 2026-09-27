import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';

/// Fullscreen-overlaying confetti burst. Play it once via [ConfettiCelebrationController.play]
/// on a successful catch, a level-up, or a newly-received achievement.
class ConfettiCelebration extends StatefulWidget {
  const ConfettiCelebration({super.key, required this.controller});

  final ConfettiCelebrationController controller;

  @override
  State<ConfettiCelebration> createState() => _ConfettiCelebrationState();
}

class ConfettiCelebrationController {
  final _confettiController = ConfettiController(duration: const Duration(seconds: 1));

  void play() => _confettiController.play();

  void dispose() => _confettiController.dispose();
}

class _ConfettiCelebrationState extends State<ConfettiCelebration> {
  static const _colors = [
    GameColors.gold,
    GameColors.primary,
    GameColors.success,
    Colors.white,
  ];

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConfettiWidget(
          confettiController: widget.controller._confettiController,
          blastDirection: pi / 2,
          blastDirectionality: BlastDirectionality.explosive,
          numberOfParticles: 24,
          gravity: 0.3,
          colors: _colors,
        ),
      ),
    );
  }
}

import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:guessthegyarados/core/settings/haptics.dart';
import 'package:guessthegyarados/core/settings/reduced_motion.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';
import 'package:guessthegyarados/features/play/domain/models/round_outcome.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/confetti_celebration.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/outlined_text.dart';

// Timeline in milliseconds, same one-controller approach as the catch
// animation: every piece is a pure function of the time elapsed.
const _stampAt = 0.0; // "NEW!" slams down
const _pointsAt = 350.0; // "+250" floats up and counts
const _bonusAt = 1000.0; // bonus chips pop in one after another
const _chipGap = 260.0;
const _levelAt = 2000.0; // level-up banner + confetti
const _totalMs = 2800.0;

const _stageHalf = 110.0; // half the Pokemon sprite's height
const _groundY = 50.0; // where the ball rests, relative to center

/// The payoff after a round: a "NEW!" stamp on a first-time catch, the points
/// floating up (counting as they land), a perfect-round bonus chip, and a
/// level-up banner with confetti. Plays once when it appears and only draws
/// what the [outcome] earned. Must be given the full reveal area.
class RoundResultOverlay extends StatefulWidget {
  const RoundResultOverlay({super.key, required this.outcome});

  final RoundOutcome outcome;

  @override
  State<RoundResultOverlay> createState() => _RoundResultOverlayState();
}

class _RoundResultOverlayState extends State<RoundResultOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  );
  final _confetti = ConfettiCelebrationController();
  final _fired = <int>{};

  RoundOutcome get o => widget.outcome;

  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_haptics);
  }

  // Reduced motion shows the finished result at once instead of animating it.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (ReducedMotion.of(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _confetti.dispose();
    super.dispose();
  }

  double get _ms => _controller.value * _totalMs;

  void _haptics() {
    void once(int id, double at, VoidCallback fire) {
      if (_ms >= at && _fired.add(id)) fire();
    }

    if (o.isNewCatch) {
      once(0, _stampAt + 220, () => Haptics.medium());
    }
    for (var i = 0; i < _chips.length; i++) {
      once(10 + i, _bonusAt + i * _chipGap, () => Haptics.selection());
    }
    if (o.leveledUp) {
      once(2, _levelAt, () {
        Haptics.heavy();
        _confetti.play();
      });
    }
  }

  double _seg(double a, double b, [Curve curve = Curves.linear]) =>
      curve.transform(((_ms - a) / (b - a)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final center = constraints.maxHeight / 2;
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Stack(
              clipBehavior: Clip.none,
              children: [
                if (o.leveledUp) ConfettiCelebration(controller: _confetti),
                if (o.isNewCatch)
                  Positioned(
                    top: center + _groundY - 96,
                    left: 0,
                    right: 0,
                    child: Center(child: _stamp()),
                  ),
                Positioned(
                  // Just above the Pokemon: the space below it already holds
                  // the catch / "It was" message and the buttons.
                  bottom: constraints.maxHeight - (center - _stageHalf - 8),
                  left: 16,
                  right: 16,
                  child: _rewards(context),
                ),
                if (o.leveledUp)
                  Positioned(
                    top: 8,
                    left: 16,
                    right: 16,
                    child: _levelBanner(context),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Slams down from large with a little overshoot, tilted like a rubber stamp.
  Widget _stamp() {
    final u = _seg(_stampAt, _stampAt + 380, Curves.easeIn);
    final settle = _seg(_stampAt + 380, _stampAt + 620, Curves.elasticOut);
    final scale = u < 1 ? lerpDouble(2.6, 1.0, u)! : lerpDouble(1.12, 1.0, settle)!;
    return Opacity(
      opacity: _seg(_stampAt, _stampAt + 150),
      child: Transform.rotate(
        angle: -0.2,
        child: Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GameColors.danger, width: 4),
            ),
            child: const Text(
              'NEW!',
              style: TextStyle(
                fontSize: 32,
                height: 1.1,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: GameColors.danger,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // The bonus chips, in the order they pop in.
  List<_Chip> get _chips => [
        if (o.perfectBonus > 0)
          _Chip(Icons.star_rounded, 'PERFECT +${o.perfectBonus}',
              GameColors.gold, GameColors.goldDeep),
        if (o.streakBonus > 0)
          _Chip(
              Icons.local_fire_department_rounded,
              'STREAK x${o.multiplier.toStringAsFixed(1)} +${o.streakBonus}',
              const Color(0xFFFF8A3D),
              const Color(0xFFC25A12)),
        if (o.streakLost)
          const _Chip(Icons.heart_broken_rounded, 'STREAK LOST',
              GameColors.danger, Color(0xFFB83A48)),
        if (o.dailyBonusCoins > 0)
          _Chip(
              Icons.calendar_month_rounded,
              'DAILY STREAK ${o.dailyStreak} +${o.dailyBonusCoins}',
              GameColors.primaryDeep,
              GameColors.backgroundDeep),
        if (o.coins > 0)
          _Chip(Icons.monetization_on_rounded, '+${o.coins} coins',
              GameColors.gold, GameColors.goldDeep),
      ];

  Widget _rewards(BuildContext context) {
    final rise = _seg(_pointsAt, _pointsAt + 550, Curves.easeOutBack);
    final count = (o.totalPoints * _seg(_pointsAt, _pointsAt + 700, Curves.easeOut))
        .round();
    final chips = _chips;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: _seg(_pointsAt, _pointsAt + 250),
          child: Transform.translate(
            offset: Offset(0, (1 - rise) * 36),
            child: OutlinedText(
              '+$count pts',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontSize: 40),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            for (var i = 0; i < chips.length; i++)
              _chipView(chips[i],
                  _seg(_bonusAt + i * _chipGap, _bonusAt + i * _chipGap + 380,
                      Curves.easeOutBack)),
          ],
        ),
      ],
    );
  }

  Widget _chipView(_Chip chip, double pop) {
    return Opacity(
      opacity: pop.clamp(0.0, 1.0),
      child: Transform.scale(
        scale: pop,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: chip.shadow, offset: const Offset(0, 3))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(chip.icon, color: chip.color, size: 22),
              const SizedBox(width: 6),
              Text(
                chip.label,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: GameColors.textOnLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _levelBanner(BuildContext context) {
    final pop = _seg(_levelAt, _levelAt + 700, Curves.elasticOut);
    return Opacity(
      opacity: _seg(_levelAt, _levelAt + 150),
      child: Transform.scale(
        scale: pop,
        child: Column(
          children: [
            OutlinedText(
              'LEVEL UP!',
              fill: GameColors.primary,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontSize: 40),
            ),
            Text(
              'Level ${o.levelBefore}  →  ${o.levelAfter}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: GameColors.textOnLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip {
  const _Chip(this.icon, this.label, this.color, this.shadow);

  final IconData icon;
  final String label;
  final Color color;
  final Color shadow;
}

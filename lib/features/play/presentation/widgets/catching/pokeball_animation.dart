import 'dart:math';
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guessthegyarados/core/constants/asset_paths.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';
import 'package:guessthegyarados/features/play/presentation/widgets/catching/catch_stage_controller.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/outlined_text.dart';

// Timeline in milliseconds. Everything below is a pure function of the time
// elapsed, so the whole sequence is one controller and nothing can drift.
const _throwEnd = 800.0; // ball arcs in from the bottom of the screen
const _bounce1End = 1100.0; // ...bounces off the Pokemon's head
const _bounce2End = 1300.0; // ...a smaller second bounce
const _absorbEnd = 1750.0; // Pokemon is pulled into the ball
const _fallEnd = 2100.0; // ball drops to the ground
const _settleEnd = 2300.0; // ...and bounces once
const _wiggleStart = 2500.0;
const _wiggleLen = 500.0;
const _wiggleGap = 200.0;
const _resultAt = 4600.0; // 3 wiggles + gaps + a beat of suspense
const _totalMs = 5800.0;

const _ballSize = 72.0;
const _stageHalf = 110.0; // half the Pokemon sprite's height
const _landY = -64.0; // ball resting on the Pokemon's head (relative to center)
const _groundY = 50.0; // ball on the ground

double _seg(double ms, double a, double b, [Curve curve = Curves.linear]) =>
    curve.transform(((ms - a) / (b - a)).clamp(0.0, 1.0));

// A parabolic hop of [height] over [a, b]; zero outside it.
double _hop(double ms, double a, double b, double height) {
  final s = _seg(ms, a, b);
  return 4 * s * (1 - s) * height;
}

Offset _bezier(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
  final u = 1 - t;
  return p0 * (u * u * u) +
      p1 * (3 * u * u * t) +
      p2 * (3 * u * t * t) +
      p3 * (t * t * t);
}

/// The full catch sequence, drawn over the (centered) Pokemon: a ball is
/// thrown from the bottom of the screen in a wide arc, lands on the Pokemon,
/// bounces, sucks it in, drops, wiggles three times, then either pops open
/// in a burst of stars (caught) or breaks apart and releases the Pokemon.
///
/// The Pokemon's own shrink/flash is applied by the page through [stage].
/// Must be given the full reveal area (it centers on it and paints outside
/// its bounds on purpose).
class PokeBallCatchAnimation extends StatefulWidget {
  final bool isCaught;
  final String pokemonName;
  final bool isShiny;
  final CatchStageController stage;
  final VoidCallback? onFinished;

  const PokeBallCatchAnimation({
    super.key,
    required this.isCaught,
    required this.pokemonName,
    required this.stage,
    this.isShiny = false,
    this.onFinished,
  });

  @override
  State<PokeBallCatchAnimation> createState() => _PokeBallCatchAnimationState();
}

class _PokeBallCatchAnimationState extends State<PokeBallCatchAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 5800),
  );
  final _fired = <int>{};

  @override
  void initState() {
    super.initState();
    _controller.addListener(_tick);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onFinished?.call();
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _ms => _controller.value * _totalMs;

  void _tick() {
    final ms = _ms;

    var absorb = _seg(ms, _bounce2End, _absorbEnd, Curves.easeIn);
    var anchorY = _landY / _stageHalf;
    if (!widget.isCaught && ms >= _resultAt) {
      // Broke free: it springs back out from where the ball was.
      absorb = 1 - _seg(ms, _resultAt, _resultAt + 600, Curves.easeOut);
      anchorY = _groundY / _stageHalf;
    }
    widget.stage.update(absorb: absorb, anchorY: anchorY);

    _haptics(ms);
  }

  void _haptics(double ms) {
    void once(int id, double at, VoidCallback fire) {
      if (ms >= at && _fired.add(id)) fire();
    }

    once(0, _throwEnd, () => HapticFeedback.lightImpact());
    for (var k = 0; k < 3; k++) {
      once(1 + k, _wiggleStart + k * (_wiggleLen + _wiggleGap),
          () => HapticFeedback.selectionClick());
    }
    once(10, _resultAt, () {
      if (widget.isCaught) {
        HapticFeedback.lightImpact();
      } else {
        HapticFeedback.heavyImpact();
        Future.delayed(
            const Duration(milliseconds: 90), HapticFeedback.heavyImpact);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final start = Offset(0, constraints.maxHeight / 2 + _ballSize);
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => _scene(context, constraints, start, _ms),
        );
      },
    );
  }

  Widget _scene(
      BuildContext context, BoxConstraints constraints, Offset start, double ms) {
    var pos = const Offset(0, _landY);
    var scale = 0.85;
    var angle = 0.0;

    if (ms < _throwEnd) {
      final u = _seg(ms, 0, _throwEnd, Curves.easeInOutSine);
      pos = _bezier(
        start,
        Offset(-190, start.dy * 0.1),
        Offset(150, -start.dy * 0.55),
        const Offset(0, _landY),
        u,
      );
      scale = lerpDouble(1.3, 0.85, u)!;
      angle = u * 4 * pi;
    } else if (ms < _bounce2End) {
      pos = Offset(
        0,
        _landY -
            _hop(ms, _throwEnd, _bounce1End, 56) -
            _hop(ms, _bounce1End, _bounce2End, 22),
      );
    } else if (ms < _absorbEnd) {
      scale = 0.85 + 0.15 * sin(pi * _seg(ms, _bounce2End, _absorbEnd));
    } else {
      final fall = _seg(ms, _absorbEnd, _fallEnd, Curves.easeIn);
      pos = Offset(
        0,
        lerpDouble(_landY, _groundY, fall)! -
            _hop(ms, _fallEnd, _settleEnd, 22),
      );
    }

    // Wiggles: a rock left-right-center around the ball's base, three times.
    const period = _wiggleLen + _wiggleGap;
    var lit = 0;
    if (ms >= _wiggleStart) {
      final local = ms - _wiggleStart;
      final k = (local / period).floor();
      final within = local - k * period;
      if (k < 3 && within < _wiggleLen) {
        angle = sin(within / _wiggleLen * 2 * pi) * 0.5;
      }
      for (var i = 0; i < 3; i++) {
        if (local >= i * period + _wiggleLen) lit = i + 1;
      }
    }

    final resolved = ms >= _resultAt;
    final broken = resolved && !widget.isCaught;
    if (resolved && widget.isCaught) {
      scale = 0.85 + 0.2 * sin(pi * _seg(ms, _resultAt, _resultAt + 350));
    }

    final ball = Transform.translate(
      offset: pos,
      child: Transform.scale(
        scale: scale,
        child: Transform.rotate(
          angle: angle,
          alignment: ms >= _wiggleStart
              ? Alignment.bottomCenter
              : Alignment.center,
          child: Image.asset(pokeballIcon, width: _ballSize, height: _ballSize),
        ),
      ),
    );

    final name = widget.pokemonName.isEmpty
        ? ''
        : '${widget.pokemonName[0].toUpperCase()}${widget.pokemonName.substring(1).toLowerCase()}';
    final headline = widget.isCaught ? 'Gotcha!' : 'Oh no!';
    final subline = widget.isCaught
        ? (widget.isShiny
            ? 'A shiny $name was caught!'
            : '$name was caught!')
        : '$name broke free!';

    return IgnorePointer(
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (broken)
            Transform.translate(
              offset: const Offset(0, _groundY),
              child: _BrokenBall(progress: _seg(ms, _resultAt, _resultAt + 700)),
            )
          else
            ball,
          if (resolved && widget.isCaught)
            Transform.translate(
              offset: const Offset(0, _groundY),
              child: _StarBurst(progress: _seg(ms, _resultAt, _resultAt + 1000)),
            ),
          if (ms >= _fallEnd && !resolved)
            Transform.translate(
              offset: Offset(0, _groundY + _ballSize / 2 + 16),
              child: _WiggleDots(lit: lit),
            ),
          Positioned(
            top: constraints.maxHeight / 2 + _stageHalf + 28,
            left: 16,
            right: 16,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: ms >= _resultAt + 150 ? 1 : 0,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                offset: ms >= _resultAt + 150
                    ? Offset.zero
                    : const Offset(0, 0.3),
                child: Column(
                  children: [
                    OutlinedText(
                      headline,
                      fill: widget.isCaught ? GameColors.gold : GameColors.danger,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(fontSize: 38),
                    ),
                    Text(
                      subline,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: GameColors.textOnLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One dot per completed wiggle, lighting up as the ball settles.
class _WiggleDots extends StatelessWidget {
  const _WiggleDots({required this.lit});

  final int lit;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final on = i < lit;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: on ? GameColors.gold : Colors.white,
            border: Border.all(
              color: on ? GameColors.goldDeep : const Color(0xFFC9CEDB),
              width: 2,
            ),
          ),
        );
      }),
    );
  }
}

class _HalfClipper extends CustomClipper<Rect> {
  const _HalfClipper({required this.top});

  final bool top;

  @override
  Rect getClip(Size size) => top
      ? Rect.fromLTWH(0, 0, size.width, size.height / 2)
      : Rect.fromLTWH(0, size.height / 2, size.width, size.height / 2);

  @override
  bool shouldReclip(covariant _HalfClipper oldClipper) => oldClipper.top != top;
}

/// The ball splitting in two and tumbling away, with a ring flashing out.
class _BrokenBall extends StatelessWidget {
  const _BrokenBall({required this.progress});

  final double progress;

  Widget _half(bool top) {
    final p = progress;
    final dir = top ? -1.0 : 1.0;
    final dx = dir * 50 * p;
    final dy = top ? -60 * p + 110 * p * p : 10 * p + 130 * p * p;
    final fade = 1 - ((p - 0.5) / 0.5).clamp(0.0, 1.0);

    return Transform.translate(
      offset: Offset(dx, dy),
      child: Transform.rotate(
        angle: dir * 0.9 * p,
        child: Opacity(
          opacity: fade,
          child: ClipRect(
            clipper: _HalfClipper(top: top),
            child:
                Image.asset(pokeballIcon, width: _ballSize, height: _ballSize),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ringScale = 0.6 + 1.6 * Curves.easeOut.transform(progress);
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Opacity(
          opacity: (1 - progress * 1.4).clamp(0.0, 1.0),
          child: Transform.scale(
            scale: ringScale,
            child: Container(
              width: _ballSize,
              height: _ballSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: GameColors.danger, width: 4),
              ),
            ),
          ),
        ),
        _half(true),
        _half(false),
      ],
    );
  }
}

/// Eight stars popping outward from the ball and fading as they drift.
class _StarBurst extends StatelessWidget {
  const _StarBurst({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final p = progress;
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        for (var i = 0; i < 8; i++)
          Builder(builder: (context) {
            final big = i.isEven;
            final angle = i * pi / 4 - pi / 2;
            final radius = (big ? 120.0 : 85.0) * Curves.easeOutCubic.transform(p);
            final pop = p < 0.35
                ? Curves.easeOutBack.transform(p / 0.35)
                : 1 - (p - 0.35) / 0.65 * 0.4;
            final opacity = p < 0.6 ? 1.0 : 1 - (p - 0.6) / 0.4;
            final size = big ? 38.0 : 28.0;

            return Transform.translate(
              offset: Offset(cos(angle) * radius, sin(angle) * radius),
              child: Transform.rotate(
                angle: p * pi * (big ? 1 : -1),
                child: Transform.scale(
                  scale: pop * (big ? 1 : 0.85),
                  child: Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.star_rounded,
                            size: size + 8, color: GameColors.goldDeep),
                        Icon(Icons.star_rounded,
                            size: size, color: GameColors.gold),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}

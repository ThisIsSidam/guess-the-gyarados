import 'dart:async';
import 'package:flutter/material.dart';
import 'package:guessthegyarados/consts/strings.dart';

class PokeBallCatchAnimation extends StatefulWidget {
  final bool isCaught;

  const PokeBallCatchAnimation({super.key, required this.isCaught});

  @override
  State<PokeBallCatchAnimation> createState() => _PokeBallCatchAnimationState();
}

class _PokeBallCatchAnimationState extends State<PokeBallCatchAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final List<bool> _ballsColored = [true, false, false]; // First ball is initially colored
  String _catchMessage = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..forward();

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _startCatchAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startCatchAnimation() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timer.tick < 3) {
        setState(() {
          _ballsColored[timer.tick] = true;
        });
      } else {
        timer.cancel();
        if (widget.isCaught) {
          setState(() {
            _catchMessage = 'Catch successful!';
          });
        } else {
          setState(() {
            _ballsColored.fillRange(0, 3, false);
            _catchMessage = 'Catch failed!';
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildBall(0),
                const SizedBox(width: 16),
                _buildBall(1),
                const SizedBox(width: 16),
                _buildBall(2),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          _catchMessage,
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildBall(int index) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: _ballsColored[index]
          ? widget.isCaught
              ? Image.asset(pokeballIcon, width: 48, height: 48, key: UniqueKey())
              : Image.asset(pokeballIcon, width: 32, height: 32, key: UniqueKey())
          : ColorFiltered(
              colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcATop),
              child: Image.asset(pokeballIcon, width: 32, height: 32, key: UniqueKey()),
            ),
    );
  }
}
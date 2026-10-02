import 'dart:async';
import 'package:flutter/material.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/folded_backdrop.dart';

class HoveringImageLoadingScreen extends StatefulWidget {
  final Image image;
  final String text;
  final int maxDotCount;

  /// When set, the screen sits on a [FoldedBackdrop] tinted with this color
  /// (and its text switches to dark) instead of the plain scaffold color.
  final Color? accentColor;
  const HoveringImageLoadingScreen({
    super.key,
    required this.image,
    required this.text,
    this.maxDotCount = 3,
    this.accentColor,
  });

  @override
  State<HoveringImageLoadingScreen> createState() => _HoveringImageLoadingScreenState();
}

class _HoveringImageLoadingScreenState extends State<HoveringImageLoadingScreen> {
  int dotCount = 0;
  String dots = '.';
  bool timerIsActive = true;

  @override
void initState() {
  super.initState();
  startTimer();
}

void startTimer() {
  const Duration interval = Duration(seconds: 1);
  Timer.periodic(interval, (timer) {
    if (timerIsActive)
    {
      setState(() {
        dotCount = dotCount > widget.maxDotCount ? 0 : dotCount+1;
      });
    }
    else
    {
      timer.cancel();
    }
  });
}

@override
void dispose() {
  timerIsActive = false;
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor;
    final content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.image,
          const SizedBox(height: 16),
          Text(
            "${widget.text}${dots*dotCount}",
            key: Key(dotCount.toString()),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: accent == null ? null : GameColors.textOnLight,
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      body: accent == null
          ? content
          : FoldedBackdrop(accentColor: accent, child: content),
    );
  }
}

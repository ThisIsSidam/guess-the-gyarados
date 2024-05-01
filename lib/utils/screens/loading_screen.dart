import 'dart:async';
import 'package:flutter/material.dart';

class HoveringImageLoadingScreen extends StatefulWidget {
  final Image image;
  final String text;
  final int maxDotCount;
  const HoveringImageLoadingScreen({
    super.key,
    required this.image,
    required this.text,
    this.maxDotCount = 3
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
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.image,
            const SizedBox(height: 16),
            Text(
              "${widget.text}${dots*dotCount}",
              key: Key(dotCount.toString()),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
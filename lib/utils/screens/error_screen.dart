import 'dart:math';
import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget{

  final Image image;
  final String? errorText;
  ErrorScreen({
    super.key,
    required this.image,
    this.errorText,
  });

  final errorStrings = [
    "Even I, God himself, don't know what happened",
    "I swear to myself, I don't know what happened",
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            image,
            const SizedBox(height: 16),
            Text(
              softWrap: true,
              errorText ?? errorStrings[Random().nextInt(errorStrings.length)],
              style: Theme.of(context).textTheme.bodySmall
            ),
          ],
        ),
      ),
    );
  }
}
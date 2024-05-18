import 'package:flutter/material.dart';
import 'package:guessthegyarados/consts/asset_paths.dart';

class MessageOfGod extends StatelessWidget {
  final String message;
  const MessageOfGod({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            arceusImagePath,
            height: 200,
            width: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            softWrap: true,
            message,
            style: Theme.of(context).textTheme.bodySmall
          ),
        ],
      ),
    );
  }
}
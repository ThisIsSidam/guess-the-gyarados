import 'package:flutter/material.dart';
import 'package:guessthegyarados/core/constants/asset_paths.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              softWrap: true,
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: GameColors.textOnLight,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

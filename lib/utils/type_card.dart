import 'package:flutter/material.dart';
import 'package:guessthegyarados/utils/misc_methods.dart';

class TypeCard extends StatelessWidget {
  final String type;

  const TypeCard({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: getColorFromString(type),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text(
            type.toUpperCase(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
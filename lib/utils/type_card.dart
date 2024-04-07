import 'package:flutter/material.dart';
import 'package:guessthegyarados/theme/theme.dart';

class TypeCard extends StatelessWidget {
  final String type;

  const TypeCard({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: getTypeColor(type),
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

  Color getTypeColor(String type) {
    switch (type) {
      case 'normal':
        return Colors.brown[400]!;
      case 'fighting':
        return Colors.red[800]!;
      case 'flying':
        return Colors.indigo[300]!;
      case 'poison':
        return Colors.purple[600]!;
      case 'ground':
        return Colors.brown[800]!;
      case 'rock':
        return Colors.grey[800]!;
      case 'bug':
        return Colors.green[600]!;
      case 'ghost':
        return Colors.indigo[900]!;
      case 'steel':
        return Colors.grey[600]!;
      case 'fire':
        return Colors.orange[800]!;
      case 'water':
        return Colors.blue[600]!;
      case 'grass':
        return Colors.green[800]!;
      case 'electric':
        return Colors.yellow[800]!;
      case 'psychic':
        return Colors.pink[400]!;
      case 'ice':
        return Colors.cyan[600]!;
      case 'dragon':
        return Colors.indigo[800]!;
      case 'dark':
        return Colors.brown[900]!;
      case 'fairy':
        return Colors.pink[200]!;
      default:
        return neutralPill;
    }
  }
}
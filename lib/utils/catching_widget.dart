import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:guessthegyarados/database/pokemon_db.dart';
import 'package:guessthegyarados/pokemon_class/pokemon.dart';

class CatchingWidget extends StatefulWidget {
  final int steps;
  final Pokemon pokemon;

  const CatchingWidget({
    super.key,
    required this.steps,
    required this.pokemon,
  });

  @override
  State<CatchingWidget> createState() => _CatchingWidgetState();
}

class _CatchingWidgetState extends State<CatchingWidget> {
  bool caught = false;
  Future<void>? _catchingFuture;

  @override
  void initState() {
    super.initState();
    _startCatching();
  }

  void _startCatching() {
    _catchingFuture = _simulateCatching();
  }

  Future<void> _simulateCatching() async {
    final duration = Duration(seconds: Random().nextInt(3) + 3);
    await Future.delayed(duration);
    final successRate = 100 - widget.steps;
    final random = Random().nextInt(100);
    setState(() {
      caught = random < successRate;
    });

    if (caught)
    {
      successfullyCaught();
    }
  }


  /// Adds caught pokemon id to database
  void successfullyCaught() {
    PokemonDB.updateData(widget.pokemon.id);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<void>(
        future: _catchingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16.0),
                Text('Wait, Catching the ${widget.pokemon.name}'),
              ],
            );
          } else {
            return Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: caught ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                caught
                    ? 'Excellent, you caught ${widget.pokemon.name}!'
                    : 'Oops, ${widget.pokemon.name} ran away.',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
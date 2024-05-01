import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:guessthegyarados/database/pokemon_db.dart';
import 'package:guessthegyarados/pokemon_class/pokemon.dart';

class CatchingWidget extends StatefulWidget {
  final int steps;
  final Pokemon pokemon;
  final bool isShiny;
  const CatchingWidget({
    super.key,
    required this.steps,
    required this.pokemon,
    required this.isShiny
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

    final catchRate = getSuccessRate();

    final random = Random().nextInt(100);
    setState(() {
      caught = random < catchRate;
    });

    if (caught)
    {
      successfullyCaught();
    }
  }

  double getSuccessRate() {
    double successRate = 100 - (widget.steps * 0.5);
    if (widget.pokemon.isLegendary || widget.pokemon.isMythical) successRate /= 2;

    switch(widget.pokemon.stageOfEvolution)
    {
      case 2 : successRate - 5; break;
      case 3 : successRate - 10; break;
    }

    if (widget.pokemon.name.toLowerCase() == "arceus") successRate = 1;


    debugPrint("success rate: $successRate");
    return successRate;
  }


  /// Adds caught pokemon id to database
  void successfullyCaught() {
    CaughtPokemonDB.updateData(widget.pokemon.id, widget.isShiny);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
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
              return Text(
                caught
                ? 'Excellent, you caught a ${widget.isShiny ? "Shiny " : ''}${widget.pokemon.name}!'
                : 'Oops, ${widget.isShiny ? "Shiny " : ''}${widget.pokemon.name} ran away.',
                softWrap: true,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
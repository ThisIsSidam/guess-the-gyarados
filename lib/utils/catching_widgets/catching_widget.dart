import 'dart:math';
import 'package:flutter/material.dart';
import 'package:guessthegyarados/database/pokemon_db.dart';
import 'package:guessthegyarados/pokemon_class/pokemon.dart';
import 'package:guessthegyarados/utils/catching_widgets/pokeball_animation.dart';

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

  @override
  void initState() {
    super.initState();

    final catchRate = getSuccessRate();

    final random = Random().nextInt(100);
    setState(() {
      caught = random < catchRate;
    });

    caught = false;
    if (caught)
    {
      successfullyCaught();
    }
    else 
    {
      CaughtPokemonDB.updateData(
        widget.pokemon.id, 
        PokemonUpdateType.catchFailed
      );
    }
  }

  double getSuccessRate() {
    double successRate = 100 - (widget.steps * 0.5);
    if (widget.pokemon.isLegendary || widget.pokemon.isMythical) successRate /= 2;

    switch(widget.pokemon.stageOfEvolution)
    {
      case 2 : successRate = successRate - 5; break;
      case 3 : successRate = successRate - 10; break;
    }

    if (widget.pokemon.name.toLowerCase() == "arceus") successRate = 1;

    debugPrint("success rate: $successRate");
    return successRate;
  }


  /// Adds caught pokemon id to database
  void successfullyCaught() {
    CaughtPokemonDB.updateData(
      widget.pokemon.id, 
      widget.isShiny 
      ? PokemonUpdateType.caughtShiny 
      : PokemonUpdateType.caughtNormal
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: PokeBallCatchAnimation(isCaught: caught,),
      ),
    );
  }
}
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:guessthegyarados/database/user_pokemon_db.dart';
import 'package:guessthegyarados/database/user_data.dart';
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

    // caught = false;
    if (caught)
    {
      successfullyCaught();

      final int? firstCatch = UserDB.getData(UserDetails.firstCatch);
      if (firstCatch == null)
      {
        UserDB.updateData(UserDetails.firstCatch, widget.pokemon.id);
        UserDB.updateData(UserDetails.userColorString, widget.pokemon.types.first);
      }
    }
    else 
    {
      UserPokemonDB.updateData(
        widget.pokemon.id, 
        PokemonInteractionType.catchFailed
      );
      UserDB.addPoints((widget.pokemon.bst * 0.5).toInt());
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
    UserPokemonDB.updateData(
      widget.pokemon.id, 
      widget.isShiny 
      ? PokemonInteractionType.caughtShiny 
      : PokemonInteractionType.caughtNormal
    );

    UserDB.addPoints((widget.isShiny ? widget.pokemon.bst * 2 : widget.pokemon.bst));
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
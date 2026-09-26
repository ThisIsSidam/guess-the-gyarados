import 'dart:math';
import 'package:flutter/material.dart';
import 'package:guessthegyarados/core/di/injection.dart';
import 'package:guessthegyarados/data/local/entities/pokemon_entity.dart';
import 'package:guessthegyarados/data/local/entities/pokemon_interaction_entity.dart';
import 'package:guessthegyarados/data/repositories/user_pokemon_repository.dart';
import 'package:guessthegyarados/data/repositories/user_profile_repository.dart';
import 'package:guessthegyarados/presentation/widgets/catching/pokeball_animation.dart';

class CatchingWidget extends StatefulWidget {
  final int steps;
  final PokemonEntity pokemon;
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

    final userPokemonRepository = getIt<UserPokemonRepository>();
    final userProfileRepository = getIt<UserProfileRepository>();

    if (caught)
    {
      successfullyCaught(userPokemonRepository, userProfileRepository);
      userProfileRepository.recordFirstCatch(
        widget.pokemon.id,
        widget.pokemon.types.first,
      );
    }
    else
    {
      userPokemonRepository.recordInteraction(
        widget.pokemon.id,
        PokemonInteractionType.catchFailed,
      );
      userProfileRepository.addPoints((widget.pokemon.bst * 0.5).toInt());
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

  /// Records the catch and awards points.
  void successfullyCaught(
    UserPokemonRepository userPokemonRepository,
    UserProfileRepository userProfileRepository,
  ) {
    userPokemonRepository.recordInteraction(
      widget.pokemon.id,
      widget.isShiny
      ? PokemonInteractionType.caughtShiny
      : PokemonInteractionType.caughtNormal
    );

    userProfileRepository.addPoints((widget.isShiny ? widget.pokemon.bst * 2 : widget.pokemon.bst));
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

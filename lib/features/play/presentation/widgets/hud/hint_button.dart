import 'package:flutter/material.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/tap_bounce.dart';

/// Opens the hint shop; shows the coin balance so the price of a hint is
/// always weighed against what you have.
class HintButton extends StatelessWidget {
  const HintButton({super.key, required this.coins, required this.onTap});

  final int coins;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TapBounce(
      onTap: onTap,
      semanticLabel: 'Hints, $coins coins',
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(color: Color(0x33000000), offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lightbulb_rounded,
                color: GameColors.goldDeep, size: 26),
            const SizedBox(width: 6),
            const Icon(Icons.monetization_on_rounded,
                color: GameColors.gold, size: 20),
            const SizedBox(width: 3),
            Text(
              '$coins',
              style: const TextStyle(
                fontSize: 18,
                height: 1,
                fontWeight: FontWeight.w800,
                color: GameColors.textOnLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

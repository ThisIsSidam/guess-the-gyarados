import 'package:flutter/material.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/game_button.dart';

/// Replaces the AppBar on sub-pages: a plain row laid straight onto the
/// backdrop — a round back button, a title ribbon, and an optional trailing
/// widget — with no Material surface or shadow behind it.
class GamePageHeader extends StatelessWidget {
  const GamePageHeader({
    super.key,
    required this.title,
    this.trailing,
    this.backIcon = Icons.arrow_back,
  });

  final String title;
  final Widget? trailing;
  final IconData backIcon;

  static const _slot = 52.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          GameIconBadge(
            semanticLabel: 'Back',
            onPressed: () => Navigator.maybePop(context),
            child: Icon(backIcon, color: GameColors.textOnLight),
          ),
          Expanded(child: Center(child: _TitleRibbon(title))),
          SizedBox(width: _slot, child: trailing),
        ],
      ),
    );
  }
}

class _TitleRibbon extends StatelessWidget {
  const _TitleRibbon(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
      decoration: BoxDecoration(
        color: GameColors.backgroundDeep,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color.lerp(GameColors.backgroundDeep, Colors.black, 0.4)!,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // Long titles (ACHIEVEMENTS) scale down rather than overflow the slot
      // between the back button and the trailing widget.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 22,
                letterSpacing: 2,
                color: GameColors.textOnDark,
              ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';
import 'package:guessthegyarados/features/play/domain/models/hint.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/shake.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/tap_bounce.dart';

/// The hint shop: one row per [Hint] with its price. [onBuy] spends the coins
/// and returns the new balance, or null if they couldn't be spent. A bought
/// hint closes the sheet so the player sees it at once.
Future<void> showHintSheet({
  required BuildContext context,
  required int coins,
  required Set<Hint> bought,
  required int? Function(Hint hint) onBuy,
}) {
  return showModalBottomSheet(
    context: context,
    // Without this the sheet is capped at 9/16 of the screen and the rows
    // overflow on short screens.
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _HintSheet(
      coins: coins,
      bought: bought,
      onBuy: (hint) {
        final balance = onBuy(hint);
        if (balance != null && sheetContext.mounted) {
          Navigator.pop(sheetContext);
        }
        return balance;
      },
    ),
  );
}

class _HintSheet extends StatefulWidget {
  const _HintSheet({
    required this.coins,
    required this.bought,
    required this.onBuy,
  });

  final int coins;
  final Set<Hint> bought;
  final int? Function(Hint hint) onBuy;

  @override
  State<_HintSheet> createState() => _HintSheetState();
}

class _HintSheetState extends State<_HintSheet> {
  int _refused = 0;

  void _tap(Hint hint) {
    if (widget.bought.contains(hint)) return;
    if (widget.coins < hint.cost || widget.onBuy(hint) == null) {
      // Can't afford it: the balance shakes instead of the row silently
      // doing nothing.
      setState(() => _refused++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: GameColors.surfaceRaised,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Hints',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: GameColors.textOnLight,
                    ),
                  ),
                ),
                Shake(
                  trigger: _refused,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monetization_on_rounded,
                          color: GameColors.gold, size: 24),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.coins} coins',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: GameColors.textOnLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(24),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(Icons.close,
                        color: GameColors.textMuted, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (final hint in Hint.values)
                      _HintRow(
                        hint: hint,
                        owned: widget.bought.contains(hint),
                        affordable: widget.coins >= hint.cost,
                        onTap: () => _tap(hint),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HintRow extends StatelessWidget {
  const _HintRow({
    required this.hint,
    required this.owned,
    required this.affordable,
    required this.onTap,
  });

  final Hint hint;
  final bool owned;
  final bool affordable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: TapBounce(
        onTap: owned ? null : onTap,
        pressedScale: 0.97,
        semanticLabel:
            '${hint.label}, ${owned ? 'unlocked' : '${hint.cost} coins'}',
        child: Opacity(
          opacity: owned || affordable ? 1 : 0.55,
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: GameColors.primaryDeep, offset: Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Icon(hint.icon, size: 30, color: GameColors.backgroundDeep),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hint.label,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: GameColors.textOnLight,
                        ),
                      ),
                      Text(
                        hint.description,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: GameColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (owned)
                  const Icon(Icons.check_circle_rounded,
                      color: GameColors.success, size: 28)
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monetization_on_rounded,
                          color: GameColors.gold, size: 22),
                      const SizedBox(width: 3),
                      Text(
                        '${hint.cost}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: GameColors.textOnLight,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

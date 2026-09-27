import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guessthegyarados/core/extensions/string_extensions.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';
import 'package:guessthegyarados/core/theme/pokemon_type_colors.dart';
import 'package:guessthegyarados/features/play/domain/models/clue.dart';

/// A single clue rendered as a compact pill for the info row above the
/// clue carousel. Unrevealed: icon + label, dim. Revealed: icon + the
/// actual value, colored when the clue is a Pokemon type.
class ClueRowChip extends StatelessWidget {
  const ClueRowChip({super.key, required this.clue, required this.revealed, this.onTap});

  final ClueSpec clue;
  final bool revealed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = revealed && clue.coloredOptions ? getColorFromString(clue.answer) : GameColors.surfaceRaised;

    return InkWell(
      onTap: revealed ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            typeIcon(revealed),
            const SizedBox(width: 8),
            Text(
              revealed ? clue.answer.capitalize : clue.label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: revealed ? GameColors.textOnDark : GameColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget typeIcon(bool revealed) {
    final iconColor = revealed ? GameColors.textOnDark : GameColors.textMuted;
    if (revealed && clue.coloredOptions) {
      final path = getIconPathForType(clue.answer);
      if (path != null) {
        return SvgPicture.asset(
          path,
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        );
      }
    }
    return Icon(clue.icon, size: 20, color: iconColor);
  }
}

/// A single clue rendered as a list row inside a carousel card. Boolean
/// clues reveal instantly on tap; choice clues open an answer sheet via
/// [onTap] instead.
class ClueCardRow extends StatelessWidget {
  const ClueCardRow({
    super.key,
    required this.clue,
    required this.revealed,
    this.accentColor = GameColors.primary,
    this.onTap,
  });

  final ClueSpec clue;
  final bool revealed;
  final Color accentColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isYesNo = clue.answer == "Yes" || clue.answer == "No";
    final badgeColor = !isYesNo
        ? accentColor
        : clue.answer == "Yes"
            ? GameColors.success
            : GameColors.danger;

    return InkWell(
      onTap: revealed ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Icon(clue.icon, size: 20, color: accentColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                clue.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: GameColors.textOnLight),
              ),
            ),
            if (revealed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  clue.answer.capitalize,
                  style: TextStyle(fontWeight: FontWeight.w700, color: badgeColor),
                ),
              )
            else
              const Icon(Icons.help_outline, size: 18, color: GameColors.textMuted),
          ],
        ),
      ),
    );
  }
}

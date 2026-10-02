import 'package:flutter/material.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';

/// Text with a solid outline and a hard drop shadow, so a colored title stays
/// legible on any backdrop (HUD-text rule: contrasting outline, never bare).
class OutlinedText extends StatelessWidget {
  const OutlinedText(
    this.text, {
    super.key,
    required this.style,
    this.fill = GameColors.gold,
    this.outline = GameColors.backgroundDeep,
    this.outlineWidth = 6,
    this.shadowOffset = 4,
    this.textAlign = TextAlign.center,
  });

  final String text;
  final TextStyle style;
  final Color fill;
  final Color outline;
  final double outlineWidth;
  final double shadowOffset;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final strokeStyle = style.copyWith(
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = outlineWidth
        ..strokeJoin = StrokeJoin.round
        ..color = outline,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: Offset(0, shadowOffset),
          child: Text(
            text,
            textAlign: textAlign,
            style: strokeStyle.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = outlineWidth
                ..strokeJoin = StrokeJoin.round
                ..color = Color.lerp(outline, Colors.black, 0.35)!,
            ),
          ),
        ),
        Text(text, textAlign: textAlign, style: strokeStyle),
        Text(text, textAlign: textAlign, style: style.copyWith(color: fill)),
      ],
    );
  }
}

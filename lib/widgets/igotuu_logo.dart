import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

/// App Logo widget rendering "igotuu" in the bold Pacifico script font.
/// Rendered with native crisp anti-aliasing to prevent glyph descender clipping.
class IgotuuLogo extends StatelessWidget {
  final double fontSize;
  final Color? color;
  final bool enableHero;
  final String heroTag;

  const IgotuuLogo({
    super.key,
    this.fontSize = 30,
    this.color,
    this.enableHero = true,
    this.heroTag = 'igotuu_logo_hero',
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? AppColors.sageDark;

    final textWidget = Text(
      'igotuu',
      style: AppTypography.logoScript(
        fontSize: fontSize,
        color: textColor,
      ),
    );

    if (enableHero) {
      return Hero(
        tag: heroTag,
        flightShuttleBuilder: (flightContext, animation, flightDirection,
            fromHeroContext, toHeroContext) {
          return Material(
            color: Colors.transparent,
            child: textWidget,
          );
        },
        child: Material(
          color: Colors.transparent,
          child: textWidget,
        ),
      );
    }

    return textWidget;
  }
}

import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

/// App Logo widget rendering "igotuu" or "igu" in the bold script font.
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
    final textWidget = ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [
            color ?? AppColors.sageDark,
            (color ?? AppColors.sageDark).withValues(alpha: 0.92),
            AppColors.sage,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      child: Text(
        'igotuu',
        style: AppTypography.logoScript(
          fontSize: fontSize,
          color: Colors.white, // Masked by shader
        ),
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

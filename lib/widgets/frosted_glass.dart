import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Reusable Glassmorphism Widget
/// Built strictly to spec:
/// - ClipRRect + BackdropFilter with ImageFilter.blur(sigma ~18)
/// - White fill at 25-40% opacity
/// - 1px white border at ~50% opacity
/// - Soft shadow, radius 20-28
class FrostedGlass extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double blurSigma;
  final Color? fillColor;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;
  final String? semanticLabel;

  const FrostedGlass({
    super.key,
    required this.child,
    this.borderRadius = 24.0,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.blurSigma = 18.0,
    this.fillColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.shadows,
    this.onTap,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveFillColor = fillColor ?? Colors.white.withValues(alpha: 0.35);
    final effectiveBorderColor = borderColor ?? Colors.white.withValues(alpha: 0.55);

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveFillColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: effectiveBorderColor,
          width: borderWidth,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: AppColors.sage.withValues(alpha: 0.15),
          highlightColor: Colors.white.withValues(alpha: 0.2),
          child: content,
        ),
      );
    }

    Widget glassContainer = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows ??
            [
              const BoxShadow(
                color: Color(0x1026332A),
                blurRadius: 22,
                spreadRadius: 0,
                offset: Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.4),
                blurRadius: 10,
                spreadRadius: -4,
                offset: const Offset(0, -2),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurSigma,
            sigmaY: blurSigma,
          ),
          child: content,
        ),
      ),
    );

    if (semanticLabel != null) {
      glassContainer = Semantics(
        label: semanticLabel,
        button: onTap != null,
        child: glassContainer,
      );
    }

    return glassContainer;
  }
}

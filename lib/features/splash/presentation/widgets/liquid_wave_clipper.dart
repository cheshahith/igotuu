import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A custom clipper that makes the intro slide sweep UPWARD like a liquid.
/// As [progress] advances from 0.0 to 1.0, the bottom boundary of the slide
/// surges from below the screen (y = height + 60) up and past the top (y = -80),
/// revealing the content underneath with fluid, organic wave crests.
class LiquidSlideUpClipper extends CustomClipper<Path> {
  final double progress;
  final double waveAmplitude;

  LiquidSlideUpClipper({
    required this.progress,
    this.waveAmplitude = 34.0,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    if (progress >= 1.0) {
      return path; // Completely slid up and cleared
    }
    if (progress <= 0.0) {
      path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
      return path;
    }

    // currentBottomY moves from (height + 50) smoothly up to (-70)
    final currentBottomY = (size.height + 120) * (1.0 - progress) - 70;

    // Start at top-left, go across to top-right
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, currentBottomY);

    // Liquid organic wave along the bottom edge, moving across
    final step = size.width / 4;
    final waveShift = math.sin(progress * math.pi * 3.5) * waveAmplitude;

    path.cubicTo(
      step * 3.0,
      currentBottomY + waveShift - (waveAmplitude * 0.7),
      step * 2.5,
      currentBottomY - waveShift + (waveAmplitude * 0.7),
      step * 2.0,
      currentBottomY,
    );

    path.cubicTo(
      step * 1.5,
      currentBottomY + waveShift + waveAmplitude,
      step * 0.5,
      currentBottomY - waveShift - waveAmplitude,
      0,
      currentBottomY,
    );

    path.lineTo(0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant LiquidSlideUpClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}

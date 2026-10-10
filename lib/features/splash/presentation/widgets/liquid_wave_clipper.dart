import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A custom clipper generating an organic, liquid wave crest
/// that sweeps across the screen based on [progress] (0.0 -> 1.0).
class LiquidWaveClipper extends CustomClipper<Path> {
  final double progress;
  final double waveFrequency;
  final double waveAmplitude;

  LiquidWaveClipper({
    required this.progress,
    this.waveFrequency = 1.5,
    this.waveAmplitude = 28.0,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    if (progress <= 0.0) {
      return path; // Empty
    }
    if (progress >= 1.0) {
      path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
      return path;
    }

    // Baseline sweeps from bottom (size.height) to beyond top (-40)
    final currentY = size.height * (1.0 - progress) + (progress * -40);

    path.moveTo(0, size.height);
    path.lineTo(0, currentY);

    final step = size.width / 4;
    final waveShift = math.sin(progress * math.pi * 2) * waveAmplitude;

    // Cubic bezier curves forming natural liquid crests
    path.cubicTo(
      step * 1.0,
      currentY - waveShift - waveAmplitude,
      step * 2.0,
      currentY + waveShift + waveAmplitude,
      step * 2.5,
      currentY,
    );

    path.cubicTo(
      step * 3.0,
      currentY - waveShift + (waveAmplitude * 0.5),
      step * 3.5,
      currentY + waveShift - (waveAmplitude * 0.5),
      size.width,
      currentY,
    );

    path.lineTo(size.width, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant LiquidWaveClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}

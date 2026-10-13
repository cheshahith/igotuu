import 'package:flutter/material.dart';

/// Custom painter for an aesthetic checked line (grid paper) texture.
/// Designed with reduced line thickness (delicate hairline) for a refined,
/// non-distracting designer stationery feel.
class CheckedPatternPainter extends CustomPainter {
  /// Spacing between checked lines in logical pixels.
  final double gridSize;

  /// Delicate reduced line thickness (hairline width).
  final double lineWidth;

  /// Subtle stroke color for the checked lines.
  final Color lineColor;

  const CheckedPatternPainter({
    this.gridSize = 26.0,
    this.lineWidth = 0.8,
    this.lineColor = const Color(0x9EB07085),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    // Draw vertical checked lines
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal checked lines
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CheckedPatternPainter oldDelegate) {
    return oldDelegate.gridSize != gridSize ||
        oldDelegate.lineWidth != lineWidth ||
        oldDelegate.lineColor != lineColor;
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// CustomPainter that renders a hand-drawn red pencil-style circle.
/// Draws a slightly imperfect, wobbly, overlapping ellipse stroke in red (#D62828, ~1.8px, round caps).
/// Fully deterministic per date so it remains static across rebuilds.
class RedPencilCirclePainter extends CustomPainter {
  final DateTime date;

  const RedPencilCirclePainter({
    required this.date,
  });

  static const Color pencilRed = Color(0xFFD62828);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadiusX = (size.width / 2) * 0.88;
    final baseRadiusY = (size.height / 2) * 0.88;

    // Deterministic pseudo-random seed derived strictly from the date components
    final seed = (date.year * 372 + date.month * 31 + date.day) & 0x7FFFFFFF;

    double rand(int index) {
      var s = (seed + index * 1013904223) & 0x7FFFFFFF;
      s = (s * 1664525 + 1013904223) & 0x7FFFFFFF;
      return (s % 1000) / 1000.0; // 0.0 .. 1.0
    }

    // Deterministic rotation angle (-0.12 to +0.12 rad, ~-7 to +7 deg)
    final tiltAngle = (rand(1) - 0.5) * 0.24;

    // Start angle between -0.4 and -0.1 rad (top right entry)
    final startAngle = -0.35 + (rand(2) - 0.5) * 0.20;

    // Sweep angle includes an overlapping loop (~2.25 * pi)
    final sweepAngle = (2.0 + 0.22 + rand(3) * 0.12) * math.pi;

    final paintMain = Paint()
      ..color = pencilRed
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Subtle graphite texture pass with slight opacity
    final paintPencilTexture = Paint()
      ..color = pencilRed.withValues(alpha: 0.35)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final texturePath = Path();

    const segments = 40;
    bool isFirst = true;

    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      final angle = startAngle + (t * sweepAngle);

      // Deterministic radial wobble: subtle variations around the circumference
      final wobbleFactor = (rand(10 + i) - 0.5) * 2.2;
      // Slight widening toward the overlap
      final overlapOffset = (t > 0.85) ? (t - 0.85) * 3.5 : 0.0;

      final rx = baseRadiusX + wobbleFactor + overlapOffset;
      final ry = baseRadiusY + wobbleFactor * 0.8;

      // Unrotated position on the ellipse
      final unrotatedX = rx * math.cos(angle);
      final unrotatedY = ry * math.sin(angle);

      // Apply tilt
      final cosA = math.cos(tiltAngle);
      final sinA = math.sin(tiltAngle);
      final px = center.dx + (unrotatedX * cosA - unrotatedY * sinA);
      final py = center.dy + (unrotatedX * sinA + unrotatedY * cosA);

      if (isFirst) {
        path.moveTo(px, py);
        texturePath.moveTo(px + 0.35, py - 0.35);
        isFirst = false;
      } else {
        path.lineTo(px, py);
        texturePath.lineTo(px + 0.35, py - 0.35);
      }
    }

    // Render soft pencil texture underlay then main stroke
    canvas.drawPath(texturePath, paintPencilTexture);
    canvas.drawPath(path, paintMain);
  }

  @override
  bool shouldRepaint(covariant RedPencilCirclePainter oldDelegate) {
    return oldDelegate.date.year != date.year ||
        oldDelegate.date.month != date.month ||
        oldDelegate.date.day != date.day;
  }
}

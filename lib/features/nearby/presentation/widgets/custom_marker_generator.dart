import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/worker_model.dart';

/// Runtime generator that paints high-DPI custom BitmapDescriptor markers:
/// - Circular avatar with initials and crisp white border
/// - Floating rating pill (⭐ 4.9)
/// - Highlighted border for selected worker
class CustomMarkerGenerator {
  CustomMarkerGenerator._();

  static final Map<String, BitmapDescriptor> _markerCache = {};

  /// Create or retrieve cached custom BitmapDescriptor for a worker
  static Future<BitmapDescriptor> getWorkerMarker({
    required WorkerModel worker,
    required bool isSelected,
  }) async {
    final cacheKey = '${worker.id}_${worker.rating}_$isSelected';
    if (_markerCache.containsKey(cacheKey)) {
      return _markerCache[cacheKey]!;
    }

    final descriptor = await _drawWorkerMarker(worker, isSelected);
    _markerCache[cacheKey] = descriptor;
    return descriptor;
  }

  static Future<BitmapDescriptor> _drawWorkerMarker(
    WorkerModel worker,
    bool isSelected,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Scale dimensions based on selection
    final sizeMultiplier = isSelected ? 1.25 : 1.0;
    final totalWidth = 120.0 * sizeMultiplier;
    final totalHeight = 135.0 * sizeMultiplier;

    final avatarRadius = 40.0 * sizeMultiplier;
    final avatarCenter = Offset(totalWidth / 2, avatarRadius + 4);

    // 1. Drop shadow for the marker
    final shadowPaint = Paint()
      ..color = const Color(0x3326332A)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(avatarCenter.translate(0, 4), avatarRadius, shadowPaint);

    // 2. Selection outer halo ring
    if (isSelected) {
      final haloPaint = Paint()
        ..color = AppColors.sageDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.0 * sizeMultiplier;
      canvas.drawCircle(avatarCenter, avatarRadius + 3.0, haloPaint);
    }

    // 3. Avatar background circle
    final bgPaint = Paint()..color = worker.avatarColor;
    canvas.drawCircle(avatarCenter, avatarRadius, bgPaint);

    // 4. Inner white border
    final whiteBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5 * sizeMultiplier;
    canvas.drawCircle(avatarCenter, avatarRadius, whiteBorderPaint);

    // 5. Initials text in the avatar
    final initialsPainter = TextPainter(
      text: TextSpan(
        text: worker.initials,
        style: TextStyle(
          color: AppColors.textDark,
          fontSize: 26.0 * sizeMultiplier,
          fontWeight: FontWeight.w800,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    initialsPainter.paint(
      canvas,
      Offset(
        avatarCenter.dx - (initialsPainter.width / 2),
        avatarCenter.dy - (initialsPainter.height / 2),
      ),
    );

    // 6. Rating Pill at bottom (e.g., "⭐ 4.9")
    final pillWidth = 62.0 * sizeMultiplier;
    final pillHeight = 26.0 * sizeMultiplier;
    final pillRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(totalWidth / 2, avatarCenter.dy + avatarRadius + 4),
        width: pillWidth,
        height: pillHeight,
      ),
      Radius.circular(13.0 * sizeMultiplier),
    );

    // Pill shadow
    canvas.drawRRect(pillRect.shift(const Offset(0, 2)), shadowPaint);

    // Pill background
    final pillBgPaint = Paint()..color = Colors.white;
    canvas.drawRRect(pillRect, pillBgPaint);

    // Pill border
    final pillBorderPaint = Paint()
      ..color = AppColors.sage.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(pillRect, pillBorderPaint);

    // Star icon & rating text
    final ratingPainter = TextPainter(
      text: TextSpan(
        text: '★ ${worker.rating}',
        style: TextStyle(
          color: AppColors.textDark,
          fontSize: 13.0 * sizeMultiplier,
          fontWeight: FontWeight.w800,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    ratingPainter.paint(
      canvas,
      Offset(
        (totalWidth / 2) - (ratingPainter.width / 2),
        avatarCenter.dy + avatarRadius + 4 - (ratingPainter.height / 2),
      ),
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(totalWidth.toInt(), totalHeight.toInt());
    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(pngBytes!.buffer.asUint8List());
  }
}

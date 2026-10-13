import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'checked_pattern_painter.dart';

/// Renders a soft pink palette background layered with:
/// 1. Glowing ambient organic blobs (cream, sage, blush)
/// 2. Delicate checked line texture (with reduced line thickness)
/// Frosted glass surfaces float over this backdrop to blur both the blobs
/// and checked grid texture for an aesthetic, high-end feel.
class BlurredBackgroundBlobs extends StatefulWidget {
  final Widget? child;

  const BlurredBackgroundBlobs({
    super.key,
    this.child,
  });

  @override
  State<BlurredBackgroundBlobs> createState() => _BlurredBackgroundBlobsState();
}

class _BlurredBackgroundBlobsState extends State<BlurredBackgroundBlobs>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final animValue = _controller.value;
        final size = MediaQuery.sizeOf(context);

        return Stack(
          children: [
            // 1. Base soft pink background from palette (#F6E2E9)
            Container(color: AppColors.background),

            // 2. Ambient organic blobs floating beneath the checked grid & cards
            // Blob 1: Luminous Warm Cream glow (top right / upper center)
            Positioned(
              top: -60 + (animValue * 25),
              right: -80 + (animValue * 20),
              child: _buildBlob(
                size: 380,
                color: AppColors.cream.withValues(alpha: 0.80),
                blurRadius: 75,
              ),
            ),

            // Blob 2: Light Sage (middle left)
            Positioned(
              top: size.height * 0.35 + ((1.0 - animValue) * 30),
              left: -100 + (animValue * 15),
              child: _buildBlob(
                size: 390,
                color: AppColors.lightSage.withValues(alpha: 0.65),
                blurRadius: 85,
              ),
            ),

            // Blob 3: Sage Primary (lower right / bottom)
            Positioned(
              bottom: -50 + (animValue * 30),
              right: -60 + ((1.0 - animValue) * 20),
              child: _buildBlob(
                size: 410,
                color: AppColors.sage.withValues(alpha: 0.38),
                blurRadius: 95,
              ),
            ),

            // Blob 4: Soft pearl blush glow in mid-lower section
            Positioned(
              top: size.height * 0.62 - (animValue * 20),
              left: size.width * 0.18,
              child: _buildBlob(
                size: 280,
                color: const Color(0xFFFFEEF4).withValues(alpha: 0.60),
                blurRadius: 65,
              ),
            ),

            // 3. Delicate checked line texture with reduced line thickness (richer, darker definition)
            const Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: CheckedPatternPainter(
                    gridSize: 26.0,
                    lineWidth: 0.8,
                    lineColor: Color(0x9EB07085),
                  ),
                ),
              ),
            ),

            // 4. Foreground content
            if (widget.child != null) widget.child!,
          ],
        );
      },
    );
  }

  Widget _buildBlob({
    required double size,
    required Color color,
    required double blurRadius,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: color.a * 0.6),
            color.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
    );
  }
}

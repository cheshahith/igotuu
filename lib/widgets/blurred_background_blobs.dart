import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Renders 2-3 large blurred organic blobs (pink, light sage, sage)
/// on the cream page background so that frosted glass surfaces
/// have rich colored backdrops to blur over.
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
            // Base cream background
            Container(color: AppColors.background),

            // Blob 1: Soft Pink (top right / upper center)
            Positioned(
              top: -60 + (animValue * 25),
              right: -80 + (animValue * 20),
              child: _buildBlob(
                size: 360,
                color: AppColors.softPink.withValues(alpha: 0.85),
                blurRadius: 70,
              ),
            ),

            // Blob 2: Light Sage (middle left)
            Positioned(
              top: size.height * 0.35 + ((1.0 - animValue) * 30),
              left: -100 + (animValue * 15),
              child: _buildBlob(
                size: 380,
                color: AppColors.lightSage.withValues(alpha: 0.80),
                blurRadius: 80,
              ),
            ),

            // Blob 3: Sage Primary (lower right / bottom)
            Positioned(
              bottom: -50 + (animValue * 30),
              right: -60 + ((1.0 - animValue) * 20),
              child: _buildBlob(
                size: 400,
                color: AppColors.sage.withValues(alpha: 0.50),
                blurRadius: 90,
              ),
            ),

            // Blob 4: Soft Pinkish-Cream glow in middle for rich contrast
            Positioned(
              top: size.height * 0.65 - (animValue * 20),
              left: size.width * 0.2,
              child: _buildBlob(
                size: 260,
                color: AppColors.softPink.withValues(alpha: 0.55),
                blurRadius: 60,
              ),
            ),

            // Foreground content
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

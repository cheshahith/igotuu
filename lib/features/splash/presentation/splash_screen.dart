import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/persistent_shell.dart';
import 'widgets/liquid_wave_clipper.dart';

/// Splash intro screen for igotuu
/// Sequence:
/// 1. Centered logo "igu" appears in bold script font in palette soft pink (#F6E2E9)
/// 2. Smoothly expands into "igotuu" without jumps on a rich forest sage canvas
/// 3. Holds for 0.5s
/// 4. When the intro completes, the intro slide goes UP like a liquid wave,
///    revealing the soft pink checked Home page underneath!
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Main master controller for the splash sequence (3.2 seconds total)
  late final AnimationController _masterController;

  // Animation curves
  late final Animation<double> _fadeInAnimation;
  late final Animation<double> _expansionAnimation;
  late final Animation<double> _liquidSlideUpAnimation;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    // Phase 1 (0ms - 600ms): Logo "igu" in soft pink fades and scales into center
    _fadeInAnimation = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.0, 0.20, curve: Curves.easeOutBack),
    );

    // Phase 2 (700ms - 1750ms): "igu" expands smoothly into "igotuu"
    _expansionAnimation = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.22, 0.55, curve: Curves.easeInOutCubic),
    );

    // Phase 3 (1750ms - 2250ms): Hold for ~0.5s

    // Phase 4 (2250ms - 3200ms): Intro slide sweeps UP like a liquid
    _liquidSlideUpAnimation = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.68, 1.0, curve: Curves.easeInOutQuart),
    );

    _masterController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_navigated) {
        _navigated = true;
        _navigateToHome();
      }
    });

    _masterController.forward();
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        pageBuilder: (context, animation, secondaryAnimation) {
          return const PersistentShell();
        },
      ),
    );
  }

  @override
  void dispose() {
    _masterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // App name color is the palette soft pink (#F6E2E9)
    const scriptStyle = TextStyle(
      fontSize: 54,
      fontWeight: FontWeight.w700,
      color: AppColors.softPink,
      letterSpacing: 0.2,
      shadows: [
        Shadow(
          color: Color(0x60F6E2E9),
          blurRadius: 18,
          offset: Offset(0, 3),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Base Layer: The Home Screen (unveiled seamlessly as the intro slide goes up like liquid)
          const Positioned.fill(
            child: PersistentShell(),
          ),

          // 2. Top Layer: Intro Slide with liquid slide-up clipper
          AnimatedBuilder(
            animation: _liquidSlideUpAnimation,
            builder: (context, child) {
              final slideProgress = _liquidSlideUpAnimation.value;
              if (slideProgress >= 1.0) {
                return const SizedBox.shrink();
              }

              return ClipPath(
                clipper: LiquidSlideUpClipper(
                  progress: slideProgress,
                  waveAmplitude: 36.0,
                ),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF1E2B22),
                        Color(0xFF26332A),
                        Color(0xFF2E3D32),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Ambient luminous glowing blobs on the intro slide
                      Positioned(
                        top: -50,
                        right: -60,
                        child: _buildAmbientBlob(
                          size: 340,
                          color: AppColors.sage.withValues(alpha: 0.35),
                        ),
                      ),
                      Positioned(
                        bottom: -60,
                        left: -50,
                        child: _buildAmbientBlob(
                          size: 360,
                          color: AppColors.softPink.withValues(alpha: 0.20),
                        ),
                      ),

                      // Center Logo with Animated Expansion: "igu" -> "igotuu" in soft pink
                      Center(
                        child: AnimatedBuilder(
                          animation: _masterController,
                          builder: (context, child) {
                            final fade = _fadeInAnimation.value;
                            final expand = _expansionAnimation.value;

                            return Opacity(
                              opacity: fade.clamp(0.0, 1.0),
                              child: Transform.scale(
                                scale: 0.85 + (0.15 * fade),
                                child: Material(
                                  color: Colors.transparent,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      // "ig" - always present
                                      Text(
                                        'ig',
                                        style: AppTypography.logoScript(
                                          fontSize: scriptStyle.fontSize!,
                                          color: scriptStyle.color!,
                                        ).copyWith(
                                          shadows: scriptStyle.shadows,
                                        ),
                                      ),

                                      // "ot" - expands smoothly from 0 width to full width
                                      ClipRect(
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: expand,
                                          child: Opacity(
                                            opacity: expand.clamp(0.0, 1.0),
                                            child: Text(
                                              'ot',
                                              style: AppTypography.logoScript(
                                                fontSize: scriptStyle.fontSize!,
                                                color: scriptStyle.color!,
                                              ).copyWith(
                                                shadows: scriptStyle.shadows,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // "u" - always present
                                      Text(
                                        'u',
                                        style: AppTypography.logoScript(
                                          fontSize: scriptStyle.fontSize!,
                                          color: scriptStyle.color!,
                                        ).copyWith(
                                          shadows: scriptStyle.shadows,
                                        ),
                                      ),

                                      // "u" (second 'u') - expands smoothly from 0 width to full width
                                      ClipRect(
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: expand,
                                          child: Opacity(
                                            opacity: expand.clamp(0.0, 1.0),
                                            child: Text(
                                              'u',
                                              style: AppTypography.logoScript(
                                                fontSize: scriptStyle.fontSize!,
                                                color: scriptStyle.color!,
                                              ).copyWith(
                                                shadows: scriptStyle.shadows,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientBlob({
    required double size,
    required Color color,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.75],
        ),
      ),
    );
  }
}

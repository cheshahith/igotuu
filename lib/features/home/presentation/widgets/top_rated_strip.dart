import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../widgets/frosted_glass.dart';
import '../../../nearby/presentation/nearby_workers_screen.dart';
import '../../data/dummy_providers.dart';

/// Top rated service providers strip that continuously glides like a train.
/// Engineered with:
/// - VSync-locked Ticker for ultra-smooth 60fps/120fps continuous train movement
/// - Proportionately scaled-down compact cards ("a little smaller")
/// - Interactive pause-on-touch with graceful resume
/// - Soft edge gradient vignettes for aesthetic entry & exit
class TopRatedStrip extends StatefulWidget {
  const TopRatedStrip({super.key});

  @override
  State<TopRatedStrip> createState() => _TopRatedStripState();
}

class _TopRatedStripState extends State<TopRatedStrip>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final Ticker _ticker;
  Timer? _resumeTimer;
  bool _isUserInteracting = false;
  Duration _lastTick = Duration.zero;

  // Proportionately reduced dimensions ("a little smaller")
  static const double _cardWidth = 212.0;
  static const double _cardSpacing = 11.0;
  static const double _stripHeight = 124.0;
  static const double _scrollSpeed = 50.0; // Steady, fluid train cruising speed (px/sec)

  // Infinite seamless loop multiplier
  static const int _loopMultiplier = 600;
  late final double _oneCycleWidth;
  late final double _centerOffset;

  @override
  void initState() {
    super.initState();

    _oneCycleWidth = (_cardWidth + _cardSpacing) * DummyProviders.list.length;
    _centerOffset = _oneCycleWidth * (_loopMultiplier ~/ 2);
    _scrollController = ScrollController(initialScrollOffset: _centerOffset);

    // Vsync-locked ticker for silky-smooth train motion
    _ticker = createTicker(_onTick);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _ticker.start();
      }
    });
  }

  void _onTick(Duration elapsed) {
    if (!mounted || !_scrollController.hasClients || _isUserInteracting) {
      _lastTick = elapsed;
      return;
    }

    if (_lastTick == Duration.zero) {
      _lastTick = elapsed;
      return;
    }

    final dt = (elapsed - _lastTick).inMicroseconds / 1000000.0;
    _lastTick = elapsed;

    // Guard against frame lag spikes (e.g. app resume or route transition)
    if (dt <= 0.0 || dt > 0.08) return;

    final currentOffset = _scrollController.offset;
    final step = _scrollSpeed * dt;
    final newOffset = currentOffset + step;

    // Seamless loop reset: jump backward or forward by exact cycle multiples
    final maxThreshold = _centerOffset + (_oneCycleWidth * 120);
    final minThreshold = _centerOffset - (_oneCycleWidth * 120);
    if (newOffset >= maxThreshold) {
      _scrollController.jumpTo(newOffset - (_oneCycleWidth * 60));
    } else if (newOffset <= minThreshold) {
      _scrollController.jumpTo(newOffset + (_oneCycleWidth * 60));
    } else {
      _scrollController.jumpTo(newOffset);
    }
  }

  void _pauseAutoScroll() {
    _resumeTimer?.cancel();
    _isUserInteracting = true;
  }

  void _resumeAutoScrollAfterDelay() {
    _resumeTimer?.cancel();
    _resumeTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        _lastTick = Duration.zero;
        _isUserInteracting = false;
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _resumeTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top rated near you',
                style: AppTypography.headingMedium(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.sage.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.sage.withValues(alpha: 0.28),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.near_me_rounded,
                      size: 12,
                      color: AppColors.sageDark,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'within 5km',
                      style: AppTypography.bodySmall(
                        fontSize: 11,
                        color: AppColors.sageDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Horizontally scrolling train strip with edge fade vignettes
        SizedBox(
          height: _stripHeight,
          child: Stack(
            children: [
              // Continuous train scroll list
              Listener(
                onPointerDown: (_) => _pauseAutoScroll(),
                onPointerUp: (_) => _resumeAutoScrollAfterDelay(),
                onPointerCancel: (_) => _resumeAutoScrollAfterDelay(),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    // Only pause on real user touch/drag gesture.
                    // Programmatic jumpTo has null dragDetails and must NOT pause the train!
                    if (notification is ScrollStartNotification &&
                        notification.dragDetails != null) {
                      _pauseAutoScroll();
                    } else if (notification is ScrollEndNotification) {
                      if (_isUserInteracting) {
                        _resumeAutoScrollAfterDelay();
                      }
                    } else if (notification is UserScrollNotification) {
                      if (notification.direction != ScrollDirection.idle) {
                        _pauseAutoScroll();
                      } else {
                        _resumeAutoScrollAfterDelay();
                      }
                    }
                    return false;
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: DummyProviders.list.length * _loopMultiplier,
                    itemBuilder: (context, index) {
                      final provider =
                          DummyProviders.list[index % DummyProviders.list.length];
                      return Container(
                        width: _cardWidth,
                        margin: const EdgeInsets.only(right: _cardSpacing),
                        child: _buildProviderCard(provider),
                      );
                    },
                  ),
                ),
              ),

              // Left edge soft fade vignette
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 22,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          AppColors.background.withValues(alpha: 0.92),
                          AppColors.background.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Right edge soft fade vignette
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 22,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          AppColors.background.withValues(alpha: 0.92),
                          AppColors.background.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProviderCard(ProviderModel provider) {
    return FrostedGlass(
      borderRadius: 18,
      blurSigma: 16,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      fillColor: Colors.white.withValues(alpha: 0.35),
      borderColor: Colors.white.withValues(alpha: 0.62),
      onTap: () => _showProviderDetailsModal(provider),
      semanticLabel:
          'Provider ${provider.name}, ${provider.trade}, rating ${provider.rating}. Tap to view worker details.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Row: Avatar initials, Name & Verified icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Initials Avatar
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: provider.avatarColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.85),
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Text(
                    provider.initials,
                    style: AppTypography.headingSmall(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Name and Trade
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            provider.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.headingSmall(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        if (provider.isVerified) ...[
                          const SizedBox(width: 3),
                          const Icon(
                            Icons.verified_rounded,
                            size: 13,
                            color: AppColors.sageDark,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      provider.trade,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall(
                        fontSize: 10.5,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Middle info: Rating and distance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Rating
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 13,
                    color: AppColors.starAmber,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${provider.rating}',
                    style: AppTypography.bodySmall(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '(${provider.reviewCount})',
                    style: AppTypography.bodySmall(
                      fontSize: 9.5,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),

              // Distance
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 11,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    provider.distance,
                    style: AppTypography.bodySmall(
                      fontSize: 10,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Bottom line: Price per hour + Verified chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                provider.pricePerHour,
                style: AppTypography.headingSmall(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.sageDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.sage.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Verified',
                  style: AppTypography.label(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.sageDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showProviderDetailsModal(ProviderModel provider) {
    _pauseAutoScroll();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: FrostedGlass(
            borderRadius: 28,
            blurSigma: 24,
            padding: const EdgeInsets.all(22),
            fillColor: Colors.white.withValues(alpha: 0.78),
            borderColor: Colors.white,
            shadows: const [
              BoxShadow(
                color: Color(0x2226332A),
                blurRadius: 28,
                offset: Offset(0, -4),
              ),
            ],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top drag pill
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textDark.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Avatar + Worker Name Prominently
                Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: provider.avatarColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          provider.initials,
                          style: AppTypography.headingMedium(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  provider.name,
                                  style: AppTypography.headingMedium(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                              if (provider.isVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified_rounded,
                                  size: 17,
                                  color: AppColors.sageDark,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${provider.trade} • Verified Professional',
                            style: AppTypography.bodySmall(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.sageDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Ratings and Distance Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.7),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Rating
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 18, color: AppColors.starAmber),
                          const SizedBox(width: 4),
                          Text(
                            '${provider.rating}',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                          Text(
                            ' (${provider.reviewCount})',
                            style: const TextStyle(color: AppColors.textLight, fontSize: 11),
                          ),
                        ],
                      ),
                      Container(height: 20, width: 1, color: const Color(0x303F5A3E)),
                      // Distance
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 16, color: AppColors.sageDark),
                          const SizedBox(width: 4),
                          Text(
                            provider.distance,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ],
                      ),
                      Container(height: 20, width: 1, color: const Color(0x303F5A3E)),
                      // Price
                      Text(
                        provider.pricePerHour,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppColors.sageDark,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Action buttons: "Find on Map" and "Close"
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(bottomSheetContext).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => NearbyWorkersScreen(trade: provider.trade),
                              ),
                            );
                          },
                          icon: const Icon(Icons.map_rounded, size: 18),
                          label: const Text(
                            'View on Map',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.sageDark,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(bottomSheetContext).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textDark,
                          side: BorderSide(color: AppColors.textDark.withValues(alpha: 0.2)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      _resumeAutoScrollAfterDelay();
    });
  }
}

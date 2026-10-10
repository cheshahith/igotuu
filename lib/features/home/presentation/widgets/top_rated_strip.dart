import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../widgets/frosted_glass.dart';
import '../../data/dummy_providers.dart';

class TopRatedStrip extends StatefulWidget {
  const TopRatedStrip({super.key});

  @override
  State<TopRatedStrip> createState() => _TopRatedStripState();
}

class _TopRatedStripState extends State<TopRatedStrip> {
  late final ScrollController _scrollController;
  Timer? _autoScrollTimer;
  Timer? _resumeTimer;
  bool _isUserTouching = false;

  // Multiplier to create a virtually infinite looping strip
  static const int _loopMultiplier = 100;
  static const double _cardWidth = 250.0;
  static const double _cardSpacing = 14.0;
  static const double _stepDistance = 0.85; // Slow, smooth auto-scroll speed

  @override
  void initState() {
    super.initState();
    // Start somewhere in the middle so user can also scroll backward
    final initialOffset = (_cardWidth + _cardSpacing) *
        DummyProviders.list.length *
        (_loopMultiplier ~/ 2);
    _scrollController = ScrollController(initialScrollOffset: initialOffset);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 25), (_) {
      if (!mounted || _isUserTouching || !_scrollController.hasClients) return;

      final currentOffset = _scrollController.offset;
      final maxOffset = _scrollController.position.maxScrollExtent;

      if (currentOffset >= maxOffset - 100) {
        // Reset to middle seamless loop point
        final resetOffset = (_cardWidth + _cardSpacing) *
            DummyProviders.list.length *
            (_loopMultiplier ~/ 2);
        _scrollController.jumpTo(resetOffset);
      } else {
        _scrollController.jumpTo(currentOffset + _stepDistance);
      }
    });
  }

  void _pauseAutoScroll() {
    _resumeTimer?.cancel();
    _isUserTouching = true;
  }

  void _resumeAutoScrollAfterDelay() {
    _resumeTimer?.cancel();
    _resumeTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        _isUserTouching = false;
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
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
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.sage.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
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

        const SizedBox(height: 14),

        // Horizontally scrolling cards strip
        SizedBox(
          height: 148,
          child: Listener(
            onPointerDown: (_) => _pauseAutoScroll(),
            onPointerUp: (_) => _resumeAutoScrollAfterDelay(),
            onPointerCancel: (_) => _resumeAutoScrollAfterDelay(),
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification) {
                  _pauseAutoScroll();
                } else if (notification is ScrollEndNotification) {
                  _resumeAutoScrollAfterDelay();
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
        ),
      ],
    );
  }

  Widget _buildProviderCard(ProviderModel provider) {
    return FrostedGlass(
      borderRadius: 22,
      blurSigma: 18,
      padding: const EdgeInsets.all(14),
      fillColor: Colors.white.withValues(alpha: 0.32),
      borderColor: Colors.white.withValues(alpha: 0.58),
      semanticLabel:
          'Provider ${provider.name}, ${provider.trade}, rating ${provider.rating}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Row: Avatar initials, Name & Verified badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Initials Avatar
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: provider.avatarColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.8),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    provider.initials,
                    style: AppTypography.headingSmall(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

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
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        if (provider.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified_rounded,
                            size: 15,
                            color: AppColors.sageDark,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      provider.trade,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall(
                        fontSize: 11,
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
            children: [
              // Rating
              const Icon(
                Icons.star_rounded,
                size: 16,
                color: AppColors.starAmber,
              ),
              const SizedBox(width: 3),
              Text(
                '${provider.rating}',
                style: AppTypography.bodySmall(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                '(${provider.reviewCount})',
                style: AppTypography.bodySmall(
                  fontSize: 11,
                  color: AppColors.textLight,
                ),
              ),

              const Spacer(),

              // Distance
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 13,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    provider.distance,
                    style: AppTypography.bodySmall(
                      fontSize: 11,
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
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.sageDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.sage.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Verified',
                  style: AppTypography.label(
                    fontSize: 10,
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
}

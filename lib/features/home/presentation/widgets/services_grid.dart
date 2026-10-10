import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../widgets/frosted_glass.dart';

class ServicesGrid extends StatelessWidget {
  const ServicesGrid({super.key});

  static const List<Map<String, dynamic>> _services = [
    {
      'label': 'Plumber',
      'icon': Icons.plumbing_rounded,
      'subtitle': 'Pipes & leaks',
      'accentColor': AppColors.sageDark,
    },
    {
      'label': 'Electrician',
      'icon': Icons.bolt_rounded,
      'subtitle': 'Wiring & power',
      'accentColor': Color(0xFFC78438),
    },
    {
      'label': 'Carpenter',
      'icon': Icons.carpenter_rounded,
      'subtitle': 'Wood & furniture',
      'accentColor': Color(0xFF8B5E3C),
    },
    {
      'label': 'Mechanic',
      'icon': Icons.build_rounded,
      'subtitle': 'Motors & auto',
      'accentColor': Color(0xFF4A6B82),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with "More" button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Pick a service',
                style: AppTypography.headingMedium(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Semantics(
                button: true,
                label: 'View more services',
                child: TextButton(
                  onPressed: () {
                    // Per prompt: taps do nothing for now
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.sageDark,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    minimumSize: const Size(48, 48),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'More',
                        style: AppTypography.label(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.sageDark,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: AppColors.sageDark,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 2x2 Grid of frosted glass panels
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _services.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.35,
            ),
            itemBuilder: (context, index) {
              final service = _services[index];
              return _buildServicePanel(
                label: service['label'] as String,
                icon: service['icon'] as IconData,
                subtitle: service['subtitle'] as String,
                accentColor: service['accentColor'] as Color,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServicePanel({
    required String label,
    required IconData icon,
    required String subtitle,
    required Color accentColor,
  }) {
    return FrostedGlass(
      borderRadius: 24,
      blurSigma: 18,
      padding: const EdgeInsets.all(14),
      fillColor: Colors.white.withValues(alpha: 0.32),
      borderColor: Colors.white.withValues(alpha: 0.58),
      onTap: () {
        // Taps do nothing for now per spec
      },
      semanticLabel: '$label service panel',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Circular icon badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.sage.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                color: AppColors.sageDark,
                size: 24,
              ),
            ),
          ),

          // Label and subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTypography.headingSmall(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.bodySmall(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../widgets/frosted_glass.dart';
import '../../../../widgets/igotuu_logo.dart';
import 'location_bottom_sheet.dart';

class HomeHeader extends StatelessWidget {
  final String currentAddress;
  final ValueChanged<String> onAddressChanged;

  const HomeHeader({
    super.key,
    required this.currentAddress,
    required this.onAddressChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Top-left: "igotuu" logo in the bold script font with Hero continuity
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const IgotuuLogo(
                  fontSize: 32,
                  enableHero: true,
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 13,
                      color: AppColors.sageDark,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        currentAddress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Top-right: Glass location-pin icon button (min 48x48 target)
          FrostedGlass(
            borderRadius: 20,
            blurSigma: 18,
            fillColor: Colors.white.withValues(alpha: 0.40),
            borderColor: Colors.white.withValues(alpha: 0.65),
            shadows: [
              const BoxShadow(
                color: Color(0x1026332A),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
            onTap: () {
              LocationBottomSheet.show(
                context,
                currentAddress: currentAddress,
                onAddressSaved: onAddressChanged,
              );
            },
            semanticLabel: 'Change service address',
            child: const SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: Icon(
                  Icons.location_pin,
                  color: AppColors.sageDark,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

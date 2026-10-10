import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import 'frosted_glass.dart';

/// Persistent shell widget housing the floating frosted glass bottom bar.
/// Keeps future pages extensible and ensures the bar overlays the content
/// using [Scaffold.extendBody] with proper bottom inset padding.
class PersistentShell extends StatefulWidget {
  final Widget child;

  const PersistentShell({
    super.key,
    required this.child,
  });

  @override
  State<PersistentShell> createState() => _PersistentShellState();
}

class _PersistentShellState extends State<PersistentShell> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: widget.child,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: FrostedGlass(
            borderRadius: 32,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            fillColor: Colors.white.withValues(alpha: 0.38),
            borderColor: Colors.white.withValues(alpha: 0.65),
            blurSigma: 22,
            shadows: [
              const BoxShadow(
                color: Color(0x1826332A),
                blurRadius: 28,
                spreadRadius: 2,
                offset: Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.6),
                blurRadius: 10,
                spreadRadius: -2,
                offset: const Offset(0, -2),
              ),
            ],
            child: SizedBox(
              height: 56,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // 1. Home - Active with sage highlight pill
                  _buildActiveHomeTab(),

                  // 2. Bookings - Icon only, no-op
                  _buildInactiveTab(
                    icon: Icons.calendar_month_rounded,
                    label: 'Bookings',
                  ),

                  // 3. Profile - Icon only, no-op
                  _buildInactiveTab(
                    icon: Icons.person_outline_rounded,
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveHomeTab() {
    return Semantics(
      label: 'Home tab, active',
      selected: true,
      button: true,
      child: Container(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.sage.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.sage.withValues(alpha: 0.40),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.home_rounded,
              color: AppColors.sageDark,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              'Home',
              style: AppTypography.headingSmall(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.sageDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInactiveTab({
    required IconData icon,
    required String label,
  }) {
    return Semantics(
      label: '$label tab',
      button: true,
      child: Tooltip(
        message: label,
        child: InkResponse(
          onTap: () {
            // Per prompt: Bookings and Profile show only their icons
            // and do nothing when tapped (no navigation, no message).
          },
          radius: 28,
          splashColor: AppColors.sage.withValues(alpha: 0.1),
          highlightColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: AppColors.textDark.withValues(alpha: 0.55),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

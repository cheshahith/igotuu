import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../features/bookings/presentation/bookings_screen.dart';
import '../features/home/presentation/home_screen.dart';
import 'frosted_glass.dart';

/// Controller / Scope allowing child widgets to switch tabs in [PersistentShell].
class PersistentShellScope extends InheritedWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const PersistentShellScope({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required super.child,
  });

  static PersistentShellScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PersistentShellScope>();
  }

  @override
  bool updateShouldNotify(covariant PersistentShellScope oldWidget) {
    return oldWidget.currentIndex != currentIndex;
  }
}

/// Persistent shell widget housing the floating frosted glass bottom bar.
/// Keeps Home and Bookings states preserved using [IndexedStack].
/// - Tab 0: Home
/// - Tab 1: Bookings
/// - Tab 2: Profile (no-op)
class PersistentShell extends StatefulWidget {
  final Widget? child;
  final int initialIndex;

  const PersistentShell({
    super.key,
    this.child,
    this.initialIndex = 0,
  });

  /// Helper to change tabs programmatically
  static void switchTab(BuildContext context, int index) {
    PersistentShellScope.of(context)?.onTabSelected(index);
  }

  @override
  State<PersistentShell> createState() => _PersistentShellState();
}

class _PersistentShellState extends State<PersistentShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      // Profile tab still does nothing when tapped per prompt
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bodyContent = widget.child ??
        IndexedStack(
          index: _currentIndex,
          children: const [
            HomeScreen(),
            BookingsScreen(),
          ],
        );

    return PersistentShellScope(
      currentIndex: _currentIndex,
      onTabSelected: _onTabTapped,
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: bodyContent,
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
                    // 1. Home tab
                    _currentIndex == 0
                        ? _buildActiveTab(
                            icon: Icons.home_rounded,
                            label: 'Home',
                          )
                        : _buildInactiveTab(
                            icon: Icons.home_outlined,
                            label: 'Home',
                            index: 0,
                          ),

                    // 2. Bookings tab
                    _currentIndex == 1
                        ? _buildActiveTab(
                            icon: Icons.calendar_month_rounded,
                            label: 'Bookings',
                          )
                        : _buildInactiveTab(
                            icon: Icons.calendar_month_rounded,
                            label: 'Bookings',
                            index: 1,
                          ),

                    // 3. Profile - Icon only, no-op
                    _buildInactiveTab(
                      icon: Icons.person_outline_rounded,
                      label: 'Profile',
                      index: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTab({
    required IconData icon,
    required String label,
  }) {
    return Semantics(
      label: '$label tab, active',
      selected: true,
      button: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
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
            Icon(
              icon,
              color: AppColors.sageDark,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              label,
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
    required int index,
  }) {
    return Semantics(
      label: '$label tab',
      button: true,
      child: Tooltip(
        message: label,
        child: InkResponse(
          onTap: () => _onTabTapped(index),
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

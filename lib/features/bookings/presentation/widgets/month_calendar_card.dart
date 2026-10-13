import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../widgets/frosted_glass.dart';
import '../../data/bookings_repository.dart';
import 'red_pencil_circle_painter.dart';

/// Glass card featuring today's prominent date header and an animated expand/collapse month calendar.
/// Follows strict design guidelines:
/// - Hand-drawn red pencil circle around dates with completed past bookings
/// - Today highlighted with primary-color filled circle
/// - Selected date outlined
/// - Touch targets >= 48dp, semantic labels, smooth animations
class MonthCalendarCard extends StatefulWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateSelected;
  final bool initiallyExpanded;

  const MonthCalendarCard({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.initiallyExpanded = true,
  });

  @override
  State<MonthCalendarCard> createState() => _MonthCalendarCardState();
}

class _MonthCalendarCardState extends State<MonthCalendarCard>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late DateTime _viewMonth;
  late final AnimationController _expandController;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _chevronRotation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    final now = DateTime.now();
    _viewMonth = DateTime(now.year, now.month, 1);

    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      value: _isExpanded ? 1.0 : 0.0,
    );

    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOutCubic,
    );

    _chevronRotation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _expandController,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }

  void _prevMonth() {
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayFormatted = DateFormat('EEE, d MMM yyyy').format(now);

    return FrostedGlass(
      borderRadius: 24,
      blurSigma: 18,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      fillColor: Colors.white.withValues(alpha: 0.36),
      borderColor: Colors.white.withValues(alpha: 0.65),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Prominent Today Header (Tap to toggle calendar expand/collapse)
          Semantics(
            button: true,
            label: 'Today is $todayFormatted. ${_isExpanded ? "Collapse calendar" : "Expand calendar"}',
            child: InkWell(
              onTap: _toggleExpanded,
              borderRadius: BorderRadius.circular(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      // Calendar Icon badge
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.sage.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.sage.withValues(alpha: 0.30),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          color: AppColors.sageDark,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Prominent Today's Date
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'TODAY',
                              style: AppTypography.label(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              todayFormatted,
                              style: AppTypography.headingMedium(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Animated Chevron
                      RotationTransition(
                        turns: _chevronRotation,
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.sageDark,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Expandable Month Calendar Section
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1.0,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  final velocity = details.primaryVelocity ?? 0;
                  if (velocity < -120) {
                    _nextMonth();
                  } else if (velocity > 120) {
                    _prevMonth();
                  }
                },
                child: Column(
                  children: [
                    const Divider(
                      height: 16,
                      thickness: 0.8,
                      color: Color(0x203F5A3E),
                    ),

                    // Month Title with Prev / Next Arrow buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.chevron_left_rounded,
                            color: AppColors.sageDark,
                            size: 26,
                          ),
                          onPressed: _prevMonth,
                          tooltip: 'Previous month',
                          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                        ),
                        Text(
                          DateFormat('MMMM yyyy').format(_viewMonth),
                          style: AppTypography.headingSmall(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.sageDark,
                            size: 26,
                          ),
                          onPressed: _nextMonth,
                          tooltip: 'Next month',
                          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Weekday names
                    _buildWeekdayHeader(),

                    const SizedBox(height: 6),

                    // Grid of Days in Month
                    _buildCalendarDaysGrid(now),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: AppTypography.label(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarDaysGrid(DateTime now) {
    final year = _viewMonth.year;
    final month = _viewMonth.month;
    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // weekday is 1 (Mon) .. 7 (Sun)
    final startingWeekdayOffset = firstDayOfMonth.weekday - 1;

    final totalCells = ((startingWeekdayOffset + daysInMonth + 6) ~/ 7) * 7;
    final rows = <Widget>[];

    for (int weekStart = 0; weekStart < totalCells; weekStart += 7) {
      final weekCells = <Widget>[];
      for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
        final cellIndex = weekStart + dayOffset;
        final dayNumber = cellIndex - startingWeekdayOffset + 1;

        if (dayNumber < 1 || dayNumber > daysInMonth) {
          // Empty cell outside current month
          weekCells.add(const Expanded(child: SizedBox(height: 48)));
        } else {
          final date = DateTime(year, month, dayNumber);
          weekCells.add(
            Expanded(
              child: _buildDayCell(
                date: date,
                dayNumber: dayNumber,
                now: now,
              ),
            ),
          );
        }
      }
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekCells,
          ),
        ),
      );
    }

    return Column(children: rows);
  }

  Widget _buildDayCell({
    required DateTime date,
    required int dayNumber,
    required DateTime now,
  }) {
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;

    final isSelected = widget.selectedDate != null &&
        widget.selectedDate!.year == date.year &&
        widget.selectedDate!.month == date.month &&
        widget.selectedDate!.day == date.day;

    // Marker rule: ONLY dates that have at least one COMPLETED booking get the red pencil circle
    final hasCompleted = BookingsRepository.instance.hasCompletedBookingOn(date);
    final totalBookings = BookingsRepository.instance.bookingCountOn(date);

    String semanticDescription = DateFormat('d MMMM yyyy').format(date);
    if (isToday) semanticDescription += ', today';
    if (hasCompleted) {
      semanticDescription += ', completed booking';
    } else if (totalBookings > 0) {
      semanticDescription += ', pending booking';
    }

    return Semantics(
      button: true,
      selected: isSelected,
      label: semanticDescription,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Tapping selects date; tapping already selected date toggles back to all
            if (isSelected) {
              widget.onDateSelected(null);
            } else {
              widget.onDateSelected(date);
            }
          },
          borderRadius: BorderRadius.circular(24),
          child: Container(
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            alignment: Alignment.center,
            child: SizedBox(
              width: 36,
              height: 36,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. Day background circle: Today = filled primary sage circle
                  if (isToday)
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: AppColors.sage,
                        shape: BoxShape.circle,
                      ),
                    ),

                  // 2. Outlined highlight for selected date
                  if (isSelected)
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.sageDark,
                          width: 2.0,
                        ),
                      ),
                    ),

                  // 3. Hand-drawn red pencil circle for dates with COMPLETED booking
                  if (hasCompleted)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: RedPencilCirclePainter(date: date),
                        ),
                      ),
                    ),

                  // 4. Day number text
                  Text(
                    '$dayNumber',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: isToday || isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: isToday
                          ? Colors.white
                          : (isSelected
                              ? AppColors.sageDark
                              : AppColors.textDark),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

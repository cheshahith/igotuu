import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/blurred_background_blobs.dart';
import '../../../widgets/frosted_glass.dart';
import '../data/bookings_repository.dart';
import '../domain/models/booking_model.dart';
import 'widgets/booking_card.dart';
import 'widgets/month_calendar_card.dart';

/// Bookings Screen - second tab in the persistent bottom navigation bar.
/// Displays today's date header, expandable month calendar with hand-drawn red pencil circles
/// on dates with completed bookings, and a reactive appointments list with date filtering.
class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  DateTime? _selectedDate;

  void _onDateSelected(DateTime? date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlurredBackgroundBlobs(
      child: SafeArea(
        bottom: false,
        child: ValueListenableBuilder<List<BookingModel>>(
          valueListenable: BookingsRepository.instance.bookingsNotifier,
          builder: (context, allBookings, _) {
            final filteredBookings = _selectedDate == null
                ? BookingsRepository.instance.getAllBookingsNewestFirst()
                : BookingsRepository.instance.getBookingsForDate(_selectedDate!);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              // Bottom padding ensures content scrolls well above the floating glass bar
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Title "Bookings" in signature igotuu script font
                  Text(
                    'Bookings',
                    style: AppTypography.logoScript(
                      fontSize: 32,
                      color: AppColors.sageDark,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2 & 3. Date Header & Month Calendar (in expandable glass card)
                  MonthCalendarCard(
                    selectedDate: _selectedDate,
                    onDateSelected: _onDateSelected,
                    initiallyExpanded: true,
                  ),

                  const SizedBox(height: 24),

                  // 4. Appointments Section Heading + "Show all" chip
                  _buildAppointmentsHeader(filteredBookings.length),

                  const SizedBox(height: 14),

                  // Appointments List or Empty State
                  if (filteredBookings.isEmpty)
                    _buildEmptyState()
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredBookings.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        return BookingCard(booking: filteredBookings[index]);
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppointmentsHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Text(
              'Appointments',
              style: AppTypography.logoScript(
                fontSize: 22,
                color: AppColors.sageDark,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.sage.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: AppTypography.label(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.sageDark,
                ),
              ),
            ),
          ],
        ),

        // "Show all" chip appears when a date filter is active
        if (_selectedDate != null)
          Semantics(
            button: true,
            label: 'Clear date filter and show all bookings',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _clearDateFilter,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 48),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.sageDark.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.sageDark.withValues(alpha: 0.28),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.filter_alt_off_rounded,
                        size: 14,
                        color: AppColors.sageDark,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Show all',
                        style: AppTypography.label(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.sageDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        else
          Text(
            'Newest first',
            style: AppTypography.bodySmall(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final dateStr = _selectedDate != null
        ? DateFormat('d MMMM yyyy').format(_selectedDate!)
        : 'this day';

    return FrostedGlass(
      borderRadius: 22,
      blurSigma: 16,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      fillColor: Colors.white.withValues(alpha: 0.32),
      borderColor: Colors.white.withValues(alpha: 0.58),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.sage.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_busy_rounded,
                size: 28,
                color: AppColors.sageDark,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'No bookings on this day',
              style: AppTypography.headingSmall(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No service visits were scheduled for $dateStr.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _clearDateFilter,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sageDark,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(140, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.calendar_month_rounded, size: 18),
              label: const Text(
                'View All Bookings',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

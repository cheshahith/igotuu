import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../widgets/frosted_glass.dart';
import '../../domain/models/booking_model.dart';

/// Glass card representing an individual appointment.
/// Displays provider avatar, name, trade, issue description, slot, hourly rate, and status chip.
class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onTap;

  const BookingCard({
    super.key,
    required this.booking,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Booking with ${booking.providerName}, ${booking.trade}, status ${booking.statusLabel}, scheduled ${booking.formattedDate} at ${booking.timeSlot}',
      child: FrostedGlass(
        borderRadius: 22,
        blurSigma: 18,
        padding: const EdgeInsets.all(16),
        fillColor: Colors.white.withValues(alpha: 0.35),
        borderColor: Colors.white.withValues(alpha: 0.62),
        onTap: onTap, // Tapping does nothing yet per prompt
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Row: Avatar initials + Provider Name + Trade + Status Chip
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Initials Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: booking.avatarColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.85),
                      width: 1.5,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1026332A),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      booking.initials,
                      style: AppTypography.headingSmall(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Trade
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.providerName,
                        style: AppTypography.headingSmall(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        booking.trade,
                        style: AppTypography.bodySmall(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Status Chip
                _buildStatusChip(),
              ],
            ),

            const SizedBox(height: 12),

            // Issue description
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.40),
                  width: 0.8,
                ),
              ),
              child: Text(
                booking.issue,
                style: AppTypography.bodySmall(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 12),

            // Bottom line: Date & Time slot + Price per hour
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Date and Time Slot
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: AppColors.sageDark,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${booking.formattedDate} • ${booking.timeSlot}',
                      style: AppTypography.bodySmall(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),

                // Price per hour
                Text(
                  booking.pricePerHour,
                  style: AppTypography.headingSmall(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.sageDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    if (booking.isCompleted) {
      // Completed: primary / sage-style chip with check icon
      return Container(
        constraints: const BoxConstraints(minHeight: 28),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.sage.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.sage.withValues(alpha: 0.45),
            width: 1,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 13,
              color: AppColors.sageDark,
            ),
            SizedBox(width: 4),
            Text(
              'Completed',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.sageDark,
              ),
            ),
          ],
        ),
      );
    } else {
      // Pending: warm accent chip with clock icon
      return Container(
        constraints: const BoxConstraints(minHeight: 28),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.starAmber.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.starAmber.withValues(alpha: 0.45),
            width: 1,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.hourglass_top_rounded,
              size: 13,
              color: Color(0xFFB57400),
            ),
            SizedBox(width: 4),
            Text(
              'Pending',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF9E6400),
              ),
            ),
          ],
        ),
      );
    }
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../widgets/frosted_glass.dart';
import '../../../nearby/presentation/nearby_workers_screen.dart';
import '../../domain/models/triage_result.dart';

/// Glass bottom sheet allowing users to manually choose their desired trade.
class ManualTradePickerModal extends StatelessWidget {
  final ValueChanged<TradeType>? onTradeSelected;

  const ManualTradePickerModal({
    super.key,
    this.onTradeSelected,
  });

  static Future<TradeType?> show(BuildContext context) {
    return showModalBottomSheet<TradeType>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const ManualTradePickerModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trades = [
      (TradeType.plumber, 'Plumber', 'Pipe leaks, taps, water drainage', Icons.plumbing_rounded),
      (TradeType.electrician, 'Electrician', 'Wiring, MCB switches, shocks, appliances', Icons.bolt_rounded),
      (TradeType.carpenter, 'Carpenter', 'Doors, furniture, locks, woodwork', Icons.carpenter_rounded),
      (TradeType.acRepair, 'AC Repair', 'Cooling, gas refill, servicing, filters', Icons.ac_unit_rounded),
      (TradeType.mechanic, 'Mechanic', 'Car/Bike engine, brakes, batteries, punctures', Icons.car_repair_rounded),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
      child: FrostedGlass(
        borderRadius: 28,
        blurSigma: 24,
        padding: const EdgeInsets.all(22),
        fillColor: Colors.white.withValues(alpha: 0.85),
        borderColor: Colors.white,
        shadows: const [
          BoxShadow(
            color: Color(0x2226332A),
            blurRadius: 30,
            offset: Offset(0, -6),
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textDark.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Heading
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.sage.withValues(alpha: 0.20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.handyman_rounded,
                    color: AppColors.sageDark,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Service Trade',
                        style: AppTypography.headingMedium(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        'Choose the specialist needed for your repair',
                        style: AppTypography.bodySmall(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Trade option list
            ...trades.map((item) {
              final type = item.$1;
              final title = item.$2;
              final desc = item.$3;
              final icon = item.$4;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop(type);
                    if (onTradeSelected != null) {
                      onTradeSelected!(type);
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => NearbyWorkersScreen(trade: title),
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.sage.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.sage.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: AppColors.sageDark, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: AppTypography.headingSmall(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              Text(
                                desc,
                                style: AppTypography.bodySmall(
                                  fontSize: 11.5,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: AppColors.textLight,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 6),

            // Close button
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textDark,
                  side: BorderSide(color: AppColors.textDark.withValues(alpha: 0.2)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../widgets/frosted_glass.dart';
import '../../../nearby/presentation/nearby_workers_screen.dart';
import '../../domain/models/triage_result.dart';
import 'manual_trade_picker_modal.dart';

/// Glassmorphic presentation of the AI Triage Result.
class AiTriageResultView extends StatefulWidget {
  final TriageResult result;
  final ValueChanged<String>? onFollowUpSubmitted;
  final VoidCallback? onReset;

  const AiTriageResultView({
    super.key,
    required this.result,
    this.onFollowUpSubmitted,
    this.onReset,
  });

  @override
  State<AiTriageResultView> createState() => _AiTriageResultViewState();
}

class _AiTriageResultViewState extends State<AiTriageResultView> {
  final TextEditingController _followUpController = TextEditingController();
  bool _isSubmittingFollowUp = false;

  @override
  void dispose() {
    _followUpController.dispose();
    super.dispose();
  }

  void _submitFollowUp() {
    final text = _followUpController.text.trim();
    if (text.isEmpty) return;
    setState(() => _isSubmittingFollowUp = true);
    widget.onFollowUpSubmitted?.call(text);
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final isUnknownOrLow = result.isUnknownOrLowConfidence;
    final tradeName = result.trade == TradeType.unknown
        ? 'Specialist'
        : result.trade.displayName;

    return FrostedGlass(
      borderRadius: 22,
      blurSigma: 18,
      padding: const EdgeInsets.all(18),
      fillColor: Colors.white.withValues(alpha: 0.62),
      borderColor: AppColors.sage.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Trade Diagnosis + Urgency Chip
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.sage.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.sage.withValues(alpha: 0.40),
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  result.trade.icon,
                  color: AppColors.sageDark,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Looks like a $tradeName problem',
                      style: AppTypography.headingSmall(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Confidence: ${result.confidence.name.toUpperCase()}',
                      style: AppTypography.bodySmall(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Urgency Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: result.urgency.badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: result.urgency.badgeColor.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  result.urgency.displayName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: result.urgency.badgeColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Problem Summary (User's language)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              result.summary.isNotEmpty ? result.summary : result.summaryEn,
              style: AppTypography.bodyMedium(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
          ),

          // Safety Tip Box (if present)
          if (result.safetyTip != null && result.safetyTip!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFFFB74D),
                  width: 1.2,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFE65100),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Safety Precaution',
                          style: AppTypography.headingSmall(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFE65100),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          result.safetyTip!,
                          style: AppTypography.bodySmall(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF7A3600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Follow-up Question Box (if unknown or low confidence)
          if (isUnknownOrLow &&
              result.followUpQuestion != null &&
              result.followUpQuestion!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.sage.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.sage.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.help_outline_rounded,
                        size: 16,
                        color: AppColors.sageDark,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Follow-up clarification:',
                        style: AppTypography.headingSmall(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.sageDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result.followUpQuestion!,
                    style: AppTypography.bodySmall(
                      fontSize: 12.5,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _followUpController,
                          style: AppTypography.bodySmall(
                            fontSize: 12.5,
                            color: AppColors.textDark,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Type answer to clarify...',
                            hintStyle: AppTypography.bodySmall(
                              fontSize: 12,
                              color: AppColors.textLight,
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 34,
                        child: ElevatedButton(
                          onPressed: _isSubmittingFollowUp ? null : _submitFollowUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.sageDark,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: _isSubmittingFollowUp
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Update', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Action Buttons: "Find <trade>s near me" & "Not right? Choose manually"
          Row(
            children: [
              Expanded(
                flex: 6,
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final tradeTarget = result.trade == TradeType.unknown
                          ? 'Electrician'
                          : result.trade.displayName;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => NearbyWorkersScreen(trade: tradeTarget),
                        ),
                      );
                    },
                    icon: const Icon(Icons.near_me_rounded, size: 16),
                    label: Text(
                      'Find ${result.trade == TradeType.unknown ? 'Workers' : '${result.trade.displayName}s'} near me',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
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
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () => ManualTradePickerModal.show(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textDark,
                      side: BorderSide(
                        color: AppColors.textDark.withValues(alpha: 0.25),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Choose manually',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                    ),
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

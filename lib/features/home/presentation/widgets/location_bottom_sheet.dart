import 'package:flutter/material.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../widgets/frosted_glass.dart';

class LocationBottomSheet extends StatefulWidget {
  final String currentAddress;
  final ValueChanged<String> onAddressSaved;

  const LocationBottomSheet({
    super.key,
    required this.currentAddress,
    required this.onAddressSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required String currentAddress,
    required ValueChanged<String> onAddressSaved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LocationBottomSheet(
        currentAddress: currentAddress,
        onAddressSaved: onAddressSaved,
      ),
    );
  }

  @override
  State<LocationBottomSheet> createState() => _LocationBottomSheetState();
}

class _LocationBottomSheetState extends State<LocationBottomSheet> {
  late final TextEditingController _addressController;
  bool _isLoadingGps = false;
  String? _statusMessage;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.currentAddress);
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleUseCurrentLocation() async {
    setState(() {
      _isLoadingGps = true;
      _statusMessage = 'Acquiring GPS location...';
      _isError = false;
    });

    final result = await LocationService.instance.fetchCurrentLocationAddress();

    if (!mounted) return;

    if (result.success && result.address != null) {
      setState(() {
        _isLoadingGps = false;
        _addressController.text = result.address!;
        _statusMessage = 'Location detected successfully!';
        _isError = false;
      });
    } else {
      setState(() {
        _isLoadingGps = false;
        _statusMessage = result.errorMessage ?? 'Failed to get location';
        _isError = true;
      });
    }
  }

  Future<void> _handleSave() async {
    final text = _addressController.text.trim();
    if (text.isEmpty) return;

    await LocationService.instance.saveAddress(text);
    widget.onAddressSaved(text);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Address updated: $text'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: mediaQuery.viewInsets.bottom + 24,
        left: 20,
        right: 20,
        top: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2226332A),
            blurRadius: 30,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle pill
            Center(
              child: Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.textDark.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // Sheet title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.sage.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.sageDark,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service Location',
                        style: AppTypography.headingMedium(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Where do you need assistance?',
                        style: AppTypography.bodySmall(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Option 1: "Use current location" button
            FrostedGlass(
              borderRadius: 20,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              fillColor: AppColors.lightSage.withValues(alpha: 0.35),
              borderColor: AppColors.sage.withValues(alpha: 0.35),
              onTap: _isLoadingGps ? null : _handleUseCurrentLocation,
              semanticLabel: 'Use current GPS location',
              child: SizedBox(
                height: 48,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isLoadingGps)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation(AppColors.sageDark),
                        ),
                      )
                    else
                      const Icon(
                        Icons.my_location_rounded,
                        color: AppColors.sageDark,
                        size: 20,
                      ),
                    const SizedBox(width: 10),
                    Text(
                      _isLoadingGps
                          ? 'Detecting GPS...'
                          : 'Use current location',
                      style: AppTypography.label(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.sageDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Status or Error message
            if (_statusMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _isError
                      ? Colors.red.withValues(alpha: 0.08)
                      : AppColors.sage.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isError
                        ? Colors.red.withValues(alpha: 0.25)
                        : AppColors.sage.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isError ? Icons.info_outline_rounded : Icons.check_circle_outline_rounded,
                      size: 16,
                      color: _isError ? Colors.red.shade700 : AppColors.sageDark,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _statusMessage!,
                        style: AppTypography.bodySmall(
                          fontSize: 12,
                          color: _isError ? Colors.red.shade800 : AppColors.sageDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 18),

            // Or enter manually divider
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: AppColors.textDark.withValues(alpha: 0.12),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'OR TYPE MANUALLY',
                    style: AppTypography.label(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: AppColors.textDark.withValues(alpha: 0.12),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Textfield for manual address
            FrostedGlass(
              borderRadius: 18,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              fillColor: Colors.white.withValues(alpha: 0.7),
              borderColor: AppColors.textDark.withValues(alpha: 0.12),
              child: TextField(
                controller: _addressController,
                style: AppTypography.bodyMedium(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  icon: const Icon(
                    Icons.edit_location_alt_outlined,
                    color: AppColors.sageDark,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  hintText: 'Enter street, apartment, city...',
                  hintStyle: AppTypography.bodyMedium(
                    fontSize: 14,
                    color: AppColors.textLight,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sageDark,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  'Save Address',
                  style: AppTypography.label(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

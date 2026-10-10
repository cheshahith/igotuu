import 'package:flutter/material.dart';

/// App color palette for igotuu
/// Follows the design specifications:
/// - #FEFAF3 (page background)
/// - #F6E2E9 (soft pink)
/// - #B8CFB3 (light sage)
/// - #84A282 (sage, primary)
/// - #26332A (text primary)
/// - #3F5A3E (icons and active states)
class AppColors {
  AppColors._();

  // Primary Palette
  static const Color background = Color(0xFFFEFAF3); // Cream page background
  static const Color softPink = Color(0xFFF6E2E9); // Soft pink for blobs & accents
  static const Color lightSage = Color(0xFFB8CFB3); // Light sage for blobs & highlights
  static const Color sage = Color(0xFF84A282); // Sage primary
  static const Color sageDark = Color(0xFF3F5A3E); // Active states, icon accents
  static const Color textDark = Color(0xFF26332A); // High-contrast primary text
  static const Color textMuted = Color(0xFF5A6E5E); // Secondary/label text
  static const Color textLight = Color(0xFF8B9E8F); // Placeholder / subtle text

  // Glassmorphic Values
  static Color glassFill = Colors.white.withValues(alpha: 0.32);
  static Color glassBorder = Colors.white.withValues(alpha: 0.52);
  static Color glassHighlight = Colors.white.withValues(alpha: 0.70);
  static const Color glassShadow = Color(0x1226332A);

  // Status & Accents
  static const Color starAmber = Color(0xFFE5A122);
  static const Color verifiedGreen = Color(0xFF2E7D32);
  static const Color recordingRed = Color(0xFFE05353);
  static const Color cardWhite = Colors.white;
}

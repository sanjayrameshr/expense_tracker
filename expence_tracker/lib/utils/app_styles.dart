import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Soft UI Design System - Modern neumorphic styles
class SoftUI {
  // Color Palette
  static const softBackground = Color(0xFFF8F9FB); // Changed to match AppColors
  static const softCard = Color(0xFFFFFFFF);

  // --- Modern, subtle shadow (replaces old SoftUI) ---
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      offset: const Offset(0, 4),
      blurRadius: 12,
    ),
  ];

  // --- Inset shadow (unchanged) ---
  static List<BoxShadow> softShadowInset = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      offset: const Offset(4, 4),
      blurRadius: 8,
      spreadRadius: -2,
    ),
  ];

  // Card decoration
  static BoxDecoration cardDecoration({Color? color}) => BoxDecoration(
        color: color ?? softCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: softShadow,
      );

  // Gradient card decoration
  static BoxDecoration gradientCardDecoration(Gradient gradient) =>
      BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      );

  // Text styles
  static const heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Color(0xFF2D3142),
    letterSpacing: -0.5,
  );

  static const heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: Color(0xFF2D3142),
    letterSpacing: -0.3,
  );

  static const subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Color(0xFF8E9AAF),
  );

  static const body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: Color(0xFF4A5568),
  );

  static const caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Color(0xFF9CA3AF),
  );
}

/// Consistent button styles for the app
class AppButtonStyles {
  /// Primary elevated button style (blue)
  static ButtonStyle primaryElevated = ElevatedButton.styleFrom(
    backgroundColor: AppColors.buttonPrimary,
    foregroundColor: AppColors.buttonText,
    elevation: 2,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );

  /// Large primary button style
  static ButtonStyle primaryLarge = ElevatedButton.styleFrom(
    backgroundColor: AppColors.buttonPrimary,
    foregroundColor: AppColors.buttonText,
    elevation: 2,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  /// Secondary elevated button style (grey)
  static ButtonStyle secondaryElevated = ElevatedButton.styleFrom(
    backgroundColor: AppColors.buttonSecondary,
    foregroundColor: AppColors.buttonText,
    elevation: 2,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );

  /// Text button style
  static ButtonStyle textButton = TextButton.styleFrom(
    foregroundColor: AppColors.textSecondary,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  );

  /// Floating action button background color
  static Color fabBackground = AppColors.buttonPrimary;

  /// Floating action button icon color
  static Color fabIconColor = AppColors.iconLight;

  // Private constructor
  AppButtonStyles._();
}

import 'package:flutter/material.dart';
import 'app_colors.dart';

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

import 'package:flutter/material.dart';

/// App-wide color constants for consistent theming
class AppColors {
  // Primary Colors
  static final Color primary = Colors.blue.shade700;
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF42A5F5);

  // Background Colors
  static const Color background = Color(0xFFF8F9FB);
  static const Color cardBackground = Colors.white;
  static final Color surfaceLight = Colors.grey.shade50;

  // Text Colors
  static final Color textPrimary = Colors.grey.shade900;
  static final Color textSecondary = Colors.grey.shade700;
  static final Color textTertiary = Colors.grey.shade600;
  static final Color textDisabled = Colors.grey.shade400;

  // Button Colors
  static final Color buttonPrimary = Colors.blue.shade700;
  static final Color buttonSecondary = Colors.grey.shade800;
  static const Color buttonText = Colors.white;

  // Status Colors
  static final Color success = Colors.green.shade400;
  static final Color warning = Colors.orange.shade400;
  static final Color error = Colors.red.shade400;
  static final Color info = Colors.blue.shade400;

  // Category Colors
  static final Color loansColor = const Color(0xFFBFAE8D);
  static final Color feesColor = const Color(0xFFA7B6C2);
  static final Color expenseColor = const Color(0xFF7D8C9E);
  static final Color trendColor = const Color(0xFF8CA08C);
  static final Color statsColor = const Color(0xFF9B9DB4);

  // Gradient Colors
  static const List<Color> balanceGradient = [
    Color(0xFFBCCCDC),
    Color(0xFFD9E2EC),
  ];

  // Border Colors
  static final Color borderLight = Colors.grey.shade200;
  static final Color borderMedium = Colors.grey.shade300;

  // Icon Colors
  static final Color iconPrimary = Colors.grey.shade700;
  static final Color iconSecondary = Colors.grey.shade500;
  static const Color iconLight = Colors.white;

  // Navigation Colors
  static final Color navActive = Colors.blue.shade700;
  static final Color navInactive = Colors.grey.shade500;

  // Private constructor to prevent instantiation
  AppColors._();
}

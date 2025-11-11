import 'package:flutter/material.dart';

/// App-wide color constants for consistent theming
class AppColors {
  // --- Primary Palette ---
  static final Color primary = Colors.blue.shade700;
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF42A5F5);

  // --- UI Elements ---
  static const Color background = Color(0xFFF8F9FB);
  static const Color cardBackground = Colors.white;
  static final Color surfaceLight = Colors.grey.shade50;

  // --- Text ---
  static final Color textPrimary = Colors.grey.shade900;
  static final Color textSecondary = Colors.grey.shade700;
  static final Color textTertiary = Colors.grey.shade600;
  static final Color textDisabled = Colors.grey.shade400;

  // --- Buttons ---
  static final Color buttonPrimary = Colors.blue.shade700;
  static final Color buttonSecondary = Colors.grey.shade800;
  static const Color buttonText = Colors.white;

  // --- Navigation ---
  static final Color navActive = Colors.blue.shade700;
  static final Color navInactive = Colors.grey.shade500;

  // --- Status & Semantic ---
  static final Color success = Colors.green.shade400;
  static final Color warning = Colors.orange.shade400;
  static final Color error = Colors.red.shade400;
  static final Color info = Colors.blue.shade400;

  // --- Icon ---
  static final Color iconPrimary = Colors.grey.shade700;
  static final Color iconSecondary = Colors.grey.shade500;
  static const Color iconLight = Colors.white;

  // --- Gradients ---
  static const List<Color> balanceGradient = [
    Color(0xFF42A5F5), // blue.shade400
    Color(0xFF1565C0), // blue.shade800
  ];

  // --- Borders ---
  static final Color borderLight = Colors.grey.shade200;
  static final Color borderMedium = Colors.grey.shade300;

  // --- App-Specific Categories ---
  static final Color loansColor = const Color(0xFFBFAE8D);
  static final Color feesColor = const Color(0xFFA7B6C2);
  static final Color expenseColor = const Color(0xFF7D8C9E);
  static final Color trendColor = const Color(0xFF8CA08C);
  static final Color statsColor = const Color(0xFF9B9DB4);

  // Private constructor to prevent instantiation
  AppColors._();
}

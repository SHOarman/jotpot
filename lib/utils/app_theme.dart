import 'package:flutter/material.dart';

class AppColors {
  // Vibrant Brand Orange from screenshots
  static const Color primaryOrange = Color(0xFFFF7A00);
  static const Color primary = Color(0xFFFF7A00);
  static const Color primaryDark = Color(0xFF111827);

  // Notice Bar Colors
  static const Color noticeRed = Color(0xFFDC2626);
  static const Color noticeBadgeRed = Color(0xFF991B1B);

  // Renew License & Badge Peach Colors
  static const Color renewBg = Color(0xFFFEE0C4); // Deeper warm peach
  static const Color renewBorder = Color(0xFFFED7AA);
  static const Color renewText = Color(0xFFEA580C);

  // Neutral Colors (Soft grey canvas so pure white cards pop and float)
  static const Color background = Color(0xFFF4F6F9);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFEDF2F7);
  static const Color textDark = Color(0xFF111827);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textBody = Color(0xFF4B5563);
  static const Color textHint = Color(0xFF9CA3AF);

  // Action / Accent Colors
  static const Color locationRed = Color(0xFFEF4444);
  static const Color infoTeal = Color(0xFF64748B);

  static const List<int> noteColors = [
    0xFFFF7A00,
    0xFF6366F1,
    0xFF10B981,
  ];
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryOrange,
        primary: AppColors.primaryOrange,
        surface: AppColors.background,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryOrange,
        strokeWidth: 4.0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textDark),
      ),
    );
  }
}


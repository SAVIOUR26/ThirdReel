import 'package:flutter/material.dart';

import 'colors.dart';

/// Font weights: regular and medium only — see SPEC.md section 5.
abstract final class AppTypography {
  static const regular = FontWeight.w400;
  static const medium = FontWeight.w500;

  static TextTheme textTheme() {
    return const TextTheme(
      headlineLarge: TextStyle(
        fontWeight: medium,
        fontSize: 28,
        color: AppColors.cream,
      ),
      headlineMedium: TextStyle(
        fontWeight: medium,
        fontSize: 22,
        color: AppColors.cream,
      ),
      titleMedium: TextStyle(
        fontWeight: medium,
        fontSize: 16,
        color: AppColors.cream,
      ),
      bodyLarge: TextStyle(
        fontWeight: regular,
        fontSize: 16,
        color: AppColors.cream,
      ),
      bodyMedium: TextStyle(
        fontWeight: regular,
        fontSize: 14,
        color: AppColors.muted,
      ),
      bodySmall: TextStyle(
        fontWeight: regular,
        fontSize: 12,
        color: AppColors.mutedDark,
      ),
      labelLarge: TextStyle(
        fontWeight: medium,
        fontSize: 16,
        color: AppColors.navy,
      ),
    );
  }
}

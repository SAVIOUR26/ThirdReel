import 'package:flutter/material.dart';

import 'core/theme/colors.dart';
import 'core/theme/typography.dart';
import 'features/splash/splash_screen.dart';

class ThirdReelApp extends StatelessWidget {
  const ThirdReelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThirdReel',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const SplashScreen(),
    );
  }

  ThemeData _buildTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.gold,
      brightness: Brightness.dark,
      primary: AppColors.gold,
      onPrimary: AppColors.navy,
      surface: AppColors.navyLight,
      onSurface: AppColors.cream,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.navy,
      colorScheme: colorScheme,
      fontFamily: null,
      textTheme: AppTypography.textTheme(),
      // Flat fills, no gradients, no drop shadows — SPEC.md section 5.
      cardTheme: const CardThemeData(
        color: AppColors.navyLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          side: BorderSide(color: AppColors.navyBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.navy,
          elevation: 0,
          shadowColor: Colors.transparent,
          textStyle: const TextStyle(
            fontWeight: AppTypography.medium,
            fontSize: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.muted),
      dividerColor: AppColors.navyBorder,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.navy,
        elevation: 0,
        foregroundColor: AppColors.cream,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  /// Font dikemas di dalam aplikasi (assets/fonts) agar tidak perlu internet.
  static TextStyle heading(double size, {Color color = AppColors.brown}) => TextStyle(
        fontFamily: 'Lora',
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: color,
        height: 1.15,
        fontVariations: const [FontVariation('wght', 800)],
      );

  static OutlineInputBorder _border(Color c, double w) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: c, width: w),
      );

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'Nunito',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.terracotta,
        primary: AppColors.terracotta,
        secondary: AppColors.forest,
        surface: AppColors.cream,
      ),
      // Transparan: latar bermotif dipasang oleh AppBackdrop pada setiap halaman.
      scaffoldBackgroundColor: Colors.transparent,
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: 'Nunito',
        bodyColor: AppColors.brown,
        displayColor: AppColors.brown,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.brown,
        titleTextStyle: heading(20),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: _border(AppColors.sand, 1.5),
        enabledBorder: _border(AppColors.sand, 1.5),
        focusedBorder: _border(AppColors.terracotta, 2),
        errorBorder: _border(AppColors.error, 1.5),
        focusedErrorBorder: _border(AppColors.error, 2),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.brown,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

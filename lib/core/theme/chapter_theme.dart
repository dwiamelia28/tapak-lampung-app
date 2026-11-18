import 'package:flutter/material.dart';
import 'app_colors.dart';

class ChapterTheme {
  const ChapterTheme(this.color, this.icon);
  final Color color;
  final IconData icon;

  static ChapterTheme of(String key) {
    switch (key) {
      case 'kain':
        return const ChapterTheme(AppColors.maroon, Icons.checkroom);
      case 'seni':
        return const ChapterTheme(AppColors.forest, Icons.music_note);
      case 'kuliner':
        return const ChapterTheme(Color(0xFFB8741A), Icons.restaurant);
      default:
        return const ChapterTheme(AppColors.terracotta, Icons.home_work);
    }
  }
}

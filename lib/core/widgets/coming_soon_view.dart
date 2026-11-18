import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import 'guide_character.dart';

/// Placeholder jujur untuk fitur yang dibangun di tahap berikutnya.
class ComingSoonView extends StatelessWidget {
  const ComingSoonView({super.key, required this.title, required this.note});
  final String title;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GuideCharacter(isFemale: true, width: 120),
            const SizedBox(height: 16),
            Text(title, style: AppTheme.heading(22), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              note,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.brownSoft, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.title, required this.note});
  final String title;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ComingSoonView(title: title, note: note),
    );
  }
}

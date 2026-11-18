import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/adventure_scene.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AdventureScene(height: 170),
              const SizedBox(height: 22),
              Text(title, style: AppTheme.heading(28)),
              const SizedBox(height: 6),
              Text(subtitle, style: const TextStyle(color: AppColors.brownSoft)),
              const SizedBox(height: 20),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'guide_character.dart';
import 'primary_button.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator(color: AppColors.terracotta));
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, this.message, this.onRetry});
  final String? message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 56, color: AppColors.brownSoft),
              const SizedBox(height: 12),
              Text('Oops, ada kendala', style: AppTheme.heading(20)),
              const SizedBox(height: 8),
              Text(
                message ?? 'Data belum bisa dimuat. Periksa koneksi internet lalu coba lagi.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.brownSoft),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 18),
                SizedBox(width: 180, child: PrimaryButton(label: 'Coba Lagi', onPressed: onRetry)),
              ],
            ],
          ),
        ),
      );
}

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.title, required this.note, this.action});
  final String title;
  final String note;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const GuideCharacter(isFemale: true, width: 110),
              const SizedBox(height: 14),
              Text(title, textAlign: TextAlign.center, style: AppTheme.heading(21)),
              const SizedBox(height: 8),
              Text(note,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.brownSoft, height: 1.4)),
              if (action != null) ...[const SizedBox(height: 18), action!],
            ],
          ),
        ),
      );
}

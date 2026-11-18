import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/chapter_theme.dart';
import '../../core/widgets/reveal.dart';
import '../../core/widgets/state_views.dart';
import '../../models/progress_model.dart';
import '../../providers/content_providers.dart';
import '../../providers/providers.dart';

enum PickerMode { challenge, quiz }

/// Daftar bab untuk akses cepat Tantangan / Kuis dari beranda.
class ChapterPickerScreen extends ConsumerWidget {
  const ChapterPickerScreen({super.key, required this.mode});
  final PickerMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isQuiz = mode == PickerMode.quiz;
    final chapters = ref.watch(chaptersProvider);
    final progress = ref.watch(progressProvider).valueOrNull ?? const ProgressModel();

    return Scaffold(
      appBar: AppBar(title: Text(isQuiz ? 'Pilih Kuis' : 'Pilih Tantangan')),
      body: chapters.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(onRetry: () => ref.invalidate(chaptersProvider)),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyView(
              title: 'Belum ada bab',
              note: 'Konten belum tersedia. Jalankan skrip data awal atau hubungi admin.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final c = list[i];
              final th = ChapterTheme.of(c.theme);
              final locked = i != 0 && !progress.unlockedChapterIds.contains(c.id);
              final done = progress.completedChapterIds.contains(c.id);
              return Reveal(
                index: i,
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () {
                      if (locked) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bab ini masih terkunci.')),
                        );
                        return;
                      }
                      context.push('/chapter/${c.id}/${isQuiz ? 'quiz' : 'challenge'}');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.sand, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: (locked ? Colors.grey : th.color).withValues(alpha: .14),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(locked ? Icons.lock : th.icon,
                                color: locked ? Colors.grey : th.color),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Bab ${c.order}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.brownSoft)),
                                Text(c.title, style: AppTheme.heading(16)),
                              ],
                            ),
                          ),
                          if (done)
                            const Icon(Icons.check_circle, color: AppColors.success)
                          else
                            const Icon(Icons.chevron_right, color: AppColors.brownSoft),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

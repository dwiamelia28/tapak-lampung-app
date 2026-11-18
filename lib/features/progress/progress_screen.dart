import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/achievements.dart';
import '../../core/illustrations/ornaments.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/chapter_theme.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/badge_medal.dart';
import '../../core/widgets/reveal.dart';
import '../../core/widgets/state_views.dart';
import '../../models/progress_model.dart';
import '../../providers/content_providers.dart';
import '../../providers/providers.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key, this.embedded = true});
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressProvider);
    final chapters = ref.watch(chaptersProvider).valueOrNull ?? const [];
    final results = ref.watch(quizResultsProvider);

    final body = progressAsync.when(
      loading: () => const LoadingView(),
      error: (e, _) => ErrorView(onRetry: () => ref.invalidate(progressProvider)),
      data: (p) {
        final titles = {for (final c in chapters) c.id: c.title};
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Text('Jejak Perjalanan', style: AppTheme.heading(26)),
            const SizedBox(height: 14),
            Reveal(child: _LevelCard(progress: p)),
            const SizedBox(height: 22),
            const SectionTitle('Perjalanan Budaya'),
            const SizedBox(height: 12),
            if (chapters.isEmpty)
              const Text('Belum ada bab yang tersedia.',
                  style: TextStyle(color: AppColors.brownSoft))
            else
              for (var i = 0; i < chapters.length; i++)
                _PathRow(
                  index: i,
                  isLast: i == chapters.length - 1,
                  title: chapters[i].title,
                  order: chapters[i].order,
                  icon: ChapterTheme.of(chapters[i].theme).icon,
                  done: p.completedChapterIds.contains(chapters[i].id),
                  locked: i != 0 && !p.unlockedChapterIds.contains(chapters[i].id),
                ),
            const SizedBox(height: 22),
            const SectionTitle('Lencana'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final a in Achievements.all)
                  SizedBox(
                    width: 96,
                    child: Column(
                      children: [
                        BadgeMedal(
                            def: a, unlocked: p.achievements.contains(a.id), size: 60),
                        const SizedBox(height: 6),
                        Text(a.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            const SectionTitle('Riwayat Aktivitas'),
            const SizedBox(height: 12),
            results.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator(color: AppColors.terracotta)),
              ),
              error: (e, _) => const Text('Riwayat belum bisa dimuat.'),
              data: (list) {
                if (list.isEmpty) {
                  return const Text('Belum ada kuis yang dikerjakan.',
                      style: TextStyle(color: AppColors.brownSoft));
                }
                return Column(
                  children: [
                    for (final r in list.take(10))
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.sand, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: (r.score >= 60 ? AppColors.success : AppColors.error)
                                  .withValues(alpha: .14),
                              child: Text('${r.score}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: r.score >= 60 ? AppColors.success : AppColors.error)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Kuis ${titles[r.chapterId] ?? r.chapterId}',
                                      style: const TextStyle(fontWeight: FontWeight.w800)),
                                  Text(
                                    '${r.correctAnswers}/${r.totalQuestions} benar  |  ${formatDate(r.completedAt)}',
                                    style: const TextStyle(
                                        fontSize: 12, color: AppColors.brownSoft),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );

    if (embedded) return body;
    return Scaffold(appBar: AppBar(title: const Text('Jejak Perjalanan')), body: body);
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.progress});
  final ProgressModel progress;
  @override
  Widget build(BuildContext context) {
    final into = progress.xpIntoLevel;
    final level = progress.totalXp ~/ AppConstants.xpPerLevel + 1;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD9744A), AppColors.terracotta],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.terracotta.withValues(alpha: .35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: into / AppConstants.xpPerLevel),
            duration: const Duration(milliseconds: 1100),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => SizedBox(
              width: 96,
              height: 96,
              child: CustomPaint(
                painter: _RingPainter(v),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('LEVEL',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800)),
                      Text('$level',
                          style: AppTheme.heading(32, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${progress.totalXp} XP total',
                    style: AppTheme.heading(20, color: Colors.white)),
                const SizedBox(height: 4),
                Text('$into / ${AppConstants.xpPerLevel} XP menuju level berikutnya',
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                Text(
                  '${progress.completedCount}/${AppConstants.totalChapters} bab selesai',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value);
  final double value;
  @override
  void paint(Canvas canvas, Size s) {
    final c = s.center(Offset.zero);
    final r = s.width / 2 - 7;
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..color = Colors.white.withValues(alpha: .25);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..color = AppColors.goldLight;
    canvas.drawCircle(c, r, base);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -math.pi / 2,
        2 * math.pi * value.clamp(0.0, 1.0), false, arc);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.value != value;
}

class _PathRow extends StatelessWidget {
  const _PathRow({
    required this.index,
    required this.isLast,
    required this.title,
    required this.order,
    required this.icon,
    required this.done,
    required this.locked,
  });
  final int index;
  final bool isLast;
  final String title;
  final int order;
  final IconData icon;
  final bool done;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final color = done ? AppColors.success : (locked ? Colors.grey : AppColors.terracotta);
    return Reveal(
      index: index,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 44,
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(color: color.withValues(alpha: .4), blurRadius: 8),
                      ],
                    ),
                    child: Icon(done ? Icons.check : (locked ? Icons.lock : icon),
                        color: Colors.white, size: 20),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 4,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: done ? AppColors.success : AppColors.sand,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14, top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bab $order',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w800, color: color)),
                    Text(title, style: AppTheme.heading(16)),
                    Text(done ? 'Selesai' : (locked ? 'Terkunci' : 'Sedang dijelajahi'),
                        style: const TextStyle(fontSize: 12, color: AppColors.brownSoft)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

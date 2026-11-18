import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/photo_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/photo_image.dart';
import '../../core/widgets/state_views.dart';
import '../../models/study_model.dart';
import '../../providers/content_providers.dart';
import '../../providers/planner_providers.dart';
import '../../providers/providers.dart';

/// Daftar Belajar Budaya: daftar referensi pribadi yang menunjuk ke topik materi
/// yang sudah ada (isi materi tidak disalin).
class StudyScreen extends ConsumerWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Daftar Belajar Budaya'),
          bottom: const TabBar(
            labelColor: AppColors.terracotta,
            indicatorColor: AppColors.terracotta,
            tabs: [Tab(text: 'Daftar Saya'), Tab(text: 'Semua Materi')],
          ),
        ),
        body: const TabBarView(children: [_MyList(), _AllTopics()]),
      ),
    );
  }
}

class _MyList extends ConsumerWidget {
  const _MyList();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(studyItemsProvider);
    final topics = ref.watch(studyTopicsProvider);
    final svc = ref.read(plannerServiceProvider);
    return items.when(
      loading: () => const LoadingView(),
      error: (e, _) => ErrorView(onRetry: () => ref.invalidate(studyItemsProvider)),
      data: (list) {
        if (list.isEmpty) {
          return const EmptyView(
            title: 'Daftar belajarmu masih kosong',
            note: 'Buka tab "Semua Materi" lalu tambahkan topik budaya yang ingin kamu pelajari.',
          );
        }
        final byKey = {for (final t in topics.valueOrNull ?? <StudyTopic>[]) t.key: t};
        final learned = list.where((i) => i.learned).length;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.sand),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Progres belajar', style: AppTheme.heading(16)),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: learned / list.length,
                    minHeight: 10,
                    color: AppColors.forest,
                    backgroundColor: AppColors.sand,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 8),
                  Text('$learned dari ${list.length} materi sudah dipelajari',
                      style: const TextStyle(color: AppColors.brownSoft)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            for (final it in list)
              Builder(builder: (_) {
                final t = byKey['${it.chapterId}_${it.topicId}'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.sand),
                  ),
                  child: ListTile(
                    onTap: () => context.push('/chapter/${it.chapterId}'),
                    leading: Checkbox(
                      value: it.learned,
                      activeColor: AppColors.forest,
                      onChanged: (v) => svc.setLearned(it.id, v ?? false),
                    ),
                    title: Text(t?.title ?? it.topicId,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          decoration: it.learned ? TextDecoration.lineThrough : null,
                        )),
                    subtitle: Text(t == null ? 'Materi tidak ditemukan' : 'Bab ${t.chapterOrder}: ${t.chapterTitle}'),
                    trailing: IconButton(
                      tooltip: 'Hapus dari daftar',
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: () => svc.removeStudy(it.id),
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}

class _AllTopics extends ConsumerWidget {
  const _AllTopics();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topics = ref.watch(studyTopicsProvider);
    final items = ref.watch(studyItemsProvider).valueOrNull ?? const [];
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    final svc = ref.read(plannerServiceProvider);
    final chapters = ref.watch(chaptersProvider).valueOrNull ?? const [];

    return topics.when(
      loading: () => const LoadingView(),
      error: (e, _) => ErrorView(onRetry: () {
        ref.invalidate(allContentsProvider);
        ref.invalidate(chaptersProvider);
      }),
      data: (all) {
        if (all.isEmpty) {
          return const EmptyView(
            title: 'Materi belum tersedia',
            note: 'Jalankan skrip data awal agar materi budaya tampil di sini.',
          );
        }
        final inList = {for (final i in items) '${i.chapterId}_${i.topicId}': i};
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            for (final c in chapters)
              if (all.any((t) => t.chapterId == c.id)) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 8),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 46,
                          height: 46,
                          child: PhotoImage(CulturePhotos.forTheme(c.theme), compact: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Bab ${c.order}',
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.terracotta)),
                            Text(c.title, style: AppTheme.heading(16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                for (final t in all.where((t) => t.chapterId == c.id))
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.sand),
                    ),
                    child: ListTile(
                      title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text(t.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: inList.containsKey(t.key)
                          ? IconButton(
                              tooltip: 'Hapus dari daftar',
                              icon: const Icon(Icons.check_circle, color: AppColors.forest),
                              onPressed: () => svc.removeStudy(inList[t.key]!.id),
                            )
                          : IconButton(
                              tooltip: 'Tambah ke daftar belajar',
                              icon: const Icon(Icons.add_circle_outline, color: AppColors.terracotta),
                              onPressed: uid == null
                                  ? null
                                  : () => svc.addStudy(uid, t.chapterId, t.topicId),
                            ),
                    ),
                  ),
              ],
          ],
        );
      },
    );
  }
}

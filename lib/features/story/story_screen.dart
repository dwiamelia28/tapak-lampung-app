import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/chapter_guard.dart';
import '../../core/widgets/chapter_scene.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/reveal.dart';
import '../../core/widgets/state_views.dart';
import '../../models/content_model.dart';
import '../../providers/content_providers.dart';
import '../../providers/providers.dart';

class StoryScreen extends StatelessWidget {
  const StoryScreen({super.key, required this.chapterId});
  final String chapterId;

  @override
  Widget build(BuildContext context) => ChapterGuard(
        chapterId: chapterId,
        builder: (_) => _StoryBody(chapterId: chapterId),
      );
}

class _StoryBody extends ConsumerStatefulWidget {
  const _StoryBody({required this.chapterId});
  final String chapterId;
  @override
  ConsumerState<_StoryBody> createState() => _StoryBodyState();
}

class _StoryBodyState extends ConsumerState<_StoryBody> {
  final Set<String> _found = {};
  bool _marked = false;

  void _markVisited() {
    if (_marked) return;
    _marked = true;
    final u = ref.read(authStateProvider).valueOrNull;
    if (u != null) {
      ref.read(progressServiceProvider).setLastChapter(u.uid, widget.chapterId);
    }
  }

  void _openHotspot(Hotspot h) {
    setState(() => _found.add(h.id));
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.sand, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.gold),
                const SizedBox(width: 8),
                Expanded(child: Text(h.label, style: AppTheme.heading(22))),
              ],
            ),
            const SizedBox(height: 10),
            Text(h.description, style: const TextStyle(fontSize: 15, height: 1.5)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chapterAsync = ref.watch(chapterProvider(widget.chapterId));
    final contentsAsync = ref.watch(contentsProvider(widget.chapterId));

    return chapterAsync.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorView(onRetry: () => ref.invalidate(chapterProvider(widget.chapterId))),
      ),
      data: (chapter) {
        if (chapter == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyView(
              title: 'Bab tidak ditemukan',
              note: 'Bab ini belum tersedia atau sudah dihapus.',
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text('Bab ${chapter.order}')),
          body: contentsAsync.when(
            loading: () => const LoadingView(),
            error: (e, _) =>
                ErrorView(onRetry: () => ref.invalidate(contentsProvider(widget.chapterId))),
            data: (contents) {
              if (contents.isEmpty) {
                return const EmptyView(
                  title: 'Materi belum tersedia',
                  note: 'Materi untuk bab ini belum diisi. Silakan kembali lagi nanti.',
                );
              }
              WidgetsBinding.instance.addPostFrameCallback((_) => _markVisited());
              final main = contents.first;
              final total = main.hotspots.length;
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                children: [
                  Reveal(
                    child: ChapterScene(
                      theme: chapter.theme,
                      hotspots: main.hotspots,
                      foundIds: _found,
                      onHotspotTap: _openHotspot,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (total > 0)
                    Row(
                      children: [
                        const Icon(Icons.touch_app, size: 18, color: AppColors.terracotta),
                        const SizedBox(width: 6),
                        Text('Objek dijelajahi ${_found.length}/$total',
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  const SizedBox(height: 14),
                  if (!(chapter.verified && main.verified))
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: .2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          AppConstants.unverifiedLabel,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Reveal(index: 1, child: Text(chapter.title, style: AppTheme.heading(28))),
                  const SizedBox(height: 12),
                  for (var i = 0; i < main.paragraphs.length; i++)
                    Reveal(
                      index: i + 2,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(main.paragraphs[i],
                            style: const TextStyle(fontSize: 16, height: 1.55)),
                      ),
                    ),
                  if (main.keyFacts.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.sand, width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.lightbulb, color: AppColors.gold),
                              const SizedBox(width: 8),
                              Text('Informasi Penting', style: AppTheme.heading(17)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          for (final f in main.keyFacts)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Icon(Icons.circle, size: 8, color: AppColors.terracotta),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(f, style: const TextStyle(height: 1.45))),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  for (final extra in contents.skip(1)) ...[
                    const SizedBox(height: 18),
                    Text(extra.title, style: AppTheme.heading(20)),
                    const SizedBox(height: 8),
                    for (final p in extra.paragraphs)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(p, style: const TextStyle(fontSize: 16, height: 1.55)),
                      ),
                  ],
                  const SizedBox(height: 22),
                  PrimaryButton(
                    label: 'Mulai Tantangan',
                    icon: Icons.extension_rounded,
                    onPressed: () => context.push('/chapter/${widget.chapterId}/challenge'),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Langsung ke Kuis',
                    icon: Icons.quiz_rounded,
                    color: AppColors.forest,
                    onPressed: () => context.push('/chapter/${widget.chapterId}/quiz'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

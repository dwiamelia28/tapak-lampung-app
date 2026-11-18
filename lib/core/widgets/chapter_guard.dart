import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import 'primary_button.dart';
import 'state_views.dart';

/// Menampilkan [builder] hanya jika bab sudah terbuka untuk pengguna.
class ChapterGuard extends ConsumerWidget {
  const ChapterGuard({super.key, required this.chapterId, required this.builder});
  final String chapterId;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    return progress.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorView(onRetry: () => ref.invalidate(progressProvider)),
      ),
      data: (p) {
        if (p.unlockedChapterIds.contains(chapterId)) return builder(context);
        return Scaffold(
          appBar: AppBar(title: const Text('Bab Terkunci')),
          body: EmptyView(
            title: 'Bab ini masih terkunci',
            note: 'Selesaikan bab sebelumnya dan lulus kuisnya untuk membuka bab ini.',
            action: SizedBox(
              width: 200,
              child: PrimaryButton(label: 'Ke Peta', onPressed: () => context.go('/map')),
            ),
          ),
        );
      },
    );
  }
}

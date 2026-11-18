import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/lampung_icon.dart';
import '../../core/widgets/photo_image.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/state_views.dart';
import '../../models/journal_model.dart';
import '../../providers/content_providers.dart';

class JournalDetailScreen extends ConsumerStatefulWidget {
  const JournalDetailScreen({super.key, required this.entryId});
  final String entryId;
  @override
  ConsumerState<JournalDetailScreen> createState() => _JournalDetailScreenState();
}

class _JournalDetailScreenState extends ConsumerState<JournalDetailScreen> {
  bool _deleting = false;

  Future<void> _delete(JournalModel e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus catatan?'),
        content: const Text('Catatan dan fotonya akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _deleting = true);
    try {
      await ref.read(journalServiceProvider).delete(e.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Catatan dihapus.')));
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _deleting = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Gagal menghapus. Coba lagi.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(journalProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Catatan')),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(onRetry: () => ref.invalidate(journalProvider)),
        data: (list) {
          final idx = list.indexWhere((x) => x.id == widget.entryId);
          if (idx < 0) {
            return const EmptyView(
              title: 'Catatan tidak ditemukan',
              note: 'Catatan ini mungkin sudah dihapus.',
            );
          }
          final e = list[idx];
          final cat = JournalCategory.of(e.category);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            children: [
              if (e.imageBase64 != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: AspectRatio(aspectRatio: 4 / 3, child: Base64Image(e.imageBase64!)),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: .2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LampungIcon(cat.icon, size: 18, color: AppColors.maroon),
                        const SizedBox(width: 6),
                        Text(cat.label, style: const TextStyle(fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(formatDate(e.createdAt),
                      style: const TextStyle(fontSize: 12, color: AppColors.brownSoft)),
                ],
              ),
              const SizedBox(height: 12),
              Text(e.title, style: AppTheme.heading(26)),
              const SizedBox(height: 10),
              Text(e.description, style: const TextStyle(fontSize: 16, height: 1.55)),
              const SizedBox(height: 26),
              PrimaryButton(
                label: 'Edit Catatan',
                icon: Icons.edit,
                onPressed: _deleting ? null : () => context.push('/journal/${e.id}/edit'),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Hapus Catatan',
                icon: Icons.delete_outline,
                color: AppColors.maroon,
                loading: _deleting,
                onPressed: () => _delete(e),
              ),
            ],
          );
        },
      ),
    );
  }
}

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
import '../../providers/planner_providers.dart';

class VisitDetailScreen extends ConsumerStatefulWidget {
  const VisitDetailScreen({super.key, required this.visitId});
  final String visitId;
  @override
  ConsumerState<VisitDetailScreen> createState() => _VisitDetailScreenState();
}

class _VisitDetailScreenState extends ConsumerState<VisitDetailScreen> {
  bool _busy = false;

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus rencana?'),
        content: const Text('Rencana beserta pengingatnya akan dihapus.'),
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
    setState(() => _busy = true);
    try {
      await ref.read(plannerServiceProvider).deleteVisit(widget.visitId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rencana dihapus.')));
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Gagal menghapus. Coba lagi.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(visitsProvider);
    final svc = ref.read(plannerServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Rencana')),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(onRetry: () => ref.invalidate(visitsProvider)),
        data: (list) {
          final i = list.indexWhere((v) => v.id == widget.visitId);
          if (i < 0) {
            return const EmptyView(
                title: 'Rencana tidak ditemukan', note: 'Rencana ini mungkin sudah dihapus.');
          }
          final v = list[i];
          final cat = JournalCategory.of(v.category);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            children: [
              if (v.photoBase64 != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: AspectRatio(aspectRatio: 16 / 9, child: Base64Image(v.photoBase64!)),
                ),
              const SizedBox(height: 14),
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
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: (v.visited ? AppColors.success : AppColors.terracotta)
                          .withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(v.visited ? 'Sudah dikunjungi' : 'Belum dikunjungi',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: v.visited ? AppColors.success : AppColors.terracotta)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(v.title, style: AppTheme.heading(26)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.event, size: 18, color: AppColors.brownSoft),
                  const SizedBox(width: 6),
                  Text(formatDay(v.date), style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
              if (v.note.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(v.note, style: const TextStyle(fontSize: 16, height: 1.5)),
              ],
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.sand),
                ),
                child: SwitchListTile(
                  value: v.reminderOn && !v.visited,
                  activeColor: AppColors.terracotta,
                  title: const Text('Pengingat kunjungan', style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text(v.visited
                      ? 'Tidak aktif karena sudah dikunjungi.'
                      : 'Notifikasi lokal: sehari sebelumnya 18.00 dan hari H 07.00 WIB.'),
                  onChanged: v.visited ? null : (on) => svc.setVisitReminder(v.id, on),
                ),
              ),
              const SizedBox(height: 22),
              PrimaryButton(
                label: v.visited ? 'Tandai Belum Dikunjungi' : 'Tandai Sudah Dikunjungi',
                icon: v.visited ? Icons.undo_rounded : Icons.check_circle_outline,
                color: AppColors.forest,
                onPressed: _busy ? null : () => svc.setVisited(v.id, !v.visited),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Edit Rencana',
                icon: Icons.edit,
                onPressed: _busy ? null : () => context.push('/visits/${v.id}/edit'),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Hapus Rencana',
                icon: Icons.delete_outline,
                color: AppColors.maroon,
                loading: _busy,
                onPressed: _delete,
              ),
            ],
          );
        },
      ),
    );
  }
}

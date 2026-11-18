import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/illustrations/ornaments.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/lampung_icon.dart';
import '../../core/widgets/photo_image.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/reveal.dart';
import '../../core/widgets/state_views.dart';
import '../../models/journal_model.dart';
import '../../providers/content_providers.dart';

/// Jurnal Budaya: catatan pribadi pengguna tentang budaya Lampung, lengkap dengan
/// foto (Firebase Storage), deskripsi, kategori. Bisa ditambah, diedit, dan dihapus.
class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(journalProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Jurnal Budaya')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.terracotta,
        foregroundColor: Colors.white,
        onPressed: () => context.push('/journal/new'),
        icon: const Icon(Icons.add_a_photo_rounded),
        label: const Text('Tambah Catatan', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(onRetry: () => ref.invalidate(journalProvider)),
        data: (list) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
          children: [
            const OrnamentBanner(
              title: 'Catatan Petualanganmu',
              subtitle: 'Simpan temuan budaya Lampung dengan foto dan ceritamu sendiri.',
            ),
            const SizedBox(height: 18),
            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: EmptyView(
                  title: 'Belum ada catatan',
                  note: 'Mulai dengan menambahkan foto rumah adat, kain, kuliner, atau seni yang kamu temui.',
                  action: SizedBox(
                    width: 220,
                    child: PrimaryButton(
                      label: 'Buat Catatan Pertama',
                      icon: Icons.add,
                      onPressed: () => context.push('/journal/new'),
                    ),
                  ),
                ),
              )
            else
              for (var i = 0; i < list.length; i++)
                Reveal(index: i.clamp(0, 4), child: _EntryCard(entry: list[i])),
          ],
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry});
  final JournalModel entry;

  @override
  Widget build(BuildContext context) {
    final cat = JournalCategory.of(entry.category);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => context.push('/journal/${entry.id}'),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.sand, width: 1.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (entry.imageBase64 != null)
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Base64Image(entry.imageBase64!, cacheWidth: 700),
                  ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: .2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                LampungIcon(cat.icon, size: 16, color: AppColors.maroon),
                                const SizedBox(width: 6),
                                Text(cat.label,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text(formatDate(entry.createdAt),
                              style: const TextStyle(fontSize: 11, color: AppColors.brownSoft)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(entry.title, style: AppTheme.heading(18)),
                      const SizedBox(height: 4),
                      Text(entry.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(height: 1.4, color: AppColors.brownSoft)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

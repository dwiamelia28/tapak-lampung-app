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
import '../../models/visit_model.dart';
import '../../providers/planner_providers.dart';

enum _Filter { all, planned, done }

class VisitsScreen extends ConsumerStatefulWidget {
  const VisitsScreen({super.key});
  @override
  ConsumerState<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends ConsumerState<VisitsScreen> {
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(visitsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Rencana Kunjungan Saya')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.terracotta,
        foregroundColor: Colors.white,
        onPressed: () => context.push('/visits/new'),
        icon: const Icon(Icons.add),
        label: const Text('Rencana Baru', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(onRetry: () => ref.invalidate(visitsProvider)),
        data: (all) {
          final list = all.where((v) {
            switch (_filter) {
              case _Filter.planned:
                return !v.visited;
              case _Filter.done:
                return v.visited;
              case _Filter.all:
                return true;
            }
          }).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Wrap(
                  spacing: 8,
                  children: [
                    for (final f in _Filter.values)
                      ChoiceChip(
                        label: Text(switch (f) {
                          _Filter.all => 'Semua (${all.length})',
                          _Filter.planned => 'Belum dikunjungi',
                          _Filter.done => 'Sudah dikunjungi',
                        }),
                        selected: _filter == f,
                        selectedColor: AppColors.terracotta.withValues(alpha: .18),
                        onSelected: (_) => setState(() => _filter = f),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: list.isEmpty
                    ? EmptyView(
                        title: all.isEmpty ? 'Belum ada rencana' : 'Tidak ada rencana di filter ini',
                        note: all.isEmpty
                            ? 'Buat rencana kunjungan ke tempat yang berkaitan dengan budaya Lampung, lalu aktifkan pengingatnya.'
                            : 'Coba pilih filter lain.',
                        action: all.isEmpty
                            ? SizedBox(
                                width: 200,
                                child: PrimaryButton(
                                  label: 'Buat Rencana',
                                  icon: Icons.add,
                                  onPressed: () => context.push('/visits/new'),
                                ),
                              )
                            : null,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _VisitCard(visit: list[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _VisitCard extends ConsumerWidget {
  const _VisitCard({required this.visit});
  final VisitModel visit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cat = JournalCategory.of(visit.category);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.push('/visits/${visit.id}'),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.sand),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: visit.photoBase64 != null
                      ? Base64Image(visit.photoBase64!, cacheWidth: 200)
                      : Container(
                          color: AppColors.gold.withValues(alpha: .18),
                          alignment: Alignment.center,
                          child: LampungIcon(cat.icon, size: 30, color: AppColors.maroon),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(visit.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.heading(16)),
                    const SizedBox(height: 2),
                    Text('${cat.label}  |  ${formatDay(visit.date)}',
                        style: const TextStyle(fontSize: 12, color: AppColors.brownSoft)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(visit.visited ? Icons.check_circle : Icons.schedule,
                            size: 15, color: visit.visited ? AppColors.success : AppColors.terracotta),
                        const SizedBox(width: 4),
                        Text(visit.visited ? 'Sudah dikunjungi' : 'Belum dikunjungi',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: visit.visited ? AppColors.success : AppColors.terracotta)),
                        if (!visit.visited && visit.reminderOn) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.notifications_active, size: 14, color: AppColors.brownSoft),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: visit.visited ? 'Tandai belum dikunjungi' : 'Tandai sudah dikunjungi',
                icon: Icon(visit.visited ? Icons.undo_rounded : Icons.check_circle_outline,
                    color: AppColors.forest),
                onPressed: () => ref.read(plannerServiceProvider).setVisited(visit.id, !visit.visited),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

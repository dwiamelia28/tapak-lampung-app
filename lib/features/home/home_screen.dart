import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/photo_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/lampung_icon.dart';
import '../../core/widgets/photo_image.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/reveal.dart';
import '../../models/journal_model.dart';
import '../../models/progress_model.dart';
import '../../models/reminder_model.dart';
import '../../providers/content_providers.dart';
import '../../providers/planner_providers.dart';
import '../../providers/providers.dart';
import '../../services/audio_service.dart';

/// Beranda: tampilan aplikasi modern dengan foto budaya (bukan ilustrasi game).
/// Bagian game (peta, tantangan, kuis) tetap memakai gaya ilustrasi sendiri.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserDocProvider).valueOrNull;
    final authName = ref.watch(authStateProvider).valueOrNull?.displayName;
    final name = (user?.firstName.isNotEmpty ?? false)
        ? user!.firstName
        : (authName?.split(' ').first ?? 'Penjelajah');

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
      children: [
        const _Header(),
        const SizedBox(height: 18),
        Text('Halo, $name!', style: AppTheme.heading(26)),
        const SizedBox(height: 4),
        const Text('Yuk, jelajahi dan kenali budaya Lampung hari ini.',
            style: TextStyle(color: AppColors.brownSoft, height: 1.35)),
        const SizedBox(height: 16),
        const Reveal(child: _HeroPager()),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Mulai Petualangan',
          icon: Icons.explore,
          onPressed: () => context.push('/map'),
        ),
        const SizedBox(height: 12),
        const _QuickRow(),
        const SizedBox(height: 18),
        const _ProgressCard(),
        const SizedBox(height: 26),
        _SectionHeader(
          title: 'Rencana Kunjungan Saya',
          action: 'Lihat semua',
          onAction: () => context.push('/visits'),
        ),
        const SizedBox(height: 12),
        const _VisitsSection(),
        const SizedBox(height: 26),
        _SectionHeader(
          title: 'Daftar Belajar Budaya',
          action: 'Kelola',
          onAction: () => context.push('/study'),
        ),
        const SizedBox(height: 12),
        const _StudySection(),
        const SizedBox(height: 26),
        _SectionHeader(
          title: 'Pengingat Belajar',
          action: 'Atur',
          onAction: () => context.push('/reminder'),
        ),
        const SizedBox(height: 12),
        const _ReminderSection(),
        const SizedBox(height: 26),
        const _SectionHeader(title: 'Rekomendasi Materi'),
        const SizedBox(height: 12),
        const _RecommendSection(),
      ],
    );
  }
}

BoxDecoration _card() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.sand, width: 1),
      boxShadow: [
        BoxShadow(
          color: AppColors.brown.withValues(alpha: .06),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    );

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(child: Text(title, style: AppTheme.heading(19))),
          if (action != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.terracotta,
                visualDensity: VisualDensity.compact,
              ),
              child: Text(action!, style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
        ],
      );
}

// ------------------------------------------------------------------ header
class _Header extends ConsumerWidget {
  const _Header();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadCountProvider);
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(color: AppColors.maroon, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: const LampungIcon('siger', size: 24, color: Colors.white, accent: AppColors.goldLight),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            AppConstants.appName,
            style: AppTheme.heading(18, color: AppColors.maroon).copyWith(letterSpacing: 1),
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: AudioService.instance.soundOn,
          builder: (_, on, __) => IconButton(
            tooltip: on ? 'Matikan suara' : 'Nyalakan suara',
            icon: Icon(on ? Icons.volume_up_rounded : Icons.volume_off_rounded),
            onPressed: () => AudioService.instance.setSound(!on),
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              tooltip: 'Notifikasi',
              icon: const Icon(Icons.notifications_none_rounded),
              onPressed: () => context.push('/notifications'),
            ),
            if (unread > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.terracotta,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text('$unread',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// -------------------------------------------------------------------- hero
class _HeroPager extends StatefulWidget {
  const _HeroPager();
  @override
  State<_HeroPager> createState() => _HeroPagerState();
}

class _HeroPagerState extends State<_HeroPager> {
  final _c = PageController();
  int _i = 0;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = CulturePhotos.hero;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 220,
        child: Stack(
          children: [
            PageView.builder(
              controller: _c,
              itemCount: photos.length,
              onPageChanged: (i) => setState(() => _i = i),
              itemBuilder: (_, i) => Stack(
                fit: StackFit.expand,
                children: [
                  PhotoImage(photos[i]),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Color(0xB3000000)],
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 70,
                    bottom: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(photos[i].title,
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
                        if (photos[i].credit.isNotEmpty)
                          Text('Foto: ${photos[i].credit}',
                              style: const TextStyle(color: Colors.white70, fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 14,
              bottom: 18,
              child: Row(
                children: [
                  for (var i = 0; i < photos.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(left: 4),
                      width: i == _i ? 16 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == _i ? Colors.white : Colors.white54,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ akses cepat
class _QuickRow extends StatelessWidget {
  const _QuickRow();
  @override
  Widget build(BuildContext context) {
    Widget tile(String icon, String label, Color color, String route) => Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => context.push(route),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: _card(),
              child: Column(
                children: [
                  LampungIcon(icon, size: 26, color: color),
                  const SizedBox(height: 6),
                  Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
        );
    return Row(
      children: [
        tile('gamolan', 'Tantangan', AppColors.terracotta, '/challenges'),
        const SizedBox(width: 10),
        tile('siger', 'Kuis', AppColors.maroon, '/quiz'),
        const SizedBox(width: 10),
        tile('tapis', 'Jurnal', const Color(0xFFB8741A), '/journal'),
        const SizedBox(width: 10),
        tile('kapal', 'Progres', AppColors.forest, '/progress'),
      ],
    );
  }
}

// ---------------------------------------------------------------- progres
class _ProgressCard extends ConsumerWidget {
  const _ProgressCard();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final chapters = ref.watch(chaptersProvider).valueOrNull ?? const [];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _card(),
      child: progress.when(
        loading: () => const SizedBox(
          height: 70,
          child: Center(child: CircularProgressIndicator(color: AppColors.terracotta)),
        ),
        error: (e, _) => const Text('Gagal memuat progres. Periksa koneksi lalu coba lagi.'),
        data: (p) {
          final lastIdx = p.lastChapterId == null
              ? -1
              : chapters.indexWhere((c) => c.id == p.lastChapterId);
          final last = lastIdx >= 0 ? chapters[lastIdx] : null;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text('Progres Petualangan', style: AppTheme.heading(17))),
                  Text('${p.completedCount}/${AppConstants.totalChapters} bab',
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: p.completionRatio,
                minHeight: 10,
                color: AppColors.forest,
                backgroundColor: AppColors.sand,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Chip(Icons.trending_up, 'Level ${p.totalXp ~/ AppConstants.xpPerLevel + 1}'),
                  _Chip(Icons.bolt, '${p.totalXp} XP'),
                  _Chip(Icons.workspace_premium, '${p.achievements.length} lencana'),
                ],
              ),
              if (last != null) ...[
                const SizedBox(height: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => context.push('/chapter/${last.id}'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.play_circle_fill, color: AppColors.terracotta),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Lanjutkan: ${last.title}',
                              style: const TextStyle(fontWeight: FontWeight.w800)),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.brownSoft),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.icon, this.label);
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.sand.withValues(alpha: .7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.maroon),
            const SizedBox(width: 5),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
          ],
        ),
      );
}

// --------------------------------------------------------------- kunjungan
class _VisitsSection extends ConsumerWidget {
  const _VisitsSection();

  String _when(DateTime d) {
    final now = DateTime.now();
    final diff = DateTime(d.year, d.month, d.day).difference(DateTime(now.year, now.month, now.day)).inDays;
    if (diff == 0) return 'Hari ini';
    if (diff == 1) return 'Besok';
    if (diff > 1) return '$diff hari lagi';
    return 'Terlewat';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(visitsProvider);
    return async.when(
      loading: () => const _Loading(),
      error: (e, _) => const _InfoCard(text: 'Rencana kunjungan belum bisa dimuat.'),
      data: (all) {
        final upcoming = all.where((v) => !v.visited).take(2).toList();
        if (upcoming.isEmpty) {
          return _EmptyCard(
            icon: Icons.event_note_rounded,
            text: 'Belum ada rencana kunjungan. Rencanakan kunjunganmu ke tempat yang berkaitan dengan budaya Lampung.',
            button: 'Buat Rencana',
            onTap: () => context.push('/visits/new'),
          );
        }
        return Column(
          children: [
            for (final v in upcoming)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => context.push('/visits/${v.id}'),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: _card(),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: .18), shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: LampungIcon(JournalCategory.of(v.category).icon,
                              size: 26, color: AppColors.maroon),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(v.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                              Text(formatDay(v.date),
                                  style: const TextStyle(fontSize: 12, color: AppColors.brownSoft)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.terracotta.withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(_when(v.date),
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.terracotta)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            OutlinedButton.icon(
              onPressed: () => context.push('/visits/new'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Rencana baru'),
            ),
          ],
        );
      },
    );
  }
}

// ----------------------------------------------------------- daftar belajar
class _StudySection extends ConsumerWidget {
  const _StudySection();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(studyItemsProvider);
    final topics = ref.watch(studyTopicsProvider).valueOrNull ?? const [];
    return items.when(
      loading: () => const _Loading(),
      error: (e, _) => const _InfoCard(text: 'Daftar belajar belum bisa dimuat.'),
      data: (list) {
        if (list.isEmpty) {
          return _EmptyCard(
            icon: Icons.menu_book_rounded,
            text: 'Pilih materi budaya yang ingin kamu pelajari dan pantau progresnya.',
            button: 'Pilih Materi',
            onTap: () => context.push('/study'),
          );
        }
        final learned = list.where((i) => i.learned).length;
        final byKey = {for (final t in topics) t.key: t};
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.push('/study'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: _card(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('$learned dari ${list.length} materi dipelajari',
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                    ),
                    Text('${(learned / list.length * 100).round()}%',
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, color: AppColors.forest)),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: learned / list.length,
                  minHeight: 8,
                  color: AppColors.forest,
                  backgroundColor: AppColors.sand,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 10),
                for (final it in list.take(3))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Icon(it.learned ? Icons.check_circle : Icons.radio_button_unchecked,
                            size: 18, color: it.learned ? AppColors.success : AppColors.brownSoft),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            byKey['${it.chapterId}_${it.topicId}']?.title ?? it.topicId,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------- pengingat
class _ReminderSection extends ConsumerWidget {
  const _ReminderSection();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(reminderSettingsProvider);
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    final s = async.valueOrNull ?? const ReminderSettings();
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => context.push('/reminder'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: _card(),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.forest.withValues(alpha: .12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.alarm_rounded, color: AppColors.forest),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.enabled ? 'Pengingat aktif' : 'Pengingat belum aktif',
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  Text(
                    s.enabled ? '${s.timeLabel} WIB  |  ${s.daysLabel}' : 'Atur jam dan hari belajarmu',
                    style: const TextStyle(fontSize: 12, color: AppColors.brownSoft),
                  ),
                ],
              ),
            ),
            Switch(
              value: s.enabled,
              activeColor: AppColors.terracotta,
              onChanged: uid == null
                  ? null
                  : (v) => ref.read(plannerServiceProvider).saveReminder(uid, s.copyWith(enabled: v)),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------- rekomendasi
class _RecommendSection extends ConsumerWidget {
  const _RecommendSection();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapters = ref.watch(chaptersProvider);
    final progress = ref.watch(progressProvider).valueOrNull ?? const ProgressModel();
    return chapters.when(
      loading: () => const _Loading(),
      error: (e, _) => const _InfoCard(text: 'Materi belum bisa dimuat.'),
      data: (list) {
        if (list.isEmpty) {
          return const _InfoCard(text: 'Belum ada materi. Jalankan skrip data awal.');
        }
        final todo = list.where((c) => !progress.completedChapterIds.contains(c.id)).toList();
        final shown = todo.isEmpty ? list : todo;
        return SizedBox(
          height: 224,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: shown.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final c = shown[i];
              final idx = list.indexOf(c);
              final locked = idx != 0 && !progress.unlockedChapterIds.contains(c.id);
              final photo = CulturePhotos.forTheme(c.theme);
              return SizedBox(
                width: 230,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    if (locked) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bab ini masih terkunci. Selesaikan bab sebelumnya.')),
                      );
                    } else {
                      context.push('/chapter/${c.id}');
                    }
                  },
                  child: Container(
                    decoration: _card(),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 118,
                          width: double.infinity,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              PhotoImage(photo, compact: true),
                              if (locked)
                                Container(
                                  color: Colors.black45,
                                  child: const Icon(Icons.lock, color: Colors.white),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Bab ${c.order}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.terracotta)),
                              const SizedBox(height: 2),
                              Text(c.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTheme.heading(15)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ------------------------------------------------------------------- umum
class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) => Container(
        height: 80,
        decoration: _card(),
        child: const Center(child: CircularProgressIndicator(color: AppColors.terracotta)),
      );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: _card(),
        child: Text(text, style: const TextStyle(color: AppColors.brownSoft)),
      );
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard(
      {required this.icon, required this.text, required this.button, required this.onTap});
  final IconData icon;
  final String text;
  final String button;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: _card(),
        child: Column(
          children: [
            Icon(icon, size: 34, color: AppColors.gold),
            const SizedBox(height: 8),
            Text(text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.brownSoft, height: 1.4)),
            const SizedBox(height: 12),
            SizedBox(width: 190, child: PrimaryButton(label: button, onPressed: onTap)),
          ],
        ),
      );
}

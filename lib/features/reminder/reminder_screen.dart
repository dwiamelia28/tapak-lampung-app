import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/state_views.dart';
import '../../models/reminder_model.dart';
import '../../providers/planner_providers.dart';
import '../../providers/providers.dart';
import '../../services/fcm_service.dart';
import '../../services/reminder_service.dart';

/// Pengingat Belajar: notifikasi LOKAL terjadwal (bukan push FCM).
class ReminderScreen extends ConsumerStatefulWidget {
  const ReminderScreen({super.key});
  @override
  ConsumerState<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends ConsumerState<ReminderScreen> {
  ReminderSettings _s = const ReminderSettings();
  bool _loaded = false;
  bool _saving = false;

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _s.hour, minute: _s.minute),
      helpText: 'Pilih jam pengingat (WIB)',
    );
    if (t != null) setState(() => _s = _s.copyWith(hour: t.hour, minute: t.minute));
  }

  Future<void> _save() async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    if (_s.enabled && _s.days.isEmpty) {
      _snack('Pilih minimal satu hari.');
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(plannerServiceProvider).saveReminder(uid, _s);
      _snack(_s.enabled ? 'Pengingat disimpan: ${_s.timeLabel} WIB, ${_s.daysLabel}.' : 'Pengingat dinonaktifkan.');
    } catch (_) {
      _snack('Gagal menyimpan. Periksa koneksi lalu coba lagi.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus pengingat?'),
        content: const Text('Jadwal pengingat belajar akan dihapus dan dibatalkan.'),
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
    try {
      await ref.read(plannerServiceProvider).deleteReminder(uid);
      if (mounted) setState(() => _s = const ReminderSettings());
      _snack('Pengingat dihapus.');
    } catch (_) {
      _snack('Gagal menghapus.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(reminderSettingsProvider);
    if (!_loaded && async.hasValue) {
      _s = async.value!;
      _loaded = true;
    }
    if (async.isLoading && !_loaded) {
      return Scaffold(appBar: AppBar(title: const Text('Pengingat Belajar')), body: const LoadingView());
    }
    if (async.hasError && !_loaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pengingat Belajar')),
        body: ErrorView(onRetry: () => ref.invalidate(reminderSettingsProvider)),
      );
    }
    final denied = FcmService.instance.permission.value == AuthorizationStatus.denied;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengingat Belajar')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.sand),
            ),
            child: SwitchListTile(
              value: _s.enabled,
              activeColor: AppColors.terracotta,
              title: const Text('Aktifkan pengingat', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('"Yuk, luangkan waktu sebentar untuk mengenal budaya Lampung hari ini!"'),
              onChanged: (v) => setState(() => _s = _s.copyWith(enabled: v)),
            ),
          ),
          if (denied)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'Izin notifikasi ditolak. Aktifkan lewat Pengaturan HP agar pengingat bisa tampil.',
                style: TextStyle(color: AppColors.error.withValues(alpha: .9), fontWeight: FontWeight.w700),
              ),
            ),
          const SizedBox(height: 20),
          Text('Jam pengingat', style: AppTheme.heading(16)),
          const SizedBox(height: 8),
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: _pickTime,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.sand),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time_rounded, color: AppColors.forest),
                  const SizedBox(width: 12),
                  Text('${_s.timeLabel} WIB',
                      style: AppTheme.heading(22, color: AppColors.forest)),
                  const Spacer(),
                  const Text('Ubah', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.terracotta)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Hari pengingat', style: AppTheme.heading(16)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var d = 1; d <= 7; d++)
                FilterChip(
                  label: Text(ReminderSettings.dayNames[d - 1]),
                  selected: _s.days.contains(d),
                  selectedColor: AppColors.terracotta.withValues(alpha: .2),
                  onSelected: (on) {
                    final days = {..._s.days};
                    on ? days.add(d) : days.remove(d);
                    setState(() => _s = _s.copyWith(days: days));
                  },
                ),
            ],
          ),
          const SizedBox(height: 24),
          PrimaryButton(label: 'Simpan Jadwal', icon: Icons.check_rounded, loading: _saving, onPressed: _save),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              await ReminderService.instance.showTest();
            },
            icon: const Icon(Icons.notifications_active_outlined),
            label: const Text('Uji tampilan pengingat sekarang'),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            label: const Text('Hapus pengingat', style: TextStyle(color: AppColors.error)),
          ),
          const SizedBox(height: 12),
          const Text(
            'Pengingat ini adalah notifikasi lokal terjadwal di HP-mu (zona waktu Asia/Jakarta), '
            'berbeda dari push notification FCM. Saat HP dalam mode hemat daya, waktu tampil bisa '
            'bergeser beberapa menit.',
            style: TextStyle(fontSize: 12, color: AppColors.brownSoft, height: 1.5),
          ),
        ],
      ),
    );
  }
}

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/illustrations/ornaments.dart';
import '../../core/theme/app_colors.dart';
import '../../services/audio_service.dart';
import '../../services/fcm_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  String _statusText(AuthorizationStatus? s) {
    switch (s) {
      case AuthorizationStatus.authorized:
        return 'Diizinkan';
      case AuthorizationStatus.denied:
        return 'Ditolak (aktifkan lewat Pengaturan HP)';
      case AuthorizationStatus.provisional:
        return 'Sementara';
      case AuthorizationStatus.notDetermined:
        return 'Belum ditentukan';
      case null:
        return 'Belum diperiksa';
    }
  }

  @override
  Widget build(BuildContext context) {
    final fcm = FcmService.instance;
    final audio = AudioService.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          const OrnamentBanner(
            title: 'Pengaturan',
            subtitle: 'Suara, musik latar, dan notifikasi.',
            height: 88,
          ),
          const SizedBox(height: 18),
          const SectionTitle('Suara'),
          const SizedBox(height: 10),
          OrnateCard(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ValueListenableBuilder<bool>(
              valueListenable: audio.soundOn,
              builder: (_, on, __) => SwitchListTile(
                value: on,
                activeColor: AppColors.terracotta,
                title: const Text('Musik latar dan efek suara',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                subtitle: const Text('Musik bernuansa gamolan (komposisi sendiri).'),
                onChanged: audio.setSound,
              ),
            ),
          ),
          const SizedBox(height: 22),
          const SectionTitle('Notifikasi'),
          const SizedBox(height: 10),
          OrnateCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder<AuthorizationStatus?>(
                  valueListenable: fcm.permission,
                  builder: (_, s, __) => Row(
                    children: [
                      const Icon(Icons.notifications_active_outlined, color: AppColors.terracotta),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text('Izin notifikasi: ${_statusText(s)}',
                            style: const TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text('FCM Token perangkat',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.brownSoft)),
                const SizedBox(height: 6),
                ValueListenableBuilder<String?>(
                  valueListenable: fcm.token,
                  builder: (_, t, __) => Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.sand.withValues(alpha: .6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: SelectableText(
                      t ?? 'Token belum tersedia. Tekan "Minta izin & ambil token".',
                      style: const TextStyle(fontSize: 12, height: 1.4),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await fcm.requestPermissionAndToken();
                        },
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Minta izin & ambil token'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      tooltip: 'Salin token',
                      onPressed: () async {
                        final t = fcm.token.value;
                        if (t == null) return;
                        await Clipboard.setData(ClipboardData(text: t));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(content: Text('Token disalin.')));
                        }
                      },
                      icon: const Icon(Icons.copy),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionTitle('Cara menguji notifikasi'),
          const SizedBox(height: 10),
          OrnateCard(
            padding: const EdgeInsets.all(16),
            child: Text(
              '1. Salin token di atas.\n'
              '2. Firebase Console > Messaging > New campaign > Notifications > "Send test message".\n'
              '3. Tempel token, isi judul dan teks, lalu Test.\n'
              '4. Untuk membuka halaman tertentu saat diketuk, tambahkan data kustom: '
              'route = /map (atau /journal, /progress, /notifications).',
              style: const TextStyle(
                color: AppColors.brownSoft,
                fontWeight: FontWeight.w600,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

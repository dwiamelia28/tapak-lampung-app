import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/achievements.dart';
import '../../core/illustrations/ornaments.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/badge_medal.dart';
import '../../core/utils/photo_codec.dart';
import '../../core/widgets/lampung_icon.dart';
import '../../core/widgets/photo_image.dart';
import '../../models/progress_model.dart';
import '../../providers/content_providers.dart';
import '../../providers/providers.dart';
import '../../services/audio_service.dart';
import '../../services/fcm_service.dart';
import '../../services/reminder_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _avatarBusy = false;

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text('Progres kamu tersimpan dan akan tersedia saat masuk kembali.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Keluar')),
        ],
      ),
    );
    if (ok != true) return;
    await FcmService.instance.removeToken();
    await AudioService.instance.stopMusic();
    await ReminderService.instance.cancelAll();
    await ref.read(authServiceProvider).logout();
  }

  Future<void> _editName(String current) async {
    final c = TextEditingController(text: current);
    final form = GlobalKey<FormState>();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubah nama'),
        content: Form(
          key: form,
          child: TextFormField(
            controller: c,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            validator: (v) =>
                (v == null || v.trim().length < 2) ? 'Nama minimal 2 karakter' : null,
            decoration: const InputDecoration(labelText: 'Nama lengkap'),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              if (form.currentState!.validate()) Navigator.pop(ctx, c.text.trim());
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (name == null) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await user.updateDisplayName(name);
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': name,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      _snack('Nama diperbarui.');
    } catch (_) {
      _snack('Gagal memperbarui nama.');
    }
  }

  Future<void> _pickAvatar(ImageSource source) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final x = await ImagePicker().pickImage(source: source, imageQuality: 80, maxWidth: 800);
      if (x == null) return;
      setState(() => _avatarBusy = true);
      final bytes = await PhotoCodec.compress(await x.readAsBytes(), maxWidth: 360, maxBytes: 60 * 1024);
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'photoBase64': PhotoCodec.encode(bytes),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      _snack('Foto profil diperbarui.');
    } on PhotoTooLargeException catch (e) {
      _snack(e.toString());
    } catch (_) {
      _snack('Foto profil gagal diperbarui. Coba lagi.');
    } finally {
      if (mounted) setState(() => _avatarBusy = false);
    }
  }

  Future<void> _removeAvatar() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'photoBase64': null,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      _snack('Foto profil dihapus.');
    } catch (_) {
      _snack('Gagal menghapus foto profil.');
    }
  }

  void _avatarMenu(bool hasPhoto) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.terracotta),
              title: const Text('Pilih dari galeri'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAvatar(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded, color: AppColors.terracotta),
              title: const Text('Ambil dengan kamera'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAvatar(ImageSource.camera);
              },
            ),
            if (hasPhoto)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: const Text('Hapus foto profil', style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(ctx);
                  _removeAvatar();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _about() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tentang TAPAK LAMPUNG'),
        content: const Text(
          'Jelajahi Ceritanya, Kenali Budayanya.\n\n'
          'Aplikasi petualangan edukasi budaya Lampung: rumah adat, kain dan busana, '
          'seni pertunjukan, dan kuliner, lengkap dengan tantangan, kuis, lencana, dan jurnal budaya.\n\n'
          'Ini adalah simulasi pengelolaan oleh admin, bukan aplikasi resmi instansi mana pun. '
          'Konten awal masih perlu divalidasi dari sumber resmi.\n\nVersi 1.0.0',
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserDocProvider).valueOrNull;
    final authUser = ref.watch(authStateProvider).valueOrNull;
    final progress = ref.watch(progressProvider).valueOrNull ?? const ProgressModel();
    final name = user?.name ?? authUser?.displayName ?? 'Penjelajah';
    final email = user?.email ?? authUser?.email ?? '';
    final photo = user?.photoBase64;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(8), child: const TumpalBand(height: 12)),
        const SizedBox(height: 18),
        Center(
          child: GestureDetector(
            onTap: _avatarBusy ? null : () => _avatarMenu(photo != null),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 108,
                  height: 108,
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.goldLight, AppColors.gold, Color(0xFFB98524)],
                    ),
                  ),
                  child: ClipOval(
                    child: photo != null
                        ? Base64Image(photo, cacheWidth: 260)
                        : Container(
                            color: AppColors.sand,
                            alignment: Alignment.center,
                            child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: AppTheme.heading(42, color: AppColors.maroon)),
                          ),
                  ),
                ),
                if (_avatarBusy)
                  const SizedBox(
                    width: 108,
                    height: 108,
                    child: CircularProgressIndicator(strokeWidth: 5, color: AppColors.terracotta),
                  ),
                Positioned(
                  right: 0,
                  bottom: 2,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.terracotta,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: InkWell(
            onTap: () => _editName(name),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: Text(name, style: AppTheme.heading(24), textAlign: TextAlign.center)),
                  const SizedBox(width: 6),
                  const Icon(Icons.edit, size: 18, color: AppColors.brownSoft),
                ],
              ),
            ),
          ),
        ),
        Center(child: Text(email, style: const TextStyle(color: AppColors.brownSoft))),
        const SizedBox(height: 18),
        Row(
          children: [
            _Stat(label: 'Level', value: '${progress.totalXp ~/ 500 + 1}'),
            const SizedBox(width: 10),
            _Stat(label: 'Total XP', value: '${progress.totalXp}'),
            const SizedBox(width: 10),
            _Stat(label: 'Bab selesai', value: '${progress.completedCount}'),
          ],
        ),
        const SizedBox(height: 22),
        const SectionTitle('Lencana'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 14,
          runSpacing: 10,
          children: [
            for (final a in Achievements.all)
              BadgeMedal(def: a, unlocked: progress.achievements.contains(a.id), size: 52),
          ],
        ),
        const SizedBox(height: 22),
        const SectionTitle('Menu'),
        const SizedBox(height: 12),
        _MenuTile(
          icon: const LampungIcon('kapal', size: 26, color: AppColors.forest),
          title: 'Rencana Kunjungan Saya',
          subtitle: 'Jadwalkan kunjungan budaya dan pengingatnya',
          onTap: () => context.push('/visits'),
        ),
        _MenuTile(
          icon: const LampungIcon('siger', size: 26, color: AppColors.maroon),
          title: 'Daftar Belajar Budaya',
          subtitle: 'Materi yang ingin kamu pelajari',
          onTap: () => context.push('/study'),
        ),
        _MenuTile(
          icon: const Icon(Icons.alarm_rounded, color: AppColors.forest),
          title: 'Pengingat Belajar',
          subtitle: 'Atur jam dan hari belajarmu',
          onTap: () => context.push('/reminder'),
        ),
        _MenuTile(
          icon: const LampungIcon('tapis', size: 26, color: AppColors.maroon),
          title: 'Jurnal Budaya',
          subtitle: 'Catatan dan foto temuan budayamu',
          onTap: () => context.push('/journal'),
        ),
        _MenuTile(
          icon: const LampungIcon('gamolan', size: 26, color: AppColors.forest),
          title: 'Pengaturan',
          subtitle: 'Musik, suara, dan notifikasi',
          onTap: () => context.push('/settings'),
        ),
        _MenuTile(
          icon: const LampungIcon('rumah', size: 26, color: AppColors.terracotta),
          title: 'Tentang Aplikasi',
          subtitle: 'TAPAK LAMPUNG v1.0.0',
          onTap: _about,
        ),
        _MenuTile(
          icon: const Icon(Icons.logout, color: AppColors.error),
          title: 'Keluar',
          subtitle: 'Progresmu tetap tersimpan',
          onTap: _logout,
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Expanded(
        child: OrnateCard(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Text(value, style: AppTheme.heading(24, color: AppColors.terracotta)),
                const SizedBox(height: 2),
                Text(label, style: const TextStyle(color: AppColors.brownSoft, fontSize: 12)),
              ],
            ),
          ),
        ),
      );
}

class _MenuTile extends StatelessWidget {
  const _MenuTile(
      {required this.icon, required this.title, required this.subtitle, required this.onTap});
  final Widget icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.sand, width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: .18), shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: icon,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                        Text(subtitle,
                            style: const TextStyle(fontSize: 12, color: AppColors.brownSoft)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.brownSoft),
                ],
              ),
            ),
          ),
        ),
      );
}

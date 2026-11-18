import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/coming_soon_view.dart';
import '../../providers/providers.dart';

/// Placeholder dashboard admin. Diganti dashboard CRUD penuh di tahap admin.
class AdminPlaceholderScreen extends ConsumerWidget {
  const AdminPlaceholderScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard Admin'),
          actions: [
            IconButton(
              tooltip: 'Keluar',
              icon: const Icon(Icons.logout),
              onPressed: () => ref.read(authServiceProvider).logout(),
            ),
          ],
        ),
        body: const ComingSoonView(
          title: 'Akun admin terdeteksi',
          note: 'Custom claim admin berfungsi. CRUD materi, kuis, dan upload Storage dibangun di tahap admin.',
        ),
      );
}

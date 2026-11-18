import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/planner_providers.dart';
import '../../services/reminder_service.dart';
import '../../services/audio_service.dart';
import '../../services/fcm_service.dart';
import '../../core/theme/app_colors.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../progress/progress_screen.dart';
import 'home_screen.dart';

/// Bottom navigation 4 tab sesuai referensi: Beranda, Progres, Notifikasi, Profil.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});
  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioService.instance.startMusic();
      FcmService.instance.requestPermissionAndToken();
      FcmService.instance.flushPending();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Menjaga jadwal notifikasi LOKAL tetap sesuai data terbaru pengguna.
    ref.listen(visitsProvider, (_, next) {
      next.whenData(ReminderService.instance.syncVisits);
    });
    ref.listen(reminderSettingsProvider, (_, next) {
      next.whenData(ReminderService.instance.syncStudy);
    });
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: const [
            HomeScreen(),
            ProgressScreen(),
            NotificationsView(),
            ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: AppColors.sand,
          labelTextStyle: WidgetStateProperty.all(
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home, color: AppColors.terracotta),
                label: 'Beranda'),
            NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore, color: AppColors.terracotta),
                label: 'Progres'),
            NavigationDestination(
                icon: Icon(Icons.notifications_outlined),
                selectedIcon: Icon(Icons.notifications, color: AppColors.terracotta),
                label: 'Notifikasi'),
            NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person, color: AppColors.terracotta),
                label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

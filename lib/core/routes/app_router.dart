import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/login_screen.dart';
import '../illustrations/ornaments.dart';
import '../../features/auth/register_screen.dart';
import '../../features/challenge/challenge_screen.dart';
import '../../features/common/admin_placeholder_screen.dart';
import '../../features/common/role_gate_screen.dart';
import '../../features/home/home_shell.dart';
import '../../features/reminder/reminder_screen.dart';
import '../../features/study/study_screen.dart';
import '../../features/visits/visit_detail_screen.dart';
import '../../features/visits/visit_form_screen.dart';
import '../../features/visits/visits_screen.dart';
import '../../features/journal/journal_detail_screen.dart';
import '../../features/journal/journal_form_screen.dart';
import '../../features/journal/journal_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/map/chapter_picker_screen.dart';
import '../../features/map/map_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/progress/progress_screen.dart';
import '../../features/quiz/quiz_screen.dart';
import '../../features/quiz/result_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/story/story_screen.dart';
import '../../services/progress_service.dart';

class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Stream<User?> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<User?> _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

CustomTransitionPage<void> _page(GoRouterState s, Widget child, {bool plain = false}) =>
    CustomTransitionPage<void>(
      key: s.pageKey,
      child: AppBackdrop(plain: plain, child: child),
      transitionDuration: const Duration(milliseconds: 200),
      reverseTransitionDuration: const Duration(milliseconds: 160),
      transitionsBuilder: (_, anim, __, c) =>
          FadeTransition(opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut), child: c),
    );

GoRouter buildRouter() {
  const publicPaths = {'/splash', '/login', '/register'};
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _AuthRefresh(FirebaseAuth.instance.authStateChanges()),
    redirect: (context, state) {
      final loggedIn = FirebaseAuth.instance.currentUser != null;
      final loc = state.matchedLocation;
      if (!loggedIn && !publicPaths.contains(loc)) return '/login';
      if (loggedIn && (loc == '/login' || loc == '/register')) return '/gate';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', pageBuilder: (c, s) => _page(s, const SplashScreen())),
      GoRoute(path: '/login', pageBuilder: (c, s) => _page(s, const LoginScreen())),
      GoRoute(path: '/register', pageBuilder: (c, s) => _page(s, const RegisterScreen())),
      GoRoute(path: '/gate', pageBuilder: (c, s) => _page(s, const RoleGateScreen())),
      GoRoute(path: '/home', pageBuilder: (c, s) => _page(s, const HomeShell(), plain: true)),
      GoRoute(path: '/admin', pageBuilder: (c, s) => _page(s, const AdminPlaceholderScreen())),
      GoRoute(path: '/map', pageBuilder: (c, s) => _page(s, const MapScreen())),
      GoRoute(
        path: '/challenges',
        pageBuilder: (c, s) => _page(s, const ChapterPickerScreen(mode: PickerMode.challenge)),
      ),
      GoRoute(
        path: '/quiz',
        pageBuilder: (c, s) => _page(s, const ChapterPickerScreen(mode: PickerMode.quiz)),
      ),
      GoRoute(
        path: '/progress',
        pageBuilder: (c, s) => _page(s, const ProgressScreen(embedded: false)),
      ),
      GoRoute(
        path: '/notifications',
        pageBuilder: (c, s) => _page(s, const NotificationsScreen()),
      ),
      GoRoute(path: '/visits', pageBuilder: (c, s) => _page(s, const VisitsScreen())),
      GoRoute(path: '/visits/new', pageBuilder: (c, s) => _page(s, const VisitFormScreen())),
      GoRoute(
        path: '/visits/:id',
        pageBuilder: (c, s) => _page(s, VisitDetailScreen(visitId: s.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/visits/:id/edit',
        pageBuilder: (c, s) => _page(s, VisitFormScreen(visitId: s.pathParameters['id'])),
      ),
      GoRoute(path: '/study', pageBuilder: (c, s) => _page(s, const StudyScreen())),
      GoRoute(path: '/reminder', pageBuilder: (c, s) => _page(s, const ReminderScreen())),
      GoRoute(path: '/journal', pageBuilder: (c, s) => _page(s, const JournalScreen())),
      GoRoute(path: '/journal/new', pageBuilder: (c, s) => _page(s, const JournalFormScreen())),
      GoRoute(
        path: '/journal/:id',
        pageBuilder: (c, s) => _page(s, JournalDetailScreen(entryId: s.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/journal/:id/edit',
        pageBuilder: (c, s) => _page(s, JournalFormScreen(entryId: s.pathParameters['id'])),
      ),
      GoRoute(path: '/settings', pageBuilder: (c, s) => _page(s, const SettingsScreen())),
      GoRoute(
        path: '/chapter/:id',
        pageBuilder: (c, s) => _page(s, StoryScreen(chapterId: s.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/chapter/:id/challenge',
        pageBuilder: (c, s) => _page(s, ChallengeScreen(chapterId: s.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/chapter/:id/quiz',
        pageBuilder: (c, s) => _page(s, QuizScreen(chapterId: s.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/chapter/:id/result',
        pageBuilder: (c, s) => _page(
          s,
          ResultScreen(
            chapterId: s.pathParameters['id']!,
            outcome: s.extra is QuizOutcome ? s.extra as QuizOutcome : null,
          ),
        ),
      ),
    ],
  );
}

/// Router global agar bisa dipakai FcmService untuk membuka halaman dari notifikasi.
final GoRouter appRouter = buildRouter();

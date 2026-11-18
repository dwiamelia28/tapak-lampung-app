import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/challenge_model.dart';
import '../models/chapter_model.dart';
import '../models/content_model.dart';
import '../models/journal_model.dart';
import '../models/notification_model.dart';
import '../models/quiz_model.dart';
import '../services/content_service.dart';
import '../services/journal_service.dart';
import '../services/progress_service.dart';
import 'providers.dart';

final contentServiceProvider =
    Provider<ContentService>((ref) => ContentService(FirebaseFirestore.instance));

final progressServiceProvider =
    Provider<ProgressService>((ref) => ProgressService(FirebaseFirestore.instance));

final chaptersProvider = StreamProvider<List<ChapterModel>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return ref.watch(contentServiceProvider).watchChapters();
});

final chapterProvider = FutureProvider.autoDispose.family<ChapterModel?, String>(
  (ref, id) => ref.watch(contentServiceProvider).getChapter(id),
);

final contentsProvider = FutureProvider.autoDispose.family<List<ContentModel>, String>(
  (ref, id) => ref.watch(contentServiceProvider).getContents(id),
);

final quizProvider = FutureProvider.autoDispose.family<QuizModel?, String>(
  (ref, id) => ref.watch(contentServiceProvider).getQuiz(id),
);

final challengeProvider = FutureProvider.autoDispose.family<ChallengeModel?, String>(
  (ref, id) => ref.watch(contentServiceProvider).getChallenge(id),
);

final notificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).watchNotifications(user.uid);
});

final unreadCountProvider = Provider<int>((ref) {
  final list = ref.watch(notificationsProvider).valueOrNull ?? const [];
  return list.where((n) => !n.isRead).length;
});

final quizResultsProvider = StreamProvider<List<QuizResultModel>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).watchQuizResults(user.uid);
});

final journalServiceProvider =
    Provider<JournalService>((ref) => JournalService(FirebaseFirestore.instance));

final journalProvider = StreamProvider<List<JournalModel>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return ref.watch(journalServiceProvider).watch(user.uid);
});

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/content_model.dart';
import '../models/reminder_model.dart';
import '../models/study_model.dart';
import '../models/visit_model.dart';
import '../services/planner_service.dart';
import 'content_providers.dart';
import 'providers.dart';

final plannerServiceProvider =
    Provider<PlannerService>((ref) => PlannerService(FirebaseFirestore.instance));

final visitsProvider = StreamProvider<List<VisitModel>>((ref) {
  final u = ref.watch(authStateProvider).valueOrNull;
  if (u == null) return const Stream.empty();
  return ref.watch(plannerServiceProvider).watchVisits(u.uid);
});

final studyItemsProvider = StreamProvider<List<StudyItem>>((ref) {
  final u = ref.watch(authStateProvider).valueOrNull;
  if (u == null) return const Stream.empty();
  return ref.watch(plannerServiceProvider).watchStudy(u.uid);
});

final reminderSettingsProvider = StreamProvider<ReminderSettings>((ref) {
  final u = ref.watch(authStateProvider).valueOrNull;
  if (u == null) return const Stream.empty();
  return ref.watch(plannerServiceProvider).watchReminder(u.uid);
});

final allContentsProvider = FutureProvider<List<ContentModel>>(
  (ref) => ref.watch(contentServiceProvider).getAllContents(),
);

/// Topik materi = objek interaktif pada konten bab yang sudah ada (tidak disalin).
final studyTopicsProvider = Provider<AsyncValue<List<StudyTopic>>>((ref) {
  final chapters = ref.watch(chaptersProvider);
  final contents = ref.watch(allContentsProvider);
  if (chapters.isLoading || contents.isLoading) return const AsyncValue.loading();
  if (chapters.hasError) return AsyncValue.error(chapters.error!, chapters.stackTrace ?? StackTrace.empty);
  if (contents.hasError) return AsyncValue.error(contents.error!, contents.stackTrace ?? StackTrace.empty);
  final cl = chapters.valueOrNull ?? const [];
  final topics = <StudyTopic>[];
  for (final c in cl) {
    for (final ct in (contents.valueOrNull ?? <ContentModel>[]).where((x) => x.chapterId == c.id)) {
      for (final h in ct.hotspots) {
        topics.add(StudyTopic(
          chapterId: c.id,
          chapterTitle: c.title,
          chapterOrder: c.order,
          topicId: h.id,
          title: h.label,
          description: h.description,
        ));
      }
    }
  }
  return AsyncValue.data(topics);
});

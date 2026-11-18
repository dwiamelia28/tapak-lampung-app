import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

class ProgressModel {
  final List<String> completedChapterIds;
  final List<String> unlockedChapterIds;
  final List<String> achievements;
  final int totalXp;
  final int currentLevel;
  final String? lastChapterId;

  const ProgressModel({
    this.completedChapterIds = const [],
    this.unlockedChapterIds = const [AppConstants.firstChapterId],
    this.achievements = const [],
    this.totalXp = 0,
    this.currentLevel = 1,
    this.lastChapterId,
  });

  factory ProgressModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    if (d == null) return const ProgressModel();
    List<String> list(String k) =>
        (d[k] as List?)?.map((e) => e.toString()).toList() ?? <String>[];
    final unlocked = list('unlockedChapterIds');
    return ProgressModel(
      completedChapterIds: list('completedChapterIds'),
      unlockedChapterIds:
          unlocked.isEmpty ? const [AppConstants.firstChapterId] : unlocked,
      achievements: list('achievements'),
      totalXp: (d['totalXp'] as num?)?.toInt() ?? 0,
      currentLevel: (d['currentLevel'] as num?)?.toInt() ?? 1,
      lastChapterId: d['lastChapterId'] as String?,
    );
  }

  int get completedCount => completedChapterIds.length;
  double get completionRatio => completedCount / AppConstants.totalChapters;
  int get xpIntoLevel => totalXp % AppConstants.xpPerLevel;
}

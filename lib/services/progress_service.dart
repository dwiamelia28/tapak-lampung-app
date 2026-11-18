import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/achievements.dart';
import '../core/constants/app_constants.dart';
import '../models/chapter_model.dart';
import '../models/progress_model.dart';
import '../models/quiz_model.dart';

class QuizOutcome {
  const QuizOutcome({
    required this.chapterId,
    required this.chapterTitle,
    required this.score,
    required this.correct,
    required this.total,
    required this.passed,
    required this.xpGained,
    required this.newBadges,
    required this.firstCompletion,
    required this.levelBefore,
    required this.levelAfter,
    this.unlockedNext,
  });
  final String chapterId;
  final String chapterTitle;
  final int score;
  final int correct;
  final int total;
  final bool passed;
  final int xpGained;
  final List<AchievementDef> newBadges;
  final bool firstCompletion;
  final int levelBefore;
  final int levelAfter;
  final ChapterModel? unlockedNext;
}

/// Catatan keamanan: tanpa Cloud Functions (paket Spark), perhitungan XP,
/// unlock bab, dan lencana dilakukan di klien dalam satu transaksi Firestore.
/// Ini cukup untuk simulasi/tugas, tetapi tidak sekuat validasi di server.
class ProgressService {
  ProgressService(this._db);
  final FirebaseFirestore _db;

  Future<void> setLastChapter(String uid, String chapterId) async {
    try {
      await _db.collection('user_progress').doc(uid).set({
        'lastChapterId': chapterId,
        'lastActivityAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Tidak kritis; abaikan.
    }
  }

  Future<QuizOutcome> submitQuiz({
    required String uid,
    required ChapterModel chapter,
    required ChapterModel? next,
    required int totalChapters,
    required QuizModel quiz,
    required int correct,
  }) async {
    final total = quiz.questions.length;
    if (total == 0) throw StateError('Kuis belum memiliki soal.');
    final score = ((correct / total) * 100).round();
    final passed = score >= quiz.passingScore;

    final progRef = _db.collection('user_progress').doc(uid);
    final userRef = _db.collection('users').doc(uid);
    final resultRef = _db.collection('quiz_results').doc();
    QuizOutcome? outcome;

    await _db.runTransaction((tx) async {
      final snap = await tx.get(progRef);
      final p = ProgressModel.fromDoc(snap);

      final completed = {...p.completedChapterIds};
      final unlocked = {...p.unlockedChapterIds};
      final owned = {...p.achievements};

      var gained = correct * 20;
      final first = passed && !completed.contains(chapter.id);
      if (first) {
        completed.add(chapter.id);
        gained += 50;
      }

      ChapterModel? unlockedNext;
      if (passed && next != null && !unlocked.contains(next.id)) {
        unlocked.add(next.id);
        unlockedNext = next;
      }

      final badges = Achievements.evaluate(
        completedCount: completed.length,
        totalChapters: totalChapters,
        score: score,
        owned: owned,
      );
      for (final b in badges) {
        owned.add(b.id);
        gained += b.xp;
      }

      final levelBefore = p.totalXp ~/ AppConstants.xpPerLevel + 1;
      final xp = p.totalXp + gained;
      final levelAfter = xp ~/ AppConstants.xpPerLevel + 1;
      final now = FieldValue.serverTimestamp();

      tx.set(resultRef, {
        'userId': uid,
        'chapterId': chapter.id,
        'quizId': quiz.id,
        'score': score,
        'totalQuestions': total,
        'correctAnswers': correct,
        'completedAt': now,
      });
      tx.set(progRef, {
        'userId': uid,
        'completedChapterIds': completed.toList(),
        'unlockedChapterIds': unlocked.toList(),
        'achievements': owned.toList(),
        'totalXp': xp,
        'currentLevel': levelAfter,
        'lastChapterId': chapter.id,
        'lastActivityAt': now,
        'updatedAt': now,
      }, SetOptions(merge: true));
      tx.set(userRef, {
        'totalXp': xp,
        'level': levelAfter,
        'updatedAt': now,
      }, SetOptions(merge: true));

      void notify(String type, String title, String body, String targetId) {
        tx.set(_db.collection('notifications').doc(), {
          'userId': uid,
          'title': title,
          'body': body,
          'type': type,
          'targetId': targetId,
          'isRead': false,
          'createdAt': now,
        });
      }

      if (first) {
        notify(
          'chapter_complete',
          'Bab selesai!',
          'Hebat! Kamu berhasil menyelesaikan ${completed.length} perjalanan budaya Lampung.',
          chapter.id,
        );
      }
      if (unlockedNext != null) {
        notify(
          'chapter_unlock',
          'Perjalananmu berlanjut!',
          'Yuk, kenali ${unlockedNext.title}.',
          unlockedNext.id,
        );
      }
      for (final b in badges) {
        notify('achievement', 'Lencana baru: ${b.title}', b.description, b.id);
      }

      outcome = QuizOutcome(
        chapterId: chapter.id,
        chapterTitle: chapter.title,
        score: score,
        correct: correct,
        total: total,
        passed: passed,
        xpGained: gained,
        newBadges: badges,
        firstCompletion: first,
        levelBefore: levelBefore,
        levelAfter: levelAfter,
        unlockedNext: unlockedNext,
      );
    });
    return outcome!;
  }
}

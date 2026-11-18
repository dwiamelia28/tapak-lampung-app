import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/challenge_model.dart';
import '../models/chapter_model.dart';
import '../models/content_model.dart';
import '../models/quiz_model.dart';

class ContentService {
  ContentService(this._db);
  final FirebaseFirestore _db;

  /// Tidak menampilkan "kosong" jika yang terbaca baru cache lokal yang kosong;
  /// menunggu data dari server.
  Stream<List<ChapterModel>> watchChapters() => _db
      .collection('chapters')
      .orderBy('order')
      .snapshots(includeMetadataChanges: true)
      .where((s) => !(s.metadata.isFromCache && s.docs.isEmpty))
      .map((s) {
        debugPrint('chapters: ${s.docs.length} dokumen, dariCache=${s.metadata.isFromCache}');
        return s.docs.map(ChapterModel.fromDoc).where((c) => c.isPublished).toList();
      });

  Future<ChapterModel?> getChapter(String id) async {
    final d = await _db.collection('chapters').doc(id).get();
    return d.exists ? ChapterModel.fromDoc(d) : null;
  }

  Future<List<ContentModel>> getContents(String chapterId) async {
    final q = await _db
        .collection('cultural_contents')
        .where('chapterId', isEqualTo: chapterId)
        .get();
    final list = q.docs.map(ContentModel.fromDoc).toList();
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  Future<List<ContentModel>> getAllContents() async {
    final q = await _db.collection('cultural_contents').get();
    final list = q.docs.map(ContentModel.fromDoc).toList();
    list.sort((a, b) => a.chapterId.compareTo(b.chapterId));
    return list;
  }

  Future<QuizModel?> getQuiz(String chapterId) async {
    final q = await _db.collection('quizzes').where('chapterId', isEqualTo: chapterId).get();
    for (final d in q.docs) {
      if (d.data()['isPublished'] != false) return QuizModel.fromDoc(d);
    }
    return null;
  }

  Future<ChallengeModel?> getChallenge(String chapterId) async {
    final q = await _db.collection('challenges').where('chapterId', isEqualTo: chapterId).get();
    if (q.docs.isEmpty) return null;
    return ChallengeModel.fromDoc(q.docs.first);
  }
}

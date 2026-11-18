import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/utils/format.dart';
import '../models/reminder_model.dart';
import '../models/study_model.dart';
import '../models/visit_model.dart';

/// Rencana kunjungan, daftar belajar, dan pengaturan pengingat (semua per UID).
class PlannerService {
  PlannerService(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _visits => _db.collection('visit_plans');
  CollectionReference<Map<String, dynamic>> get _study => _db.collection('study_items');

  // ---- rencana kunjungan
  Stream<List<VisitModel>> watchVisits(String uid) =>
      _visits.where('userId', isEqualTo: uid).snapshots().map((s) {
        final l = s.docs.map(VisitModel.fromDoc).toList();
        l.sort((a, b) => a.date.compareTo(b.date));
        return l;
      });

  String newVisitId() => _visits.doc().id;

  Future<void> saveVisit({
    required String id,
    required String uid,
    required bool isNew,
    required String title,
    required String category,
    required DateTime date,
    required String note,
    required bool reminderOn,
    required bool visited,
    String? photoBase64,
  }) {
    final data = <String, dynamic>{
      'userId': uid,
      'title': title,
      'category': category,
      'visitDate': dateKey(date),
      'note': note,
      'reminderOn': reminderOn,
      'visited': visited,
      'photoBase64': photoBase64,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (isNew) {
      data['createdAt'] = FieldValue.serverTimestamp();
      return _visits.doc(id).set(data);
    }
    return _visits.doc(id).update(data);
  }

  Future<void> setVisited(String id, bool visited) =>
      _visits.doc(id).update({'visited': visited, 'updatedAt': FieldValue.serverTimestamp()});

  Future<void> setVisitReminder(String id, bool on) =>
      _visits.doc(id).update({'reminderOn': on, 'updatedAt': FieldValue.serverTimestamp()});

  Future<void> deleteVisit(String id) => _visits.doc(id).delete();

  // ---- daftar belajar
  Stream<List<StudyItem>> watchStudy(String uid) =>
      _study.where('userId', isEqualTo: uid).snapshots().map((s) {
        final l = s.docs.map(StudyItem.fromDoc).toList();
        l.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        return l;
      });

  String studyId(String uid, String chapterId, String topicId) => '${uid}_${chapterId}_$topicId';

  Future<void> addStudy(String uid, String chapterId, String topicId) =>
      _study.doc(studyId(uid, chapterId, topicId)).set({
        'userId': uid,
        'chapterId': chapterId,
        'topicId': topicId,
        'learned': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

  Future<void> removeStudy(String id) => _study.doc(id).delete();

  Future<void> setLearned(String id, bool learned) =>
      _study.doc(id).update({'learned': learned});

  // ---- pengingat belajar
  Stream<ReminderSettings> watchReminder(String uid) => _db
      .collection('reminder_settings')
      .doc(uid)
      .snapshots()
      .map(ReminderSettings.fromDoc);

  Future<void> saveReminder(String uid, ReminderSettings s) =>
      _db.collection('reminder_settings').doc(uid).set({
        'userId': uid,
        'enabled': s.enabled,
        'hour': s.hour,
        'minute': s.minute,
        'days': s.days.toList()..sort(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> deleteReminder(String uid) =>
      _db.collection('reminder_settings').doc(uid).delete();
}

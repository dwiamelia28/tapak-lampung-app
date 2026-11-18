import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import '../models/progress_model.dart';
import '../models/quiz_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  FirestoreService(this._db);
  final FirebaseFirestore _db;

  Stream<UserModel?> watchUser(String uid) => _db
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((s) => s.exists ? UserModel.fromDoc(s) : null);

  Stream<ProgressModel> watchProgress(String uid) =>
      _db.collection('user_progress').doc(uid).snapshots().map(ProgressModel.fromDoc);

  // Tanpa orderBy agar tidak membutuhkan indeks komposit; diurutkan di klien.
  Stream<List<NotificationModel>> watchNotifications(String uid) => _db
      .collection('notifications')
      .where('userId', isEqualTo: uid)
      .snapshots()
      .map((s) {
        final list = s.docs.map(NotificationModel.fromDoc).toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });

  Future<void> markNotificationRead(String id) =>
      _db.collection('notifications').doc(id).update({'isRead': true});

  Future<void> markAllNotificationsRead(String uid) async {
    final q = await _db.collection('notifications').where('userId', isEqualTo: uid).get();
    final batch = _db.batch();
    var n = 0;
    for (final d in q.docs) {
      if (d.data()['isRead'] != true) {
        batch.update(d.reference, {'isRead': true});
        n++;
      }
    }
    if (n > 0) await batch.commit();
  }

  Stream<List<QuizResultModel>> watchQuizResults(String uid) => _db
      .collection('quiz_results')
      .where('userId', isEqualTo: uid)
      .snapshots()
      .map((s) {
        final list = s.docs.map(QuizResultModel.fromDoc).toList();
        list.sort((a, b) => b.completedAt.compareTo(a.completedAt));
        return list;
      });
}

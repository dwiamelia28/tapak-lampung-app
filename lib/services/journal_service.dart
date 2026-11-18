import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/journal_model.dart';

class JournalService {
  JournalService(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('journal_entries');

  /// Diurutkan di klien agar tidak perlu indeks komposit.
  Stream<List<JournalModel>> watch(String uid) =>
      _col.where('userId', isEqualTo: uid).snapshots().map((s) {
        final list = s.docs.map(JournalModel.fromDoc).toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });

  String newId() => _col.doc().id;

  Future<void> create({
    required String id,
    required String uid,
    required String title,
    required String category,
    required String description,
    String? imageBase64,
  }) =>
      _col.doc(id).set({
        'userId': uid,
        'title': title,
        'category': category,
        'description': description,
        'imageBase64': imageBase64,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> update({
    required String id,
    required String title,
    required String category,
    required String description,
    String? imageBase64,
  }) =>
      _col.doc(id).update({
        'title': title,
        'category': category,
        'description': description,
        'imageBase64': imageBase64,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> delete(String id) => _col.doc(id).delete();
}

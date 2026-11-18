import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/utils/format.dart';
import 'model_utils.dart';

class VisitModel {
  const VisitModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.date,
    required this.note,
    required this.visited,
    required this.reminderOn,
    required this.createdAt,
    this.photoBase64,
  });
  final String id;
  final String userId;
  final String title; // nama tempat/tujuan, diisi sendiri oleh pengguna
  final String category;
  final DateTime date; // hanya tanggal (tanpa zona waktu)
  final String note;
  final bool visited;
  final bool reminderOn;
  final String? photoBase64;
  final DateTime createdAt;

  factory VisitModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    DateTime date;
    try {
      date = parseDateKey((d['visitDate'] as String?) ?? '');
    } catch (_) {
      date = DateTime.now();
    }
    return VisitModel(
      id: doc.id,
      userId: (d['userId'] as String?) ?? '',
      title: (d['title'] as String?) ?? '',
      category: (d['category'] as String?) ?? 'lainnya',
      date: date,
      note: (d['note'] as String?) ?? '',
      visited: (d['visited'] as bool?) ?? false,
      reminderOn: (d['reminderOn'] as bool?) ?? true,
      photoBase64: d['photoBase64'] as String?,
      createdAt: tsToDate(d['createdAt']) ?? DateTime.now(),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'model_utils.dart';

class JournalCategory {
  const JournalCategory(this.id, this.label, this.icon);
  final String id;
  final String label;
  final String icon; // kunci LampungIcon
  static const all = <JournalCategory>[
    JournalCategory('rumah', 'Rumah Adat', 'rumah'),
    JournalCategory('kain', 'Kain & Busana', 'tapis'),
    JournalCategory('seni', 'Seni & Pertunjukan', 'gamolan'),
    JournalCategory('kuliner', 'Kuliner', 'kopi'),
    JournalCategory('lainnya', 'Lainnya', 'siger'),
  ];
  static JournalCategory of(String id) =>
      all.firstWhere((c) => c.id == id, orElse: () => all.last);
}

class JournalModel {
  const JournalModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.description,
    required this.createdAt,
    this.imageBase64,
  });
  final String id;
  final String userId;
  final String title;
  final String category;
  final String description;
  final String? imageBase64; // foto terkompres, Base64, disimpan di Firestore
  final DateTime createdAt;

  factory JournalModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return JournalModel(
      id: doc.id,
      userId: (d['userId'] as String?) ?? '',
      title: (d['title'] as String?) ?? '',
      category: (d['category'] as String?) ?? 'lainnya',
      description: (d['description'] as String?) ?? '',
      imageBase64: d['imageBase64'] as String?,
      createdAt: tsToDate(d['createdAt']) ?? DateTime.now(),
    );
  }
}

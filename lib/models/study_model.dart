import 'package:cloud_firestore/cloud_firestore.dart';
import 'model_utils.dart';

/// Referensi pribadi ke satu topik materi (tanpa menyalin isi materi).
class StudyItem {
  const StudyItem({
    required this.id,
    required this.chapterId,
    required this.topicId,
    required this.learned,
    required this.createdAt,
  });
  final String id;
  final String chapterId;
  final String topicId;
  final bool learned;
  final DateTime createdAt;

  factory StudyItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return StudyItem(
      id: doc.id,
      chapterId: (d['chapterId'] as String?) ?? '',
      topicId: (d['topicId'] as String?) ?? '',
      learned: (d['learned'] as bool?) ?? false,
      createdAt: tsToDate(d['createdAt']) ?? DateTime.now(),
    );
  }
}

/// Topik materi yang diturunkan dari konten bab yang sudah ada.
class StudyTopic {
  const StudyTopic({
    required this.chapterId,
    required this.chapterTitle,
    required this.chapterOrder,
    required this.topicId,
    required this.title,
    required this.description,
  });
  final String chapterId;
  final String chapterTitle;
  final int chapterOrder;
  final String topicId;
  final String title;
  final String description;
  String get key => '${chapterId}_$topicId';
}

import 'package:cloud_firestore/cloud_firestore.dart';

class ChapterModel {
  const ChapterModel({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    this.theme = 'rumah',
    this.isPublished = true,
    this.isLockedByDefault = true,
    this.verified = false,
    this.coverImageUrl,
  });

  final String id;
  final String title;
  final String description;
  final int order;
  final String theme; // rumah | kain | seni | kuliner
  final bool isPublished;
  final bool isLockedByDefault;
  final bool verified;
  final String? coverImageUrl;

  factory ChapterModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return ChapterModel(
      id: doc.id,
      title: (d['title'] as String?) ?? 'Bab',
      description: (d['description'] as String?) ?? '',
      order: (d['order'] as num?)?.toInt() ?? 0,
      theme: (d['theme'] as String?) ?? 'rumah',
      isPublished: (d['isPublished'] as bool?) ?? true,
      isLockedByDefault: (d['isLockedByDefault'] as bool?) ?? true,
      verified: (d['verified'] as bool?) ?? false,
      coverImageUrl: d['coverImageUrl'] as String?,
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'model_utils.dart';

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.targetId,
    required this.isRead,
    required this.createdAt,
    this.route = '',
  });
  final String id;
  final String title;
  final String body;
  final String type; // chapter_unlock | chapter_complete | achievement | fcm
  final String targetId;
  final bool isRead;
  final DateTime createdAt;
  final String route;

  factory NotificationModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return NotificationModel(
      id: doc.id,
      title: (d['title'] as String?) ?? '',
      body: (d['body'] as String?) ?? '',
      type: (d['type'] as String?) ?? '',
      targetId: (d['targetId'] as String?) ?? '',
      isRead: (d['isRead'] as bool?) ?? false,
      createdAt: tsToDate(d['createdAt']) ?? DateTime.now(),
      route: (d['route'] as String?) ?? '',
    );
  }
}

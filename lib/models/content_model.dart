import 'package:cloud_firestore/cloud_firestore.dart';
import 'model_utils.dart';

class Hotspot {
  const Hotspot({
    required this.id,
    required this.label,
    required this.description,
    required this.dx,
    required this.dy,
  });
  final String id;
  final String label;
  final String description;
  final double dx; // 0..1 relatif terhadap lebar ilustrasi
  final double dy; // 0..1 relatif terhadap tinggi ilustrasi

  factory Hotspot.fromMap(Map<String, dynamic> m) => Hotspot(
        id: (m['id'] ?? '').toString(),
        label: (m['label'] ?? '').toString(),
        description: (m['description'] ?? '').toString(),
        dx: (m['dx'] as num?)?.toDouble() ?? 0.5,
        dy: (m['dy'] as num?)?.toDouble() ?? 0.5,
      );
}

class ContentModel {
  const ContentModel({
    required this.id,
    required this.chapterId,
    required this.title,
    required this.body,
    required this.keyFacts,
    required this.hotspots,
    required this.order,
    this.imageUrl,
    this.verified = false,
  });

  final String id;
  final String chapterId;
  final String title;
  final String body;
  final List<String> keyFacts;
  final List<Hotspot> hotspots;
  final int order;
  final String? imageUrl;
  final bool verified;

  List<String> get paragraphs =>
      body.split(RegExp(r'\n\s*\n')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  factory ContentModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return ContentModel(
      id: doc.id,
      chapterId: (d['chapterId'] as String?) ?? '',
      title: (d['title'] as String?) ?? '',
      body: (d['body'] as String?) ?? '',
      keyFacts: strList(d['keyFacts']),
      hotspots: mapList(d['interactiveObjects']).map(Hotspot.fromMap).toList(),
      order: (d['order'] as num?)?.toInt() ?? 0,
      imageUrl: d['imageUrl'] as String?,
      verified: (d['verified'] as bool?) ?? false,
    );
  }
}

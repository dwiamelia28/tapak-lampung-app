import 'package:cloud_firestore/cloud_firestore.dart';
import 'model_utils.dart';

class ChallengeTarget {
  const ChallengeTarget({required this.id, required this.label, required this.icon});
  final String id;
  final String label;
  final String icon;
  factory ChallengeTarget.fromMap(Map<String, dynamic> m) => ChallengeTarget(
        id: (m['id'] ?? '').toString(),
        label: (m['label'] ?? '').toString(),
        icon: (m['icon'] ?? '').toString(),
      );
}

class ChallengeToken {
  const ChallengeToken({required this.id, required this.label, required this.target});
  final String id;
  final String label;
  final String target;
  factory ChallengeToken.fromMap(Map<String, dynamic> m) => ChallengeToken(
        id: (m['id'] ?? '').toString(),
        label: (m['label'] ?? '').toString(),
        target: (m['target'] ?? '').toString(),
      );
}

class ChallengeModel {
  const ChallengeModel({
    required this.id,
    required this.chapterId,
    required this.type,
    required this.title,
    required this.instruction,
    required this.findIds,
    required this.targets,
    required this.tokens,
  });
  final String id;
  final String chapterId;
  final String type; // find | match
  final String title;
  final String instruction;
  final List<String> findIds;
  final List<ChallengeTarget> targets;
  final List<ChallengeToken> tokens;

  factory ChallengeModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return ChallengeModel(
      id: doc.id,
      chapterId: (d['chapterId'] as String?) ?? '',
      type: (d['type'] as String?) ?? 'find',
      title: (d['title'] as String?) ?? 'Tantangan',
      instruction: (d['instruction'] as String?) ?? '',
      findIds: strList(d['findIds']),
      targets: mapList(d['targets']).map(ChallengeTarget.fromMap).toList(),
      tokens: mapList(d['tokens']).map(ChallengeToken.fromMap).toList(),
    );
  }
}

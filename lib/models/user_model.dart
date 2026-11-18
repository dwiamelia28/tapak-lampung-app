import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String? photoBase64; // foto profil terkompres (Base64)
  final int totalXp;
  final int level;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.role = 'user',
    this.photoBase64,
    this.totalXp = 0,
    this.level = 1,
  });

  factory UserModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return UserModel(
      uid: doc.id,
      name: (d['name'] as String?) ?? 'Penjelajah',
      email: (d['email'] as String?) ?? '',
      role: (d['role'] as String?) ?? 'user',
      photoBase64: d['photoBase64'] as String?,
      totalXp: (d['totalXp'] as num?)?.toInt() ?? 0,
      level: (d['level'] as num?)?.toInt() ?? 1,
    );
  }

  String get firstName => name.trim().split(' ').first;
}

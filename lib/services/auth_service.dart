import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/app_constants.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class AuthService {
  AuthService(this._auth, this._db);
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  Stream<User?> get authChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user!;
      await user.updateDisplayName(name.trim());
      final now = FieldValue.serverTimestamp();
      final batch = _db.batch();
      batch.set(_db.collection('users').doc(user.uid), {
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim(),
        'role': 'user',
        'photoBase64': null,
        'totalXp': 0,
        'level': 1,
        'createdAt': now,
        'updatedAt': now,
      });
      batch.set(_db.collection('user_progress').doc(user.uid), {
        'userId': user.uid,
        'completedChapterIds': <String>[],
        'unlockedChapterIds': <String>[AppConstants.firstChapterId],
        'totalXp': 0,
        'currentLevel': 1,
        'achievements': <String>[],
        'lastChapterId': null,
        'lastActivityAt': now,
        'updatedAt': now,
      });
      await batch.commit();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_message(e));
    } on FirebaseException catch (e) {
      throw AuthException('Gagal menyimpan data akun (${e.code}).');
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_message(e));
    }
  }

  Future<void> logout() => _auth.signOut();

  /// Admin ditentukan oleh custom claim `admin: true` (di-set lewat
  /// scripts/set_admin.js), bukan dari data yang bisa diubah klien.
  Future<bool> isAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final token = await user.getIdTokenResult(true);
    return token.claims?['admin'] == true;
  }

  String _message(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Silakan masuk.';
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
      case 'user-disabled':
        return 'Akun ini dinonaktifkan.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi beberapa saat.';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet.';
      default:
        return 'Terjadi kesalahan (${e.code}).';
    }
  }
}

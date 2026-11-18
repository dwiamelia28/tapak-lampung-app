import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService(this._storage);
  final FirebaseStorage _storage;

  /// Mengunggah gambar. Pantau [UploadTask.snapshotEvents] untuk indikator proses.
  UploadTask upload({required String path, required File file}) {
    return _storage
        .ref(path)
        .putFile(file, SettableMetadata(contentType: 'image/jpeg'));
  }

  /// Menghapus file; dianggap berhasil jika file sudah tidak ada.
  Future<void> delete(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      await _storage.ref(path).delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') rethrow;
    }
  }

  static String friendlyError(Object e) {
    if (e is FirebaseException) {
      switch (e.code) {
        case 'unauthorized':
          return 'Tidak diizinkan. Pastikan Storage Rules sudah dipasang dan kamu sudah login.';
        case 'bucket-not-found':
        case 'project-not-found':
          return 'Firebase Storage belum aktif di project ini. Aktifkan dulu di Firebase Console.';
        case 'retry-limit-exceeded':
        case 'network-request-failed':
          return 'Koneksi bermasalah. Coba lagi.';
        case 'canceled':
          return 'Unggah dibatalkan.';
        case 'object-not-found':
          return 'File tidak ditemukan.';
      }
      return 'Storage error (${e.code}).';
    }
    return 'Terjadi kesalahan: $e';
  }
}

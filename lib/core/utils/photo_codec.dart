import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class PhotoTooLargeException implements Exception {
  const PhotoTooLargeException();
  @override
  String toString() => 'Foto terlalu besar meski sudah dikompres. Coba foto lain.';
}

class _Args {
  const _Args(this.bytes, this.maxWidth, this.maxBytes);
  final Uint8List bytes;
  final int maxWidth;
  final int maxBytes;
}

Uint8List? _compress(_Args a) {
  final decoded = img.decodeImage(a.bytes);
  if (decoded == null) return null;
  var image = img.bakeOrientation(decoded);
  if (image.width > a.maxWidth) image = img.copyResize(image, width: a.maxWidth);
  var quality = 75;
  while (true) {
    final out = Uint8List.fromList(img.encodeJpg(image, quality: quality));
    if (out.length <= a.maxBytes) return out;
    if (quality > 40) {
      quality -= 10;
    } else if (image.width > 240) {
      image = img.copyResize(image, width: (image.width * 0.8).round());
    } else {
      return out;
    }
  }
}

/// Kompresi foto lalu Base64. Foto disimpan di dokumen Firestore (batas 1 MiB per
/// dokumen), BUKAN di Firebase Storage. Kompresi dijalankan di isolate terpisah.
class PhotoCodec {
  PhotoCodec._();

  static Future<Uint8List> compress(Uint8List bytes,
      {int maxWidth = 800, int maxBytes = 150 * 1024}) async {
    final out = await compute(_compress, _Args(bytes, maxWidth, maxBytes));
    if (out == null) throw const FormatException('Foto tidak dapat dibaca.');
    if (out.length > maxBytes) throw const PhotoTooLargeException();
    return out;
  }

  static String encode(Uint8List bytes) => base64Encode(bytes);
}

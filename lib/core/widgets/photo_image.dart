import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../constants/photo_assets.dart';
import '../theme/app_colors.dart';

/// Foto budaya dari assets/photos. Jika file belum dipasang, tampil placeholder
/// yang jelas ("foto belum dipasang"), bukan gambar pengganti.
class PhotoImage extends StatelessWidget {
  const PhotoImage(this.photo, {super.key, this.fit = BoxFit.cover, this.compact = false});
  final CulturePhoto photo;
  final BoxFit fit;
  final bool compact;

  @override
  Widget build(BuildContext context) => Image.asset(
        photo.asset,
        fit: fit,
        errorBuilder: (_, __, ___) => _Placeholder(title: photo.title, compact: compact),
      );
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.title, required this.compact});
  final String title;
  final bool compact;
  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEBD9B8), Color(0xFFD9C29A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.image_not_supported_outlined, color: AppColors.brownSoft, size: 30),
            if (!compact) ...[
              const SizedBox(height: 6),
              Text('Foto belum dipasang',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.brown)),
              const SizedBox(height: 2),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: AppColors.brownSoft)),
            ],
          ],
        ),
      );
}

/// Menampilkan foto pengguna yang disimpan sebagai Base64 (di Firestore).
class Base64Image extends StatefulWidget {
  const Base64Image(this.data, {super.key, this.fit = BoxFit.cover, this.cacheWidth});
  final String data;
  final BoxFit fit;
  final int? cacheWidth;
  @override
  State<Base64Image> createState() => _Base64ImageState();
}

class _Base64ImageState extends State<Base64Image> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  @override
  void didUpdateWidget(Base64Image old) {
    super.didUpdateWidget(old);
    if (old.data != widget.data) _decode();
  }

  void _decode() {
    try {
      _bytes = base64Decode(widget.data);
    } catch (_) {
      _bytes = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bytes == null) {
      return Container(
        color: AppColors.sand,
        child: const Icon(Icons.broken_image_outlined, color: AppColors.brownSoft),
      );
    }
    return Image.memory(_bytes!, fit: widget.fit, gaplessPlayback: true, cacheWidth: widget.cacheWidth);
  }
}

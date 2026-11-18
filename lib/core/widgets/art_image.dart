import 'package:flutter/material.dart';

/// Memakai gambar dari assets/illustrations jika file tersedia.
/// Jika file belum ada, otomatis memakai [fallback] (ilustrasi vektor bawaan).
class ArtImage extends StatelessWidget {
  const ArtImage({
    super.key,
    required this.asset,
    required this.fallback,
    this.fit = BoxFit.cover,
    this.decorate,
  });
  final String asset;
  final Widget fallback;
  final BoxFit fit;
  final Widget Function(Widget image)? decorate;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      fit: fit,
      errorBuilder: (_, __, ___) => fallback,
      frameBuilder: decorate == null
          ? null
          : (context, child, frame, sync) => decorate!(child),
    );
  }
}

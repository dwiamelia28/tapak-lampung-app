import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/content_model.dart';
import '../illustrations/ornaments.dart';
import '../illustrations/painters.dart';
import '../theme/app_colors.dart';
import 'art_image.dart';

enum SceneMode { explore, find }

/// Ilustrasi bab (statis) dengan objek interaktif.
/// - explore: titik emas yang bisa diketuk untuk membaca penjelasan.
/// - find: titik disembunyikan; layar mendeteksi ketukan terdekat (untuk tantangan).
/// Jika assets/illustrations/chapter_<tema>.png ada, gambar itu dipakai;
/// posisi hotspot (dx, dy) mungkin perlu disesuaikan di Firestore.
class ChapterScene extends StatelessWidget {
  const ChapterScene({
    super.key,
    required this.theme,
    required this.hotspots,
    this.mode = SceneMode.explore,
    this.foundIds = const {},
    this.onHotspotTap,
    this.onMiss,
  });
  final String theme;
  final List<Hotspot> hotspots;
  final SceneMode mode;
  final Set<String> foundIds;
  final ValueChanged<Hotspot>? onHotspotTap;
  final VoidCallback? onMiss;

  void _findTap(Offset pos, double w, double h) {
    Hotspot? best;
    var bestD = double.infinity;
    for (final hs in hotspots) {
      final d = (Offset(hs.dx * w, hs.dy * h) - pos).distance;
      if (d < bestD) {
        bestD = d;
        best = hs;
      }
    }
    if (best != null && bestD <= math.min(w, h) * .12) {
      onHotspotTap?.call(best);
    } else {
      onMiss?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final explore = mode == SceneMode.explore;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(29),
        gradient: const LinearGradient(
          colors: [AppColors.goldLight, AppColors.gold, Color(0xFFB98524)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brown.withValues(alpha: .18),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: AspectRatio(
          aspectRatio: 1.25,
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth, h = c.maxHeight;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: explore ? null : (d) => _findTap(d.localPosition, w, h),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ArtImage(
                        asset: 'assets/illustrations/chapter_$theme.png',
                        fallback: RepaintBoundary(
                          child: CustomPaint(painter: _SceneBgPainter(theme)),
                        ),
                      ),
                    ),
                    const Positioned(left: 0, right: 0, bottom: 0, child: TumpalBand(height: 12)),
                    for (final hs in hotspots)
                      if (explore || foundIds.contains(hs.id))
                        Positioned(
                          left: hs.dx * w - 20,
                          top: hs.dy * h - 20,
                          width: 40,
                          height: 40,
                          child: _HotspotDot(
                            found: foundIds.contains(hs.id),
                            interactive: explore,
                            onTap: () => onHotspotTap?.call(hs),
                          ),
                        ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HotspotDot extends StatelessWidget {
  const _HotspotDot({required this.found, required this.interactive, required this.onTap});
  final bool found;
  final bool interactive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: interactive ? onTap : null,
        child: Center(
          child: Container(
            width: 34,
            height: 34,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: .55),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: found ? AppColors.success : AppColors.gold,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(found ? Icons.check : Icons.touch_app, size: 14, color: Colors.white),
            ),
          ),
        ),
      );
}

class _SceneBgPainter extends CustomPainter {
  _SceneBgPainter(this.theme);
  final String theme;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final w = size.width, h = size.height;
    final colors = switch (theme) {
      'kain' => const [Color(0xFFFBE6C8), Color(0xFFF1CFA0)],
      'seni' => const [Color(0xFFFFD9A0), Color(0xFFF2AE83)],
      'kuliner' => const [Color(0xFFFCE9C9), Color(0xFFF6D49B)],
      _ => const [Color(0xFFBFE3F2), Color(0xFFFBE9C8)],
    };
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: colors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rect),
    );

    Path hill(double base, double amp, double phase) {
      final p = Path()..moveTo(0, h);
      for (double x = 0; x <= w; x += 5) {
        p.lineTo(x, base + math.sin(x / w * math.pi * 3 + phase) * amp);
      }
      return p
        ..lineTo(w, h)
        ..close();
    }

    if (theme == 'rumah') {
      canvas.drawCircle(Offset(w * .82, h * .18), h * .08, Paint()..color = AppColors.goldLight);
      canvas.drawPath(hill(h * .70, h * .04, 1), Paint()..color = const Color(0xFF6FA57F));
      canvas.drawPath(hill(h * .82, h * .03, 3), Paint()..color = AppColors.forest);
      paintPalm(canvas, Offset(w * .07, h * .86), h * .38);
      paintPalm(canvas, Offset(w * .94, h * .86), h * .30);
    } else if (theme == 'seni') {
      canvas.drawRect(Rect.fromLTWH(0, h * .85, w, h * .15), Paint()..color = const Color(0xFF8A5A33));
      for (final left in [true, false]) {
        final x0 = left ? 0.0 : w;
        final dir = left ? 1.0 : -1.0;
        final curtain = Path()
          ..moveTo(x0, 0)
          ..lineTo(x0 + dir * w * .13, 0)
          ..quadraticBezierTo(x0 + dir * w * .05, h * .45, x0 + dir * w * .11, h * .88)
          ..lineTo(x0, h * .88)
          ..close();
        canvas.drawPath(curtain, Paint()..color = AppColors.maroon);
        canvas.drawPath(
          curtain,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = AppColors.gold,
        );
      }
      paintTumpalRow(canvas, Rect.fromLTWH(w * .14, h * .02, w * .72, h * .035));
    } else if (theme == 'kain') {
      canvas.drawRect(Rect.fromLTWH(0, h * .90, w, h * .10), Paint()..color = const Color(0xFFB98A5A));
      for (var i = 0; i < 9; i++) {
        canvas.drawLine(
          Offset(w * i / 8, 0),
          Offset(w * i / 8, h * .90),
          Paint()
            ..color = Colors.white.withValues(alpha: .25)
            ..strokeWidth = 2,
        );
      }
    }

    paintTheme(canvas, theme, rect);
  }

  @override
  bool shouldRepaint(covariant _SceneBgPainter old) => old.theme != theme;
}

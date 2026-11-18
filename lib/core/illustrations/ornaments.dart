import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Ornamen bergaya Lampung yang seluruhnya STATIS (digambar sekali, di-cache),
/// sehingga ringan: pita tumpal, latar ketupat/tapis, bingkai sudut emas, kapal, kelapa.

void paintTumpalRow(Canvas canvas, Rect r,
    {Color bg = AppColors.maroon, Color tri = AppColors.gold}) {
  canvas.drawRect(r, Paint()..color = bg);
  final n = math.max(1, (r.width / (r.height * 1.1)).round());
  final tw = r.width / n;
  final p = Paint()..color = tri;
  for (var i = 0; i < n; i++) {
    final x0 = r.left + tw * i;
    canvas.drawPath(
      Path()
        ..moveTo(x0, r.bottom)
        ..lineTo(x0 + tw / 2, r.top + r.height * .14)
        ..lineTo(x0 + tw, r.bottom)
        ..close(),
      p,
    );
  }
  canvas.drawRect(Rect.fromLTWH(r.left, r.top, r.width, math.max(1.0, r.height * .08)), p);
}

void paintKapal(Canvas canvas, Offset c, double s,
    {Color hull = AppColors.maroon, Color sail = AppColors.goldLight}) {
  canvas.drawOval(Rect.fromCenter(center: c.translate(0, s * .45), width: s * 1.5, height: s * .16),
      Paint()..color = Colors.black.withValues(alpha: .12));
  final h = Path()
    ..moveTo(c.dx - s * .62, c.dy + s * .05)
    ..quadraticBezierTo(c.dx, c.dy + s * .66, c.dx + s * .62, c.dy + s * .05)
    ..close();
  canvas.drawPath(h, Paint()..color = hull);
  canvas.drawPath(
      h,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * .04
        ..color = AppColors.brown);
  canvas.drawLine(c.translate(-s * .5, s * .12), c.translate(s * .5, s * .12),
      Paint()..color = AppColors.gold..strokeWidth = s * .06);
  canvas.drawLine(c.translate(0, s * .05), c.translate(0, -s * .8),
      Paint()..color = AppColors.brown..strokeWidth = s * .05 ..strokeCap = StrokeCap.round);
  canvas.drawPath(
      Path()
        ..moveTo(c.dx + s * .04, c.dy - s * .76)
        ..lineTo(c.dx + s * .04, c.dy)
        ..lineTo(c.dx + s * .52, c.dy)
        ..close(),
      Paint()..color = sail);
  canvas.drawPath(
      Path()
        ..moveTo(c.dx - s * .04, c.dy - s * .55)
        ..lineTo(c.dx - s * .04, c.dy)
        ..lineTo(c.dx - s * .42, c.dy)
        ..close(),
      Paint()..color = AppColors.terracotta);
}

void paintPalm(Canvas canvas, Offset base, double ht) {
  final top = Offset(base.dx + ht * .12, base.dy - ht);
  canvas.drawPath(
    Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(base.dx + ht * .18, base.dy - ht * .55, top.dx, top.dy),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ht * .07
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF6B4226),
  );
  final frond = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = ht * .05
    ..strokeCap = StrokeCap.round
    ..color = const Color(0xFF2F7D4F);
  for (var i = 0; i < 6; i++) {
    final a = -math.pi / 2 + (i - 2.5) * .55;
    final len = ht * .45;
    final end = top + Offset(math.cos(a), math.sin(a)) * len + Offset(0, len * .35);
    final ctrl = top + Offset(math.cos(a), math.sin(a)) * len * .6 - Offset(0, len * .22);
    canvas.drawPath(
        Path()
          ..moveTo(top.dx, top.dy)
          ..quadraticBezierTo(ctrl.dx, ctrl.dy, end.dx, end.dy),
        frond);
  }
}

// ------------------------------------------------------------------ widgets

/// Pita tumpal (segitiga emas di atas maroon), khas tepian kain Lampung.
class TumpalBand extends StatelessWidget {
  const TumpalBand({super.key, this.height = 14, this.bg = AppColors.maroon});
  final double height;
  final Color bg;
  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(painter: _TumpalPainter(bg)),
        ),
      );
}

class _TumpalPainter extends CustomPainter {
  _TumpalPainter(this.bg);
  final Color bg;
  @override
  void paint(Canvas canvas, Size s) => paintTumpalRow(canvas, Offset.zero & s, bg: bg);
  @override
  bool shouldRepaint(covariant _TumpalPainter old) => old.bg != bg;
}

/// Latar krem dengan motif ketupat/tapis samar. Dipasang di setiap halaman.
class AppBackdrop extends StatelessWidget {
  const AppBackdrop({super.key, required this.child, this.plain = false});
  final Widget child;
  final bool plain; // true: latar krem polos (dipakai beranda yang bersih)
  @override
  Widget build(BuildContext context) => plain
      ? ColoredBox(color: AppColors.cream, child: child)
      : Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: RepaintBoundary(child: CustomPaint(painter: _PatternPainter())),
          ),
          child,
        ],
      );
}

class _PatternPainter extends CustomPainter {
  const _PatternPainter();
  @override
  void paint(Canvas canvas, Size s) {
    canvas.drawRect(Offset.zero & s, Paint()..color = AppColors.cream);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = AppColors.maroon.withValues(alpha: .07);
    final dot = Paint()..color = AppColors.gold.withValues(alpha: .20);
    const step = 60.0;
    for (var r = 0; r * step < s.height + step; r++) {
      for (var c = 0; c * step < s.width + step; c++) {
        final cx = c * step + (r.isOdd ? step / 2 : 0);
        final cy = r * step;
        canvas.drawPath(
          Path()
            ..moveTo(cx, cy - 12)
            ..lineTo(cx + 12, cy)
            ..lineTo(cx, cy + 12)
            ..lineTo(cx - 12, cy)
            ..close(),
          line,
        );
        canvas.drawCircle(Offset(cx, cy), 2.2, dot);
        canvas.drawCircle(Offset(cx + step / 2, cy + step / 2), 1.6, dot);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PatternPainter old) => false;
}

/// Kartu putih berbingkai krem dengan hiasan sudut emas.
class OrnateCard extends StatelessWidget {
  const OrnateCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = Colors.white,
  });
  final Widget child;
  final EdgeInsets padding;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.sand, width: 1.5),
        ),
        child: CustomPaint(
          foregroundPainter: const _CornerPainter(),
          child: Padding(padding: padding, child: child),
        ),
      );
}

class _CornerPainter extends CustomPainter {
  const _CornerPainter();
  @override
  void paint(Canvas canvas, Size s) {
    final gold = Paint()..color = AppColors.gold;
    final ln = Paint()
      ..color = AppColors.gold.withValues(alpha: .85)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    void corner(double x, double y, double sx, double sy) {
      canvas.drawPath(
        Path()
          ..moveTo(x, y - 4 * sy)
          ..lineTo(x + 4 * sx, y)
          ..lineTo(x, y + 4 * sy)
          ..lineTo(x - 4 * sx, y)
          ..close(),
        gold,
      );
      canvas.drawLine(Offset(x + 8 * sx, y), Offset(x + 22 * sx, y), ln);
      canvas.drawLine(Offset(x, y + 8 * sy), Offset(x, y + 22 * sy), ln);
    }

    const m = 9.0;
    corner(m, m, 1, 1);
    corner(s.width - m, m, -1, 1);
    corner(m, s.height - m, 1, -1);
    corner(s.width - m, s.height - m, -1, -1);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter old) => false;
}

class _Diamond extends StatelessWidget {
  const _Diamond(this.size);
  final double size;
  @override
  Widget build(BuildContext context) => Transform.rotate(
        angle: math.pi / 4,
        child: Container(width: size, height: size, color: AppColors.gold),
      );
}

/// Judul bagian dengan ornamen ketupat dan garis emas.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Row(
        children: [
          const _Diamond(9),
          const SizedBox(width: 10),
          Text(text, style: AppTheme.heading(19)),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.gold, AppColors.gold.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
        ],
      );
}

/// Spanduk judul bermotif: maroon dengan ketupat emas, kapal kecil, dan pita tumpal.
class OrnamentBanner extends StatelessWidget {
  const OrnamentBanner({super.key, required this.title, this.subtitle, this.height = 96});
  final String title;
  final String? subtitle;
  final double height;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            children: [
              const Positioned.fill(
                child: RepaintBoundary(child: CustomPaint(painter: _BannerPainter())),
              ),
              Positioned(
                left: 18,
                right: 18,
                top: 0,
                bottom: 14,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTheme.heading(22, color: Colors.white)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(subtitle!,
                          style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _BannerPainter extends CustomPainter {
  const _BannerPainter();
  @override
  void paint(Canvas canvas, Size s) {
    canvas.drawRect(
      Offset.zero & s,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF8E2A38), AppColors.maroon, Color(0xFF5A1620)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Offset.zero & s),
    );
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = AppColors.gold.withValues(alpha: .35);
    for (var r = 0; r < 3; r++) {
      for (var c = 0; c * 34 < s.width + 34; c++) {
        final cx = c * 34.0 + (r.isOdd ? 17 : 0);
        final cy = 10.0 + r * 28;
        canvas.drawPath(
          Path()
            ..moveTo(cx, cy - 9)
            ..lineTo(cx + 9, cy)
            ..lineTo(cx, cy + 9)
            ..lineTo(cx - 9, cy)
            ..close(),
          line,
        );
      }
    }
    paintKapal(canvas, Offset(s.width - 44, s.height * .42), 26,
        hull: AppColors.gold, sail: AppColors.goldLight);
    paintTumpalRow(canvas, Rect.fromLTWH(0, s.height - 14, s.width, 14),
        bg: const Color(0xFF4A1019));
  }

  @override
  bool shouldRepaint(covariant _BannerPainter old) => false;
}

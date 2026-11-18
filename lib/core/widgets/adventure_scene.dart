import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../illustrations/ornaments.dart';
import '../illustrations/painters.dart';
import '../theme/app_colors.dart';
import 'art_image.dart';
import 'guide_character.dart';

/// Pemandangan petualangan (statis, digambar sekali): matahari, awan, burung,
/// bukit, pohon kelapa, rumah adat, bunga, dan pita tumpal di bagian bawah.
/// Jika assets/illustrations/scene_bg.png ada (tanpa karakter), gambar itu dipakai.
class AdventureScene extends StatelessWidget {
  const AdventureScene({
    super.key,
    this.height = 220,
    this.showCharacters = true,
    this.borderRadius = 28,
  });
  final double height;
  final bool showCharacters;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final charW = height * 0.40;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius + 3),
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
        borderRadius: BorderRadius.circular(borderRadius),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(
                child: ArtImage(
                  asset: 'assets/illustrations/scene_bg.png',
                  fallback: RepaintBoundary(
                    child: CustomPaint(
                      painter: _ScenePainter(const AlwaysStoppedAnimation<double>(0.18)),
                    ),
                  ),
                ),
              ),
              if (showCharacters) ...[
                Positioned(left: 10, bottom: 12, child: GuideCharacter(isFemale: false, width: charW)),
                Positioned(right: 10, bottom: 12, child: GuideCharacter(isFemale: true, width: charW)),
              ],
              const Positioned(left: 0, right: 0, bottom: 0, child: TumpalBand(height: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter(this.anim) : super(repaint: anim);
  final Animation<double> anim;

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final t = anim.value;
    final tau = 2 * math.pi;
    Paint fill(Color c) => Paint()..color = c;

    // langit
    canvas.drawRect(
      Offset.zero & s,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFFC98A), Color(0xFFFFE3B5), Color(0xFFFFF4DC)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Offset.zero & s),
    );

    // matahari + sinar
    final sun = Offset(w * .78, h * .26);
    canvas.drawCircle(
      sun,
      h * .30,
      Paint()
        ..shader = RadialGradient(
          colors: [AppColors.goldLight.withValues(alpha: .75), AppColors.goldLight.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: sun, radius: h * .30)),
    );
    final ray = Paint()
      ..color = Colors.white.withValues(alpha: .35)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 12; i++) {
      final a = i * tau / 12 + t * tau / 12;
      canvas.drawLine(
        sun + Offset(math.cos(a), math.sin(a)) * (h * .14),
        sun + Offset(math.cos(a), math.sin(a)) * (h * .22),
        ray,
      );
    }
    canvas.drawCircle(sun, h * .10, fill(AppColors.goldLight));
    canvas.drawCircle(sun, h * .075, fill(const Color(0xFFFFE9A8)));

    // awan
    final cloud = fill(Colors.white.withValues(alpha: .88));
    for (var i = 0; i < 3; i++) {
      final x = (((t + i / 3) % 1) * (w * 1.4)) - w * .2;
      final y = h * (.12 + .09 * i);
      final sc = 1.0 - i * .12;
      canvas.drawOval(Rect.fromCenter(center: Offset(x, y), width: 78 * sc, height: 22 * sc), cloud);
      canvas.drawOval(Rect.fromCenter(center: Offset(x + 18 * sc, y - 9 * sc), width: 46 * sc, height: 22 * sc), cloud);
      canvas.drawOval(Rect.fromCenter(center: Offset(x - 20 * sc, y - 6 * sc), width: 38 * sc, height: 18 * sc), cloud);
    }

    // burung
    final bird = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = AppColors.brown.withValues(alpha: .7);
    for (var i = 0; i < 3; i++) {
      final x = (((t * 2 + i * .33) % 1) * (w + 60)) - 30;
      final y = h * (.30 + i * .06) + math.sin(t * tau * 10 + i) * 4;
      final flap = math.sin(t * tau * 80 + i) * 4;
      canvas.drawPath(
        Path()
          ..moveTo(x - 8, y - flap)
          ..quadraticBezierTo(x - 3, y - 3, x, y)
          ..quadraticBezierTo(x + 3, y - 3, x + 8, y - flap),
        bird,
      );
    }

    Path hill(double base, double amp, double phase, double freq) {
      final p = Path()..moveTo(0, h);
      for (double x = 0; x <= w; x += 5) {
        p.lineTo(x, base + math.sin(x / w * math.pi * freq + phase) * amp);
      }
      return p
        ..lineTo(w, h)
        ..close();
    }

    // gunung jauh
    final far = hill(h * .52, h * .07, 1.0, 2.2);
    canvas.drawPath(far, Paint()..shader = const LinearGradient(
      colors: [Color(0xFF9DC4B0), Color(0xFF7FAE95)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Offset.zero & s));
    canvas.drawPath(hill(h * .62, h * .05, 2.4, 3.0), fill(const Color(0xFF5E9A74)));

    // pohon kelapa
    void palm(double x, double baseY, double ph, double sc) {
      final sway = math.sin(t * tau * 8 + ph) * 5;
      final base = Offset(x, baseY);
      final ht = h * .42 * sc;
      final top = Offset(x + sway + ht * .12, baseY - ht);
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
        final a = -math.pi / 2 + (i - 2.5) * .55 + sway * .012;
        final len = ht * .45;
        final end = top + Offset(math.cos(a), math.sin(a)) * len + Offset(0, len * .35);
        final ctrl = top + Offset(math.cos(a), math.sin(a)) * len * .6 - Offset(0, len * .22);
        canvas.drawPath(
          Path()
            ..moveTo(top.dx, top.dy)
            ..quadraticBezierTo(ctrl.dx, ctrl.dy, end.dx, end.dy),
          frond,
        );
      }
      canvas.drawCircle(top.translate(0, ht * .03), ht * .03, fill(const Color(0xFF5A3420)));
    }

    palm(w * .27, h * .80, 0.0, 1.0);
    palm(w * .74, h * .80, 2.0, .85);

    // rumah adat
    final hw = math.min(w * .56, h * 1.32);
    final hh = hw / 1.25;
    paintNuwoSesat(canvas, Rect.fromLTWH(w / 2 - hw / 2, h * .96 - hh, hw, hh));

    // bukit depan + rumput
    final front = hill(h * .86, h * .025, 4.0, 3.5);
    canvas.drawPath(front, Paint()..shader = const LinearGradient(
      colors: [Color(0xFF2F7D4F), Color(0xFF174A2E)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Offset.zero & s));
    final flowerColors = [AppColors.terracotta, AppColors.goldLight, Colors.white];
    for (var i = 0; i < 14; i++) {
      final x = w * (.04 + i * .07) + math.sin(i * 3.1) * 6;
      final y = h * (.90 + .05 * ((i * 37) % 10) / 10);
      canvas.drawCircle(Offset(x, y), 2.2, fill(flowerColors[i % 3]));
    }

    // kelopak melayang
    for (var i = 0; i < 7; i++) {
      final f = (t * (1 + i % 2) + i * .14) % 1;
      final x = w * ((i * .17 + .05) % 1) + math.sin(f * tau * 2 + i) * 14;
      final y = h * f;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(f * tau * 2);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 6, height: 3.5),
          fill(AppColors.terracotta.withValues(alpha: .55)));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) => false;
}

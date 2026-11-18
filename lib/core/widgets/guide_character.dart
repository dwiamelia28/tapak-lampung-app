import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../illustrations/painters.dart';
import '../theme/app_colors.dart';
import 'art_image.dart';

/// Karakter pemandu 2D (statis: digambar sekali lalu di-cache, jadi ringan).
/// Jika assets/illustrations/guide_male.png atau guide_female.png tersedia,
/// gambar itu dipakai; jika tidak, dipakai gambar vektor bawaan.
class GuideCharacter extends StatelessWidget {
  const GuideCharacter({super.key, required this.isFemale, this.width = 110});
  final bool isFemale;
  final double width;

  @override
  Widget build(BuildContext context) {
    final vector = RepaintBoundary(
      child: CustomPaint(
        size: Size(width, width * 1.3),
        painter: _GuidePainter(const AlwaysStoppedAnimation<double>(0.07), isFemale),
      ),
    );
    return SizedBox(
      width: width,
      height: width * 1.3,
      child: ArtImage(
        asset: isFemale
            ? 'assets/illustrations/guide_female.png'
            : 'assets/illustrations/guide_male.png',
        fit: BoxFit.contain,
        fallback: vector,
      ),
    );
  }
}

class _GuidePainter extends CustomPainter {
  _GuidePainter(this.anim, this.isFemale) : super(repaint: anim);
  final Animation<double> anim;
  final bool isFemale;

  static const _ink = Color(0xFF3B2314);
  static const _hair = Color(0xFF1E130D);

  @override
  void paint(Canvas canvas, Size s) {
    final t = anim.value;
    final w = s.width, h = s.height, cx = w / 2;
    final bob = math.sin(t * 2 * math.pi) * h * 0.010;

    final ol = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.012
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = _ink;
    void shape(Path p, Paint f) {
      canvas.drawPath(p, f);
      canvas.drawPath(p, ol);
    }

    Paint vg(Rect r, Color a, Color b) => Paint()
      ..shader = LinearGradient(
        colors: [a, b],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(r);
    Paint fill(Color c) => Paint()..color = c;
    void thick(Offset a, Offset b, double width, Color c) {
      canvas.drawLine(
          a, b, Paint()..strokeWidth = width + w * .014 ..strokeCap = StrokeCap.round..color = _ink);
      canvas.drawLine(a, b, Paint()..strokeWidth = width..strokeCap = StrokeCap.round..color = c);
    }

    final cloth = isFemale ? const Color(0xFF9B2E3D) : const Color(0xFF2A1B14);
    final gold = fill(AppColors.gold);

    // bayangan
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * .975), width: w * .62, height: h * .045),
      fill(Colors.black.withValues(alpha: .16)),
    );

    // ---- bawahan
    if (isFemale) {
      final skirt = Path()
        ..moveTo(cx - w * .21, h * .57 + bob)
        ..lineTo(cx + w * .21, h * .57 + bob)
        ..lineTo(cx + w * .31, h * .965)
        ..lineTo(cx - w * .31, h * .965)
        ..close();
      shape(skirt, vg(skirt.getBounds(), const Color(0xFFA23344), AppColors.maroon));
      final hw = w * .21 + (h * .74 - h * .57) / (h * .395) * w * .10;
      canvas.drawRect(Rect.fromLTRB(cx - hw, h * .74, cx + hw, h * .758), gold);
      for (var i = 0; i < 8; i++) {
        final x0 = cx - w * .31 + w * .62 * i / 8;
        final x1 = cx - w * .31 + w * .62 * (i + 1) / 8;
        canvas.drawPath(
          Path()
            ..moveTo(x0, h * .965)
            ..lineTo((x0 + x1) / 2, h * .915)
            ..lineTo(x1, h * .965)
            ..close(),
          gold,
        );
      }
    } else {
      for (final dx in [-1.0, 1.0]) {
        final leg = RRect.fromRectAndRadius(
          Rect.fromLTRB(cx + dx * w * .02 - (dx < 0 ? w * .14 : 0),
              h * .76, cx + dx * w * .02 + (dx > 0 ? w * .14 : 0), h * .945),
          Radius.circular(w * .03),
        );
        canvas.drawRRect(leg, fill(const Color(0xFF1E1410)));
        canvas.drawRRect(leg, ol);
        canvas.drawOval(
          Rect.fromCenter(
              center: Offset(cx + dx * w * .09, h * .955), width: w * .17, height: h * .04),
          fill(_ink),
        );
      }
      final sarong = Path()
        ..moveTo(cx - w * .21, h * .56 + bob)
        ..lineTo(cx + w * .21, h * .56 + bob)
        ..lineTo(cx + w * .26, h * .80)
        ..lineTo(cx - w * .26, h * .80)
        ..close();
      shape(sarong, vg(sarong.getBounds(), const Color(0xFFC4502F), const Color(0xFF8E2A1A)));
      canvas.drawRect(Rect.fromLTRB(cx - w * .235, h * .64, cx + w * .235, h * .658), gold);
      for (var i = 0; i < 7; i++) {
        final x0 = cx - w * .26 + w * .52 * i / 7;
        final x1 = cx - w * .26 + w * .52 * (i + 1) / 7;
        canvas.drawPath(
          Path()
            ..moveTo(x0, h * .80)
            ..lineTo((x0 + x1) / 2, h * .758)
            ..lineTo(x1, h * .80)
            ..close(),
          gold,
        );
      }
    }

    // ---- badan
    final torso = Path()
      ..moveTo(cx - w * .23, h * .46 + bob)
      ..quadraticBezierTo(cx, h * .385 + bob, cx + w * .23, h * .46 + bob)
      ..lineTo(cx + w * .21, h * .60 + bob)
      ..lineTo(cx - w * .21, h * .60 + bob)
      ..close();
    shape(torso, vg(torso.getBounds(), cloth, isFemale ? AppColors.maroon : const Color(0xFF1A100B)));
    if (!isFemale) {
      for (final y in [.50, .54, .58]) {
        canvas.drawCircle(Offset(cx, h * y + bob), w * .012, gold);
      }
    }
    final sash = Path()
      ..moveTo(cx - w * .22, h * .46 + bob)
      ..lineTo(cx - w * .10, h * .435 + bob)
      ..lineTo(cx + w * .21, h * .70 + bob)
      ..lineTo(cx + w * .09, h * .72 + bob)
      ..close();
    shape(sash, vg(sash.getBounds(), AppColors.goldLight, AppColors.gold));

    // ---- lengan
    Offset o(double x, double y) => Offset(x, y + bob);
    final sleeve = cloth;
    thick(o(cx - w * .22, h * .47), o(cx - w * .30, h * .58), w * .095, sleeve);
    thick(o(cx - w * .30, h * .58), o(cx - w * .29, h * .69), w * .065, AppColors.skin);
    canvas.drawCircle(o(cx - w * .29, h * .70), w * .042, fill(AppColors.skin));
    canvas.drawCircle(o(cx - w * .29, h * .70), w * .042, ol);

    final elbow = o(cx + w * .31, h * .56);
    final ang = -math.pi / 2 + .45 + math.sin(t * 4 * math.pi) * .35;
    final hand = elbow + Offset(math.cos(ang), math.sin(ang)) * (h * .17);
    thick(o(cx + w * .22, h * .47), elbow, w * .095, sleeve);
    thick(elbow, hand, w * .065, AppColors.skin);
    canvas.drawCircle(hand, w * .045, fill(AppColors.skin));
    canvas.drawCircle(hand, w * .045, ol);

    // ---- kepala
    final hc = o(cx, h * .275);
    final r = w * .165;
    canvas.drawRect(
      Rect.fromLTRB(cx - w * .04, hc.dy + r * .7, cx + w * .04, h * .43 + bob),
      fill(const Color(0xFFD9A074)),
    );
    if (isFemale) {
      canvas.drawOval(
        Rect.fromCenter(center: hc.translate(0, r * .35), width: r * 2.5, height: r * 2.4),
        fill(_hair),
      );
    }
    for (final dx in [-1.0, 1.0]) {
      canvas.drawCircle(hc.translate(dx * r * .98, r * .12), r * .2, fill(AppColors.skin));
      canvas.drawCircle(hc.translate(dx * r * .98, r * .12), r * .2, ol);
    }
    final face = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-.3, -.3),
        colors: const [Color(0xFFF5D0A8), AppColors.skin],
      ).createShader(Rect.fromCircle(center: hc, radius: r));
    canvas.drawCircle(hc, r, face);
    canvas.drawCircle(hc, r, ol);

    final fringe = Path()
      ..moveTo(hc.dx - r * 1.0, hc.dy - r * .05)
      ..cubicTo(hc.dx - r * 1.0, hc.dy - r * 1.25, hc.dx + r * 1.0, hc.dy - r * 1.25,
          hc.dx + r * 1.0, hc.dy - r * .05)
      ..cubicTo(hc.dx + r * .6, hc.dy - r * .55, hc.dx - r * .2, hc.dy - r * .62,
          hc.dx - r * 1.0, hc.dy - r * .05)
      ..close();
    canvas.drawPath(fringe, fill(_hair));

    final blink = (t * 3) % 1 > .94;
    for (final dx in [-r * .38, r * .38]) {
      final c = hc.translate(dx, r * .14);
      if (blink) {
        canvas.drawLine(c.translate(-r * .12, 0), c.translate(r * .12, 0),
            Paint()..strokeWidth = r * .06 ..strokeCap = StrokeCap.round..color = _ink);
      } else {
        canvas.drawOval(Rect.fromCenter(center: c, width: r * .27, height: r * .32), fill(Colors.white));
        canvas.drawCircle(c, r * .115, fill(_ink));
        canvas.drawCircle(c.translate(-r * .035, -r * .04), r * .035, fill(Colors.white));
      }
      canvas.drawArc(
        Rect.fromCenter(center: c.translate(0, -r * .24), width: r * .34, height: r * .16),
        math.pi * 1.1, math.pi * .8, false,
        Paint()..style = PaintingStyle.stroke..strokeWidth = r * .06 ..strokeCap = StrokeCap.round..color = _ink,
      );
    }
    canvas.drawCircle(hc.translate(-r * .62, r * .42), r * .15, fill(const Color(0x55E5735A)));
    canvas.drawCircle(hc.translate(r * .62, r * .42), r * .15, fill(const Color(0x55E5735A)));
    canvas.drawArc(
      Rect.fromCenter(center: hc.translate(0, r * .42), width: r * .55, height: r * .32),
      .2, math.pi - .4, false,
      Paint()..style = PaintingStyle.stroke..strokeWidth = r * .07 ..strokeCap = StrokeCap.round..color = _ink,
    );

    // ---- hiasan kepala
    if (isFemale) {
      drawSiger(canvas, Offset(cx, hc.dy - r * 1.0), r * 1.05);
      canvas.drawArc(
        Rect.fromCenter(center: o(cx, h * .445), width: w * .34, height: h * .10),
        .25, math.pi - .5, false,
        Paint()..style = PaintingStyle.stroke..strokeWidth = w * .018 ..strokeCap = StrokeCap.round..color = AppColors.gold,
      );
      canvas.drawCircle(o(cx, h * .493), w * .02, fill(AppColors.gold));
      for (final dx in [-1.0, 1.0]) {
        canvas.drawCircle(hc.translate(dx * r * 1.0, r * .42), r * .09, fill(AppColors.gold));
      }
    } else {
      final cloth2 = Path()
        ..moveTo(hc.dx - r * 1.02, hc.dy - r * .35)
        ..cubicTo(hc.dx - r * 1.1, hc.dy - r * 1.4, hc.dx + r * 1.1, hc.dy - r * 1.4,
            hc.dx + r * 1.02, hc.dy - r * .35)
        ..quadraticBezierTo(hc.dx, hc.dy - r * .66, hc.dx - r * 1.02, hc.dy - r * .35)
        ..close();
      shape(cloth2, vg(cloth2.getBounds(), const Color(0xFFB03A4C), AppColors.maroon));
      canvas.drawPath(
        Path()
          ..moveTo(hc.dx - r * 1.0, hc.dy - r * .38)
          ..quadraticBezierTo(hc.dx, hc.dy - r * .68, hc.dx + r * 1.0, hc.dy - r * .38),
        Paint()..style = PaintingStyle.stroke..strokeWidth = r * .13 ..color = AppColors.gold,
      );
      canvas.drawPath(
        Path()
          ..moveTo(hc.dx + r * .55, hc.dy - r * 1.18)
          ..lineTo(hc.dx + r * 1.05, hc.dy - r * 1.55)
          ..lineTo(hc.dx + r * .95, hc.dy - r * .95)
          ..close(),
        gold,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GuidePainter old) => old.isFemale != isFemale;
}

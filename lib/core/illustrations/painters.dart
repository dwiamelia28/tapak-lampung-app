import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Kumpulan ilustrasi vektor budaya Lampung (stilisasi). Semua fungsi
/// menggambar pada [Rect] dengan rasio sekitar 1.25:1 sehingga skalanya fleksibel.

class _Box {
  _Box(this.r);
  final Rect r;
  double get u => r.width;
  Offset p(double x, double y) => Offset(r.left + x * r.width, r.top + y * r.height);
  Rect rc(double x1, double y1, double x2, double y2) =>
      Rect.fromPoints(p(x1, y1), p(x2, y2));
}

Paint _fill(Color c) => Paint()..color = c;

Paint _stroke(double w, Color c) => Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..color = c
  ..strokeJoin = StrokeJoin.round
  ..strokeCap = StrokeCap.round;

Paint _vgrad(Rect r, Color a, Color b) => Paint()
  ..shader = LinearGradient(
    colors: [a, b],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  ).createShader(r);

Path _poly(List<Offset> pts) {
  final path = Path()..moveTo(pts.first.dx, pts.first.dy);
  for (final o in pts.skip(1)) {
    path.lineTo(o.dx, o.dy);
  }
  return path..close();
}

/// Mahkota siger bergaya zig-zag emas. [c] = titik tengah, [s] = setengah lebar.
void drawSiger(Canvas canvas, Offset c, double s) {
  const n = 9;
  final path = Path()..moveTo(c.dx - s, c.dy + s * .35);
  final peaks = <Offset>[];
  for (var i = 0; i < n; i++) {
    final x = c.dx - s + (2 * s) * i / (n - 1);
    final y = c.dy - (i.isEven ? s * .8 : s * .25);
    path.lineTo(x, y);
    if (i.isEven) peaks.add(Offset(x, y));
  }
  path
    ..lineTo(c.dx + s, c.dy + s * .35)
    ..close();
  final bounds = path.getBounds();
  canvas.drawPath(path, _vgrad(bounds, AppColors.goldLight, AppColors.gold));
  canvas.drawPath(path, _stroke(s * .06, AppColors.brown));
  final band = RRect.fromRectAndRadius(
    Rect.fromLTRB(c.dx - s, c.dy + s * .18, c.dx + s, c.dy + s * .46),
    Radius.circular(s * .1),
  );
  canvas.drawRRect(band, _vgrad(band.outerRect, AppColors.gold, const Color(0xFFB98524)));
  canvas.drawRRect(band, _stroke(s * .05, AppColors.brown));
  for (final pk in peaks) {
    canvas.drawCircle(pk, s * .07, _fill(AppColors.maroon));
  }
}

// ---------------------------------------------------------------- Nuwo Sesat
// Koordinat hotspot (relatif): atap (.5,.24) balai (.5,.52) tiang (.28,.74) tangga (.82,.76)
void paintNuwoSesat(Canvas canvas, Rect rect) {
  final b = _Box(rect);
  final u = b.u;
  canvas.drawOval(b.rc(.06, .84, .94, .91), _fill(Colors.black.withValues(alpha: .16)));

  final post = _fill(const Color(0xFF5A3420));
  for (final x in const [.20, .36, .52, .68, .80]) {
    canvas.drawRect(b.rc(x - .013, .62, x + .013, .87), post);
  }
  final brace = _stroke(u * .006, const Color(0xFF7A4528));
  canvas.drawLine(b.p(.20, .86), b.p(.36, .66), brace);
  canvas.drawLine(b.p(.52, .86), b.p(.36, .66), brace);
  canvas.drawLine(b.p(.52, .86), b.p(.68, .66), brace);

  canvas.drawRRect(
    RRect.fromRectAndRadius(b.rc(.13, .595, .87, .632), Radius.circular(u * .01)),
    post,
  );

  final wall = RRect.fromRectAndRadius(b.rc(.18, .40, .82, .60), Radius.circular(u * .008));
  canvas.drawRRect(
      wall, _vgrad(wall.outerRect, const Color(0xFFCB8748), const Color(0xFFA9632F)));
  final plank = _stroke(u * .0025, const Color(0xFF8F552B));
  for (var i = 1; i < 16; i++) {
    final x = .18 + .64 * i / 16;
    canvas.drawLine(b.p(x, .40), b.p(x, .60), plank);
  }
  canvas.drawRRect(wall, _stroke(u * .004, AppColors.brown));

  for (final x in const [.235, .645]) {
    final w = b.rc(x, .45, x + .12, .55);
    canvas.drawRect(w, _fill(AppColors.goldLight));
    canvas.drawRect(w, _stroke(u * .006, const Color(0xFF5A3420)));
    canvas.drawLine(b.p(x + .06, .45), b.p(x + .06, .55), _stroke(u * .004, const Color(0xFF5A3420)));
  }
  final door = RRect.fromRectAndCorners(
    b.rc(.44, .45, .56, .60),
    topLeft: Radius.circular(u * .03),
    topRight: Radius.circular(u * .03),
  );
  canvas.drawRRect(door, _fill(const Color(0xFF4A2814)));
  canvas.drawCircle(b.p(.535, .53), u * .005, _fill(AppColors.gold));

  void tier(List<Offset> pts, Color a, Color c) {
    final path = _poly(pts);
    canvas.drawPath(path, _vgrad(path.getBounds(), a, c));
    canvas.drawPath(path, _stroke(u * .005, AppColors.brown));
  }

  tier([b.p(.07, .44), b.p(.25, .28), b.p(.75, .28), b.p(.93, .44)],
      const Color(0xFF9B2E3D), AppColors.maroon);
  final shingle = _stroke(u * .003, Colors.black.withValues(alpha: .18));
  for (var i = 1; i < 4; i++) {
    final y = .28 + .16 * i / 4;
    canvas.drawLine(b.p(.25 - .18 * i / 4, y), b.p(.75 + .18 * i / 4, y), shingle);
  }
  final gold = _fill(AppColors.gold);
  for (var i = 0; i < 16; i++) {
    final x0 = .09 + .82 * i / 16;
    final x1 = .09 + .82 * (i + 1) / 16;
    canvas.drawPath(_poly([b.p(x0, .44), b.p((x0 + x1) / 2, .475), b.p(x1, .44)]), gold);
  }
  tier([b.p(.22, .28), b.p(.37, .13), b.p(.63, .13), b.p(.78, .28)],
      const Color(0xFFDD7A47), AppColors.terracotta);
  for (var i = 1; i < 3; i++) {
    final y = .13 + .15 * i / 3;
    canvas.drawLine(b.p(.37 - .15 * i / 3, y), b.p(.63 + .15 * i / 3, y), shingle);
  }
  canvas.drawLine(b.p(.5, .13), b.p(.5, .06), _stroke(u * .007, AppColors.gold));
  canvas.drawCircle(b.p(.5, .05), u * .016, gold);
  canvas.drawCircle(b.p(.5, .05), u * .016, _stroke(u * .004, AppColors.brown));

  for (var i = 0; i < 6; i++) {
    final x = .74 + .032 * i;
    final y = .64 + .037 * i;
    canvas.drawRect(b.rc(x, y, x + .075, y + .014), post);
  }
  canvas.drawLine(b.p(.745, .60), b.p(.915, .81), _stroke(u * .006, const Color(0xFF7A4528)));
}

// -------------------------------------------------------------------- Tapis
// Hotspot: sulaman (.14,.5) motif (.39,.45) kain (.39,.78) siger (.84,.36)
void paintTapis(Canvas canvas, Rect rect) {
  final b = _Box(rect);
  final u = b.u;
  canvas.drawRRect(
    RRect.fromRectAndRadius(b.rc(.08, .06, .70, .10), Radius.circular(u * .012)),
    _fill(const Color(0xFF5A3420)),
  );
  canvas.drawCircle(b.p(.08, .08), u * .02, _fill(AppColors.gold));
  canvas.drawCircle(b.p(.70, .08), u * .02, _fill(AppColors.gold));

  final cloth = b.rc(.12, .10, .66, .90);
  canvas.drawRRect(
    RRect.fromRectAndRadius(cloth, Radius.circular(u * .01)),
    _vgrad(cloth, const Color(0xFF9B2E3D), const Color(0xFF5A1620)),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(b.rc(.14, .12, .64, .88), Radius.circular(u * .008)),
    _stroke(u * .008, AppColors.gold),
  );

  final zz = Path()..moveTo(b.p(.16, .18).dx, b.p(.16, .18).dy);
  for (var i = 1; i <= 14; i++) {
    final o = b.p(.16 + .46 * i / 14, i.isOdd ? .22 : .18);
    zz.lineTo(o.dx, o.dy);
  }
  canvas.drawPath(zz, _stroke(u * .006, AppColors.goldLight));

  // motif kapal (stilisasi)
  final hull = Path()
    ..moveTo(b.p(.22, .50).dx, b.p(.22, .50).dy)
    ..quadraticBezierTo(b.p(.39, .66).dx, b.p(.39, .66).dy, b.p(.56, .50).dx, b.p(.56, .50).dy)
    ..close();
  canvas.drawPath(hull, _vgrad(hull.getBounds(), AppColors.goldLight, AppColors.gold));
  canvas.drawLine(b.p(.39, .50), b.p(.39, .30), _stroke(u * .006, AppColors.goldLight));
  canvas.drawPath(_poly([b.p(.39, .31), b.p(.39, .47), b.p(.51, .47)]), _fill(AppColors.gold));
  canvas.drawPath(_poly([b.p(.385, .34), b.p(.385, .47), b.p(.28, .47)]), _fill(AppColors.goldLight));
  final wave = Path()..moveTo(b.p(.20, .62).dx, b.p(.20, .62).dy);
  for (var i = 1; i <= 12; i++) {
    final o = b.p(.20 + .38 * i / 12, i.isOdd ? .65 : .62);
    wave.lineTo(o.dx, o.dy);
  }
  canvas.drawPath(wave, _stroke(u * .005, AppColors.gold));

  for (final y in const [.36, .72]) {
    for (var i = 0; i < 6; i++) {
      final cx = .20 + .38 * i / 5;
      canvas.drawPath(
        _poly([b.p(cx, y - .025), b.p(cx + .018, y), b.p(cx, y + .025), b.p(cx - .018, y)]),
        _fill(AppColors.gold),
      );
    }
  }
  for (var i = 0; i < 8; i++) {
    final x0 = .16 + .46 * i / 8;
    final x1 = .16 + .46 * (i + 1) / 8;
    canvas.drawPath(_poly([b.p(x0, .86), b.p((x0 + x1) / 2, .78), b.p(x1, .86)]), _fill(AppColors.gold));
  }
  for (var i = 0; i < 14; i++) {
    final x = .13 + .52 * i / 13;
    canvas.drawLine(b.p(x, .90), b.p(x, .95), _stroke(u * .004, AppColors.gold));
  }

  drawSiger(canvas, b.p(.84, .36), u * .11);
  canvas.drawOval(b.rc(.72, .47, .96, .50), _fill(Colors.black.withValues(alpha: .12)));
}

// -------------------------------------------------------------------- Seni
// Hotspot: penari (.27,.55) gamolan (.72,.50) siger penari (.27,.15)
void paintSeni(Canvas canvas, Rect rect) {
  final b = _Box(rect);
  final u = b.u;
  canvas.drawOval(b.rc(.04, .84, .96, .92), _fill(Colors.black.withValues(alpha: .15)));

  // penari
  final skirt = _poly([b.p(.19, .43), b.p(.35, .43), b.p(.44, .86), b.p(.10, .86)]);
  canvas.drawPath(skirt, _vgrad(skirt.getBounds(), const Color(0xFFA23344), AppColors.maroon));
  canvas.drawPath(skirt, _stroke(u * .004, AppColors.brown));
  for (var i = 0; i < 6; i++) {
    final x0 = .10 + .34 * i / 6;
    final x1 = .10 + .34 * (i + 1) / 6;
    canvas.drawPath(_poly([b.p(x0, .86), b.p((x0 + x1) / 2, .80), b.p(x1, .86)]), _fill(AppColors.gold));
  }
  final top = _poly([b.p(.20, .31), b.p(.34, .31), b.p(.355, .44), b.p(.185, .44)]);
  canvas.drawPath(top, _fill(const Color(0xFFC2415A)));
  canvas.drawPath(top, _stroke(u * .004, AppColors.brown));
  canvas.drawPath(
    _poly([b.p(.20, .31), b.p(.235, .31), b.p(.355, .43), b.p(.32, .44)]),
    _fill(AppColors.gold),
  );
  final armP = _stroke(u * .026, AppColors.skin);
  final armO = _stroke(u * .032, AppColors.brown);
  void arm(Offset a, Offset m, Offset e) {
    final pth = Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(m.dx, m.dy)
      ..lineTo(e.dx, e.dy);
    canvas.drawPath(pth, armO);
    canvas.drawPath(pth, armP);
  }

  arm(b.p(.20, .33), b.p(.10, .43), b.p(.07, .34));
  arm(b.p(.34, .33), b.p(.45, .41), b.p(.48, .31));
  // selendang
  final scarf = Path()
    ..moveTo(b.p(.07, .34).dx, b.p(.07, .34).dy)
    ..quadraticBezierTo(b.p(.28, .50).dx, b.p(.28, .50).dy, b.p(.48, .31).dx, b.p(.48, .31).dy);
  canvas.drawPath(scarf, _stroke(u * .012, AppColors.gold));

  canvas.drawCircle(b.p(.27, .215), u * .058, _fill(const Color(0xFF1E130D)));
  canvas.drawCircle(b.p(.27, .225), u * .05, _fill(AppColors.skin));
  canvas.drawCircle(b.p(.255, .225), u * .005, _fill(AppColors.brown));
  canvas.drawCircle(b.p(.285, .225), u * .005, _fill(AppColors.brown));
  canvas.drawArc(Rect.fromCenter(center: b.p(.27, .24), width: u * .03, height: u * .02), .2,
      math.pi - .4, false, _stroke(u * .003, AppColors.brown));
  drawSiger(canvas, b.p(.27, .15), u * .06);

  // gamolan (alat musik bilah bambu)
  final rail = _fill(const Color(0xFF6B4226));
  canvas.drawRRect(RRect.fromRectAndRadius(b.rc(.52, .60, .94, .635), Radius.circular(u * .008)), rail);
  canvas.drawRRect(RRect.fromRectAndRadius(b.rc(.52, .70, .94, .735), Radius.circular(u * .008)), rail);
  for (final x in const [.54, .92]) {
    canvas.drawRect(b.rc(x - .012, .60, x + .012, .86), rail);
  }
  for (var i = 0; i < 8; i++) {
    final x = .545 + i * .048;
    final r = b.rc(x, .26 + i * .026, x + .036, .66);
    final rr = RRect.fromRectAndRadius(r, Radius.circular(u * .008));
    canvas.drawRRect(rr, _vgrad(r, const Color(0xFFE5C672), const Color(0xFFB88B2E)));
    canvas.drawRRect(rr, _stroke(u * .003, AppColors.brown));
    final ny = r.top + r.height * .45;
    canvas.drawLine(Offset(r.left, ny), Offset(r.right, ny), _stroke(u * .003, const Color(0xFF8A6420)));
  }
  canvas.drawLine(b.p(.62, .20), b.p(.66, .33), _stroke(u * .008, const Color(0xFF6B4226)));
  canvas.drawCircle(b.p(.665, .335), u * .014, _fill(AppColors.terracotta));
}

// ----------------------------------------------------------------- Kuliner
// Hotspot: seruit (.54,.62) kopi (.80,.55) engkak (.66,.85) nasi&ikan (.28,.66)
void paintKuliner(Canvas canvas, Rect rect) {
  final b = _Box(rect);
  final u = b.u;
  // lampion gantung
  for (final x in const [.18, .50, .82]) {
    canvas.drawLine(b.p(x, 0), b.p(x, .10), _stroke(u * .003, AppColors.brown));
    final l = b.rc(x - .045, .10, x + .045, .20);
    canvas.drawOval(l, _vgrad(l, AppColors.goldLight, AppColors.terracotta));
    canvas.drawOval(l, _stroke(u * .004, AppColors.brown));
  }
  // meja bertaplak
  final table = b.rc(0, .50, 1, 1);
  canvas.drawRect(table, _vgrad(table, const Color(0xFF9B2E3D), AppColors.maroon));
  canvas.drawLine(b.p(0, .50), b.p(1, .50), _stroke(u * .012, AppColors.gold));
  for (var i = 0; i < 12; i++) {
    final x = .04 + i * .09;
    canvas.drawPath(_poly([b.p(x, .535), b.p(x + .03, .56), b.p(x - .03, .56)]), _fill(AppColors.gold));
  }

  // piring nasi & ikan
  canvas.drawOval(b.rc(.12, .66, .44, .78), _fill(Colors.black.withValues(alpha: .18)));
  final plate = b.rc(.12, .62, .44, .75);
  canvas.drawOval(plate, _fill(Colors.white));
  canvas.drawOval(b.rc(.15, .64, .41, .73), _stroke(u * .004, AppColors.sand));
  canvas.drawOval(b.rc(.17, .60, .29, .70), _fill(const Color(0xFFFFFBF2)));
  canvas.drawOval(b.rc(.17, .60, .29, .70), _stroke(u * .003, AppColors.sand));
  final fish = b.rc(.28, .64, .40, .71);
  canvas.drawOval(fish, _vgrad(fish, const Color(0xFFE1A04B), const Color(0xFFA9632F)));
  canvas.drawPath(_poly([b.p(.395, .675), b.p(.43, .64), b.p(.43, .71)]), _fill(const Color(0xFFA9632F)));
  canvas.drawCircle(b.p(.30, .672), u * .006, _fill(AppColors.brown));

  // mangkuk seruit
  final bowl = Path()
    ..moveTo(b.p(.44, .60).dx, b.p(.44, .60).dy)
    ..quadraticBezierTo(b.p(.54, .78).dx, b.p(.54, .78).dy, b.p(.64, .60).dx, b.p(.64, .60).dy)
    ..close();
  canvas.drawPath(bowl, _vgrad(bowl.getBounds(), const Color(0xFFD9744A), const Color(0xFF9A3F1E)));
  canvas.drawPath(bowl, _stroke(u * .004, AppColors.brown));
  final sambal = b.rc(.44, .575, .64, .625);
  canvas.drawOval(sambal, _fill(const Color(0xFFC8361F)));
  canvas.drawOval(sambal, _stroke(u * .004, AppColors.brown));
  for (final o in const [Offset(.48, .60), Offset(.54, .59), Offset(.59, .605)]) {
    canvas.drawCircle(b.p(o.dx, o.dy), u * .007, _fill(const Color(0xFF6FA57F)));
  }

  // cangkir kopi + uap
  final cup = Path()
    ..moveTo(b.p(.72, .46).dx, b.p(.72, .46).dy)
    ..lineTo(b.p(.88, .46).dx, b.p(.88, .46).dy)
    ..lineTo(b.p(.86, .62).dx, b.p(.86, .62).dy)
    ..quadraticBezierTo(b.p(.80, .66).dx, b.p(.80, .66).dy, b.p(.74, .62).dx, b.p(.74, .62).dy)
    ..close();
  canvas.drawPath(cup, _fill(Colors.white));
  canvas.drawPath(cup, _stroke(u * .005, AppColors.brown));
  canvas.drawArc(b.rc(.855, .50, .94, .59), -math.pi / 2, math.pi, false, _stroke(u * .012, Colors.white));
  canvas.drawArc(b.rc(.855, .50, .94, .59), -math.pi / 2, math.pi, false, _stroke(u * .004, AppColors.brown));
  canvas.drawOval(b.rc(.72, .445, .88, .475), _fill(const Color(0xFF3B2314)));
  for (var i = 0; i < 3; i++) {
    final x = .76 + i * .04;
    final s = Path()
      ..moveTo(b.p(x, .42).dx, b.p(x, .42).dy)
      ..quadraticBezierTo(b.p(x + .02, .37).dx, b.p(x + .02, .37).dy, b.p(x, .33).dx, b.p(x, .33).dy);
    canvas.drawPath(s, _stroke(u * .005, Colors.white.withValues(alpha: .75)));
  }

  // piring engkak
  final ep = b.rc(.54, .80, .80, .90);
  canvas.drawOval(ep, _fill(Colors.white));
  canvas.drawOval(ep, _stroke(u * .004, AppColors.sand));
  for (var i = 0; i < 4; i++) {
    final cx = .595 + i * .045;
    final cy = i.isEven ? .845 : .86;
    canvas.drawPath(
      _poly([b.p(cx, cy - .035), b.p(cx + .03, cy), b.p(cx, cy + .035), b.p(cx - .03, cy)]),
      _fill(const Color(0xFFB77A33)),
    );
    canvas.drawCircle(b.p(cx - .006, cy - .006), u * .003, _fill(AppColors.cream));
    canvas.drawCircle(b.p(cx + .008, cy + .006), u * .003, _fill(AppColors.cream));
  }
}

void paintTheme(Canvas canvas, String theme, Rect r) {
  switch (theme) {
    case 'kain':
      paintTapis(canvas, r);
    case 'seni':
      paintSeni(canvas, r);
    case 'kuliner':
      paintKuliner(canvas, r);
    default:
      paintNuwoSesat(canvas, r);
  }
}

/// Pulau melayang untuk peta petualangan.
void paintIsland(Canvas canvas, Size s, String theme) {
  final w = s.width, h = s.height;
  canvas.drawOval(Rect.fromLTWH(w * .02, h * .60, w * .96, h * .34),
      _fill(Colors.white.withValues(alpha: .35)));
  final sand = Rect.fromLTWH(w * .07, h * .56, w * .86, h * .34);
  canvas.drawOval(sand, _vgrad(sand, const Color(0xFFF0D9A3), const Color(0xFFD2B06A)));
  final grass = Rect.fromLTWH(w * .10, h * .52, w * .80, h * .32);
  canvas.drawOval(grass, _vgrad(grass, const Color(0xFF7CC08E), AppColors.forest));
  canvas.drawOval(grass, _stroke(w * .006, const Color(0xFF174A2E)));
  final ow = w * .86;
  final oh = ow / 1.25;
  paintTheme(canvas, theme, Rect.fromLTWH(w * .07, h * .70 - oh * .87, ow, oh));
}

/// Piala emas untuk layar hasil kuis.
void paintTrophy(Canvas canvas, Size s) {
  final w = s.width, h = s.height;
  Offset p(double x, double y) => Offset(w * x, h * y);
  final handle = _stroke(w * .05, AppColors.gold);
  canvas.drawArc(Rect.fromLTRB(w * .04, h * .14, w * .34, h * .46), math.pi / 2, math.pi, false, handle);
  canvas.drawArc(Rect.fromLTRB(w * .66, h * .14, w * .96, h * .46), -math.pi / 2, math.pi, false, handle);
  final cup = Path()
    ..moveTo(p(.22, .08).dx, p(.22, .08).dy)
    ..lineTo(p(.78, .08).dx, p(.78, .08).dy)
    ..quadraticBezierTo(p(.78, .55).dx, p(.78, .55).dy, p(.5, .62).dx, p(.5, .62).dy)
    ..quadraticBezierTo(p(.22, .55).dx, p(.22, .55).dy, p(.22, .08).dx, p(.22, .08).dy)
    ..close();
  canvas.drawPath(cup, _vgrad(cup.getBounds(), AppColors.goldLight, const Color(0xFFC08A1E)));
  canvas.drawPath(cup, _stroke(w * .012, AppColors.brown));
  canvas.drawRect(Rect.fromLTRB(w * .45, h * .60, w * .55, h * .78), _fill(AppColors.gold));
  final base = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * .28, h * .78, w * .72, h * .92), Radius.circular(w * .03));
  canvas.drawRRect(base, _vgrad(base.outerRect, AppColors.maroon, const Color(0xFF4A1019)));
  canvas.drawRRect(base, _stroke(w * .012, AppColors.brown));
  canvas.drawRect(Rect.fromLTRB(w * .36, h * .83, w * .64, h * .87), _fill(AppColors.gold));
  // bintang
  final star = Path();
  for (var i = 0; i < 10; i++) {
    final r = i.isEven ? w * .12 : w * .05;
    final a = -math.pi / 2 + i * math.pi / 5;
    final o = Offset(w * .5 + math.cos(a) * r, h * .30 + math.sin(a) * r);
    i == 0 ? star.moveTo(o.dx, o.dy) : star.lineTo(o.dx, o.dy);
  }
  star.close();
  canvas.drawPath(star, _fill(Colors.white));
  canvas.drawPath(star, _stroke(w * .008, AppColors.brown));
}

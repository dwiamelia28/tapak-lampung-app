import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Ikon bergaya Lampung (digambar dengan kode): siger, rumah adat (Nuwo Sesat),
/// tapis, gamolan, kapal, dan kopi. Kunci: siger | rumah | tapis | gamolan | kapal | kopi.
class LampungIcon extends StatelessWidget {
  const LampungIcon(this.kind, {super.key, this.size = 28, this.color = AppColors.brown, this.accent = AppColors.gold});
  final String kind;
  final double size;
  final Color color;
  final Color accent;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _IconPainter(kind, color, accent)),
      );
}

class _IconPainter extends CustomPainter {
  _IconPainter(this.kind, this.color, this.accent);
  final String kind;
  final Color color;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    Offset p(double x, double y) => Offset(x * k, y * k);
    Path poly(List<List<double>> pts) {
      final path = Path()..moveTo(pts.first[0] * k, pts.first[1] * k);
      for (final o in pts.skip(1)) {
        path.lineTo(o[0] * k, o[1] * k);
      }
      return path..close();
    }

    final main = Paint()..color = color;
    final acc = Paint()..color = accent;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6 * k
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;

    switch (kind) {
      case 'siger':
        canvas.drawPath(
            poly([[3, 17], [3, 7], [6.5, 12.5], [9, 5], [12, 12], [15, 5], [17.5, 12.5], [21, 7], [21, 17]]),
            main);
        canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTRB(3 * k, 17 * k, 21 * k, 20.5 * k), Radius.circular(1.2 * k)),
            acc);
        for (final x in [3.0, 9.0, 15.0, 21.0]) {
          canvas.drawCircle(p(x, x == 9 || x == 15 ? 5 : 7), 1.3 * k, acc);
        }
      case 'rumah':
        canvas.drawPath(poly([[1.5, 11], [6.5, 6.5], [17.5, 6.5], [22.5, 11]]), main);
        canvas.drawPath(poly([[8, 6.5], [10, 2.5], [14, 2.5], [16, 6.5]]), acc);
        canvas.drawRect(Rect.fromLTRB(4.5 * k, 11 * k, 19.5 * k, 16 * k), main);
        canvas.drawRect(Rect.fromLTRB(10.5 * k, 12.5 * k, 13.5 * k, 16 * k), Paint()..color = Colors.white.withValues(alpha: .85));
        for (final x in [5.5, 9.5, 14.5, 18.5]) {
          canvas.drawRect(Rect.fromLTRB((x - .6) * k, 16 * k, (x + .6) * k, 21.5 * k), main);
        }
      case 'tapis':
        canvas.drawRect(Rect.fromLTRB(5 * k, 2.5 * k, 19 * k, 19 * k), main);
        for (var i = 0; i < 4; i++) {
          final x0 = 5 + i * 3.5;
          canvas.drawPath(poly([[x0, 19], [x0 + 1.75, 22], [x0 + 3.5, 19]]), acc);
        }
        canvas.drawPath(poly([[12, 6], [15, 10], [12, 14], [9, 10]]), acc);
        canvas.drawLine(p(7, 4.8), p(17, 4.8), Paint()..color = accent..strokeWidth = 1 * k);
      case 'gamolan':
        final hs = [15.0, 13.0, 11.0, 9.0, 7.0];
        for (var i = 0; i < 5; i++) {
          final x = 3 + i * 3.7;
          canvas.drawRRect(
              RRect.fromRectAndRadius(Rect.fromLTRB(x * k, (21 - hs[i]) * k, (x + 2.6) * k, 18 * k), Radius.circular(.8 * k)),
              i.isEven ? main : acc);
        }
        canvas.drawLine(p(2, 19.5), p(22, 19.5), stroke);
      case 'kapal':
        canvas.drawPath(
            Path()
              ..moveTo(3 * k, 15 * k)
              ..quadraticBezierTo(12 * k, 22.5 * k, 21 * k, 15 * k)
              ..close(),
            main);
        canvas.drawLine(p(12, 15), p(12, 3), stroke);
        canvas.drawPath(poly([[12.8, 3.5], [12.8, 13.5], [19.5, 13.5]]), acc);
        canvas.drawPath(poly([[11.2, 6], [11.2, 13.5], [6, 13.5]]), main);
      case 'kopi':
        canvas.drawPath(poly([[4.5, 10], [17.5, 10], [15.5, 19], [6.5, 19]]), main);
        canvas.drawArc(Rect.fromLTRB(15 * k, 11 * k, 21.5 * k, 17 * k), -1.57, 3.14, false, stroke);
        canvas.drawOval(Rect.fromLTRB(4.5 * k, 9 * k, 17.5 * k, 11.5 * k), acc);
        for (final x in [8.0, 11.0, 14.0]) {
          canvas.drawPath(
              Path()
                ..moveTo(x * k, 7 * k)
                ..quadraticBezierTo((x + 1.2) * k, 5 * k, x * k, 3 * k),
              stroke..strokeWidth = 1.1 * k);
        }
      default:
        canvas.drawCircle(p(12, 12), 8 * k, main);
    }
  }

  @override
  bool shouldRepaint(covariant _IconPainter old) =>
      old.kind != kind || old.color != color || old.accent != accent;
}

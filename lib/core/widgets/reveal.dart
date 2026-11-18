import 'package:flutter/material.dart';

/// Muncul dengan fade + geser halus. [index] membuat elemen berurutan terasa bertahap.
class Reveal extends StatelessWidget {
  const Reveal({super.key, required this.child, this.index = 0});
  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 450 + index * 160),
        curve: Curves.easeOutCubic,
        builder: (_, v, c) => Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: Transform.translate(offset: Offset(0, 22 * (1 - v)), child: c),
        ),
        child: child,
      );
}

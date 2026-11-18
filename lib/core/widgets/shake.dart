import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Mengguncang [child] setiap kali [trigger] berubah menjadi nilai > 0.
class Shake extends StatefulWidget {
  const Shake({super.key, required this.trigger, required this.child});
  final int trigger;
  final Widget child;
  @override
  State<Shake> createState() => _ShakeState();
}

class _ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 420));

  @override
  void didUpdateWidget(Shake old) {
    super.didUpdateWidget(old);
    if (widget.trigger != 0 && old.trigger != widget.trigger) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        child: widget.child,
        builder: (_, c) {
          final v = _c.value;
          return Transform.translate(
            offset: Offset(math.sin(v * math.pi * 6) * 8 * (1 - v), 0),
            child: c,
          );
        },
      );
}

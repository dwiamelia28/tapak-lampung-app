import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 44});
  final double size;

  Widget _word(String text) {
    final style = TextStyle(
      fontFamily: 'Lora',
      fontSize: size,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.5,
      height: 1,
      fontVariations: const [FontVariation('wght', 900)],
    );
    return Stack(
      children: [
        Text(
          text,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = size * 0.16
              ..color = AppColors.maroon,
          ),
        ),
        ShaderMask(
          shaderCallback: (r) => const LinearGradient(
            colors: [AppColors.goldLight, AppColors.gold],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(r),
          child: Text(text, style: style.copyWith(color: Colors.white)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [_word('TAPAK'), SizedBox(height: size * 0.08), _word('LAMPUNG')],
      );
}

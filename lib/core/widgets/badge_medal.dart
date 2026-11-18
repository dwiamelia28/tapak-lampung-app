import 'package:flutter/material.dart';
import '../constants/achievements.dart';
import '../theme/app_colors.dart';

/// Medali lencana: emas jika sudah diperoleh, abu-abu + gembok jika belum.
class BadgeMedal extends StatelessWidget {
  const BadgeMedal({super.key, required this.def, required this.unlocked, this.size = 64});
  final AchievementDef def;
  final bool unlocked;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ribbon = unlocked ? AppColors.maroon : Colors.grey.shade400;
    return SizedBox(
      width: size,
      height: size * 1.3,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: size * .62,
            left: size * .2,
            child: Transform.rotate(
              angle: .25,
              child: Container(width: size * .22, height: size * .5, color: ribbon),
            ),
          ),
          Positioned(
            top: size * .62,
            right: size * .2,
            child: Transform.rotate(
              angle: -.25,
              child: Container(width: size * .22, height: size * .5, color: ribbon),
            ),
          ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: unlocked
                  ? const RadialGradient(
                      center: Alignment(-.3, -.3),
                      colors: [AppColors.goldLight, AppColors.gold, Color(0xFFB98524)],
                    )
                  : LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade400]),
              border: Border.all(
                  color: unlocked ? AppColors.brown : Colors.grey.shade500, width: 2),
              boxShadow: unlocked
                  ? [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: .5),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Icon(
              unlocked ? def.icon : Icons.lock_outline,
              size: size * .5,
              color: unlocked ? AppColors.maroon : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

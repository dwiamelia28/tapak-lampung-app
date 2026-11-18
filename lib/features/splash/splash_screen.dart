import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/illustrations/ornaments.dart';
import '../../core/illustrations/painters.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/adventure_scene.dart';
import '../../core/widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    final loggedIn = FirebaseAuth.instance.currentUser != null;
    context.go(loggedIn ? '/gate' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 600),
          builder: (_, v, child) => Opacity(opacity: v, child: child),
          child: Column(
            children: [
              const TumpalBand(height: 18),
              const Spacer(flex: 2),
              const SizedBox(width: 120, height: 70, child: CustomPaint(painter: _SigerPainter())),
              const SizedBox(height: 6),
              const AppLogo(size: 46),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.maroon,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.gold, width: 1.5),
                ),
                child: const Text(
                  AppConstants.tagline,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: AdventureScene(height: 230, showCharacters: false),
              ),
              const SizedBox(height: 22),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.terracotta),
              ),
              const SizedBox(height: 22),
              const TumpalBand(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _SigerPainter extends CustomPainter {
  const _SigerPainter();
  @override
  void paint(Canvas canvas, Size s) => drawSiger(canvas, Offset(s.width / 2, s.height * .55), s.width * .42);
  @override
  bool shouldRepaint(covariant _SigerPainter old) => false;
}

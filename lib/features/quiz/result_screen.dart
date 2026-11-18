import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../../services/audio_service.dart';
import 'package:go_router/go_router.dart';
import '../../core/illustrations/painters.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/art_image.dart';
import '../../core/widgets/badge_medal.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/state_views.dart';
import '../../services/progress_service.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.chapterId, required this.outcome});
  final String chapterId;
  final QuizOutcome? outcome;
  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _confetti = ConfettiController(duration: const Duration(seconds: 3));

  @override
  void initState() {
    super.initState();
    final o = widget.outcome;
    if (o != null) AudioService.instance.sfx(o.passed ? 'sfx_win' : 'sfx_wrong');
    if (o != null && (o.passed || o.newBadges.isNotEmpty)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _confetti.play());
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  void _backToMap() {
    context.go('/home');
    context.push('/map');
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.outcome;
    if (o == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hasil Kuis')),
        body: EmptyView(
          title: 'Hasil tidak tersedia',
          note: 'Halaman hasil hanya muncul setelah kamu menyelesaikan kuis.',
          action: SizedBox(
            width: 200,
            child: PrimaryButton(label: 'Ke Peta', onPressed: _backToMap),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              children: [
                Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.elasticOut,
                    builder: (_, v, child) => Transform.scale(scale: v, child: child),
                    child: SizedBox(
                      width: 170,
                      height: 170,
                      child: ArtImage(
                        asset: 'assets/illustrations/trophy.png',
                        fit: BoxFit.contain,
                        fallback: CustomPaint(painter: _TrophyPainter(o.passed)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(o.passed ? 'Hebat!' : 'Ayo coba lagi!',
                      style: AppTheme.heading(32)),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    o.passed
                        ? 'Kamu berhasil menyelesaikan kuis "${o.chapterTitle}".'
                        : 'Nilaimu belum mencapai batas lulus. Pelajari materinya lagi lalu coba kembali.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.brownSoft, height: 1.4),
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: o.score),
                    duration: const Duration(milliseconds: 1400),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => Column(
                      children: [
                        Text('Skor Akhir', style: AppTheme.heading(14, color: AppColors.brownSoft)),
                        Text('$v',
                            style: AppTheme.heading(72, color: AppColors.terracotta)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _Stat(label: 'Jawaban benar', value: '${o.correct}/${o.total}'),
                    const SizedBox(width: 12),
                    _Stat(label: 'XP diperoleh', value: '+${o.xpGained}'),
                  ],
                ),
                if (o.levelAfter > o.levelBefore) ...[
                  const SizedBox(height: 12),
                  _Banner(
                    icon: Icons.trending_up,
                    color: AppColors.forest,
                    text: 'Naik ke Level ${o.levelAfter}!',
                  ),
                ],
                if (o.newBadges.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  Text('Lencana Baru', style: AppTheme.heading(20)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 18,
                    runSpacing: 12,
                    children: [
                      for (var i = 0; i < o.newBadges.length; i++)
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: Duration(milliseconds: 700 + i * 300),
                          curve: Curves.elasticOut,
                          builder: (_, v, child) => Transform.scale(scale: v, child: child),
                          child: SizedBox(
                            width: 96,
                            child: Column(
                              children: [
                                BadgeMedal(def: o.newBadges[i], unlocked: true, size: 62),
                                const SizedBox(height: 6),
                                Text(o.newBadges[i].title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
                if (o.unlockedNext != null) ...[
                  const SizedBox(height: 18),
                  _Banner(
                    icon: Icons.lock_open,
                    color: AppColors.terracotta,
                    text: 'Bab baru terbuka: ${o.unlockedNext!.title}',
                  ),
                ],
                const SizedBox(height: 26),
                if (o.unlockedNext != null)
                  PrimaryButton(
                    label: 'Lanjut ke Bab ${o.unlockedNext!.order}',
                    icon: Icons.arrow_forward,
                    onPressed: () {
                      context.go('/home');
                      context.push('/chapter/${o.unlockedNext!.id}');
                    },
                  ),
                if (o.unlockedNext != null) const SizedBox(height: 12),
                PrimaryButton(
                  label: o.passed ? 'Kembali ke Peta' : 'Ulangi Kuis',
                  icon: o.passed ? Icons.map_rounded : Icons.refresh,
                  color: AppColors.forest,
                  onPressed: o.passed
                      ? _backToMap
                      : () => context.pushReplacement('/chapter/${widget.chapterId}/quiz'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Ke Beranda'),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 28,
              gravity: .25,
              emissionFrequency: .05,
              colors: const [
                AppColors.gold,
                AppColors.terracotta,
                AppColors.forest,
                AppColors.maroon,
                AppColors.goldLight,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.sand, width: 1.5),
          ),
          child: Column(
            children: [
              Text(value, style: AppTheme.heading(24, color: AppColors.forest)),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(color: AppColors.brownSoft, fontSize: 12)),
            ],
          ),
        ),
      );
}

class _Banner extends StatelessWidget {
  const _Banner({required this.icon, required this.color, required this.text});
  final IconData icon;
  final Color color;
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text,
                  style: TextStyle(fontWeight: FontWeight.w800, color: color)),
            ),
          ],
        ),
      );
}

class _TrophyPainter extends CustomPainter {
  _TrophyPainter(this.passed);
  final bool passed;
  @override
  void paint(Canvas canvas, Size size) {
    if (!passed) {
      canvas.saveLayer(Offset.zero & size,
          Paint()..colorFilter = const ColorFilter.mode(Color(0xFFBBBBBB), BlendMode.modulate));
      paintTrophy(canvas, size);
      canvas.restore();
    } else {
      paintTrophy(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant _TrophyPainter old) => old.passed != passed;
}

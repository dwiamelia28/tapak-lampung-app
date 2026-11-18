import 'package:flutter/material.dart';
import '../../services/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/illustrations/ornaments.dart';
import '../../core/illustrations/painters.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/art_image.dart';
import '../../core/widgets/shake.dart';
import '../../core/widgets/state_views.dart';
import '../../models/chapter_model.dart';
import '../../models/progress_model.dart';
import '../../providers/content_providers.dart';
import '../../providers/providers.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});
  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  @override
  Widget build(BuildContext context) {
    final chapters = ref.watch(chaptersProvider);
    final progress = ref.watch(progressProvider).valueOrNull ?? const ProgressModel();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Peta Petualangan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: chapters.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(onRetry: () => ref.invalidate(chaptersProvider)),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyView(
              title: 'Peta masih kosong',
              note: 'Belum ada bab yang tersedia. Jalankan skrip data awal atau hubungi admin.',
            );
          }
          return LayoutBuilder(builder: (context, cons) {
            final w = cons.maxWidth;
            final isl = w * .46;
            final step = isl * 1.22;
            final top = MediaQuery.of(context).padding.top + kToolbarHeight + 16;
            final centers = <Offset>[
              for (var i = 0; i < list.length; i++)
                Offset(i.isEven ? w * .30 : w * .70, top + isl * .5 + i * step),
            ];
            final height = top + (list.length - 1) * step + isl * 1.35 + 30;
            return SingleChildScrollView(
              child: SizedBox(
                width: w,
                height: height,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ArtImage(
                        asset: 'assets/illustrations/map_bg.png',
                        fallback: RepaintBoundary(
                          child: CustomPaint(painter: _MapPainter(centers, progress, list)),
                        ),
                      ),
                    ),
                    for (var i = 0; i < list.length; i++)
                      Positioned(
                        left: centers[i].dx - isl / 2,
                        top: centers[i].dy - isl / 2,
                        width: isl,
                        child: _IslandNode(
                          chapter: list[i],
                          index: i,
                          size: isl,
                          locked: i != 0 && !progress.unlockedChapterIds.contains(list[i].id),
                          completed: progress.completedChapterIds.contains(list[i].id),
                          previousTitle: i > 0 ? list[i - 1].title : null,
                        ),
                      ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }
}

class _IslandNode extends StatefulWidget {
  const _IslandNode({
    required this.chapter,
    required this.index,
    required this.size,
    required this.locked,
    required this.completed,
    required this.previousTitle,
  });
  final ChapterModel chapter;
  final int index;
  final double size;
  final bool locked;
  final bool completed;
  final String? previousTitle;

  @override
  State<_IslandNode> createState() => _IslandNodeState();
}

class _IslandNodeState extends State<_IslandNode> {
  bool _down = false;
  int _shake = 0;

  static const _grey = ColorFilter.matrix(<double>[
    .33, .33, .33, 0, 0,
    .33, .33, .33, 0, 0,
    .33, .33, .33, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  void _tap() {
    if (widget.locked) {
      setState(() => _shake++);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Bab terkunci. Lulus kuis "${widget.previousTitle ?? 'bab sebelumnya'}" terlebih dahulu.',
        ),
      ));
      return;
    }
    AudioService.instance.sfx('sfx_tap');
    context.push('/chapter/${widget.chapter.id}');
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final status = widget.locked ? 'Terkunci' : (widget.completed ? 'Selesai' : 'Terbuka');
    final statusColor = widget.locked
        ? Colors.grey.shade600
        : (widget.completed ? AppColors.success : AppColors.terracotta);

    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: _tap,
      child: AnimatedScale(
        scale: _down ? .93 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Shake(
          trigger: _shake,
          child: Padding(
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: s,
                  height: s * .82,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ColorFiltered(
                        colorFilter: widget.locked ? _grey : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                        child: CustomPaint(
                          size: Size(s, s * .82),
                          painter: _IslandPainter(widget.chapter.theme),
                        ),
                      ),
                      if (widget.locked)
                        Container(
                          width: s * .26,
                          height: s * .26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.brown.withValues(alpha: .85),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(Icons.lock, color: Colors.white, size: s * .13),
                        ),
                      if (widget.completed)
                        Positioned(
                          top: s * .02,
                          right: s * .06,
                          child: Container(
                            width: s * .2,
                            height: s * .2,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.success,
                              border: Border.all(color: Colors.white, width: 2.5),
                            ),
                            child: Icon(Icons.check, color: Colors.white, size: s * .12),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.sand, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brown.withValues(alpha: .12),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Bab ${widget.chapter.order}  |  $status',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w800, color: statusColor)),
                      const SizedBox(height: 2),
                      Text(
                        widget.chapter.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.heading(13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IslandPainter extends CustomPainter {
  _IslandPainter(this.theme);
  final String theme;
  @override
  void paint(Canvas canvas, Size size) => paintIsland(canvas, size, theme);
  @override
  bool shouldRepaint(covariant _IslandPainter old) => old.theme != theme;
}

class _MapPainter extends CustomPainter {
  _MapPainter(this.centers, this.progress, this.chapters);
  final List<Offset> centers;
  final ProgressModel progress;
  final List<ChapterModel> chapters;

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;

    // laut
    canvas.drawRect(
      Offset.zero & s,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFBFE6EE), Color(0xFF8CCBD6), Color(0xFF6BB5C4)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Offset.zero & s),
    );

    // motif gelombang
    final wave = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: .38);
    for (var i = 0; i < 40; i++) {
      final x = w * ((i * .137) % 1);
      final y = h * ((i * .071 + .03) % 1);
      canvas.drawPath(
        Path()
          ..moveTo(x - 12, y)
          ..quadraticBezierTo(x - 6, y - 5, x, y)
          ..quadraticBezierTo(x + 6, y + 5, x + 12, y),
        wave,
      );
    }

    // jalur putus-putus antar pulau (emas jika bab tujuan sudah terbuka)
    for (var i = 0; i < centers.length - 1; i++) {
      final a = centers[i], b = centers[i + 1];
      final midY = (a.dy + b.dy) / 2;
      final seg = Path()
        ..moveTo(a.dx, a.dy)
        ..cubicTo(a.dx, midY, b.dx, midY, b.dx, b.dy);
      final open = progress.unlockedChapterIds.contains(chapters[i + 1].id);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..color = open ? AppColors.gold : Colors.white.withValues(alpha: .6);
      for (final m in seg.computeMetrics()) {
        for (double d = 0; d < m.length; d += 24) {
          final en = d + 12 > m.length ? m.length : d + 12;
          canvas.drawPath(m.extractPath(d, en), paint);
        }
      }
    }

    // kapal layar (motif kapal Lampung) di antara pulau
    for (var i = 0; i < centers.length; i++) {
      final left = i.isEven;
      final y = centers[i].dy + (i < centers.length - 1 ? (centers[i + 1].dy - centers[i].dy) * .5 : w * .32);
      paintKapal(canvas, Offset(left ? w * .86 : w * .14, y), w * .11,
          hull: i.isEven ? AppColors.maroon : AppColors.terracotta);
    }

    // pulau kecil berpohon kelapa sebagai hiasan
    void islet(Offset c, double r) {
      canvas.drawOval(Rect.fromCenter(center: c.translate(0, r * .2), width: r * 2.4, height: r * .7),
          Paint()..color = const Color(0xFFE9CE96));
      canvas.drawOval(Rect.fromCenter(center: c, width: r * 2, height: r * .6),
          Paint()..color = const Color(0xFF6FB07F));
      paintPalm(canvas, c.translate(-r * .2, 0), r * 1.3);
    }

    islet(Offset(w * .88, centers.first.dy - w * .2), w * .07);
    islet(Offset(w * .10, centers.last.dy + w * .30), w * .08);

    // awan statis
    final cloud = Paint()..color = Colors.white.withValues(alpha: .8);
    for (var i = 0; i < 5; i++) {
      final x = w * ((i * .31 + .12) % 1);
      final y = h * (.06 + i * .19);
      canvas.drawOval(Rect.fromCenter(center: Offset(x, y), width: 90, height: 24), cloud);
      canvas.drawOval(Rect.fromCenter(center: Offset(x + 20, y - 9), width: 52, height: 24), cloud);
    }

    // kompas
    final cc = Offset(w * .87, h * .02 + 96);
    canvas.drawCircle(cc, 24, Paint()..color = Colors.white.withValues(alpha: .7));
    canvas.drawCircle(
      cc,
      24,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = AppColors.gold,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cc.dx, cc.dy - 19)
        ..lineTo(cc.dx + 6, cc.dy)
        ..lineTo(cc.dx - 6, cc.dy)
        ..close(),
      Paint()..color = AppColors.terracotta,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cc.dx, cc.dy + 19)
        ..lineTo(cc.dx + 6, cc.dy)
        ..lineTo(cc.dx - 6, cc.dy)
        ..close(),
      Paint()..color = AppColors.brown,
    );

    // tepian bermotif tumpal di sisi atas dan bawah peta
    paintTumpalRow(canvas, Rect.fromLTWH(0, 0, w, 16));
    paintTumpalRow(canvas, Rect.fromLTWH(0, h - 16, w, 16));
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) =>
      old.progress != progress || old.centers.length != centers.length;
}

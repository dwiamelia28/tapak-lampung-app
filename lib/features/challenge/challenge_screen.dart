import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../services/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/chapter_guard.dart';
import '../../core/widgets/chapter_scene.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/shake.dart';
import '../../core/widgets/state_views.dart';
import '../../models/challenge_model.dart';
import '../../models/content_model.dart';
import '../../providers/content_providers.dart';

IconData _iconFor(String key) {
  switch (key) {
    case 'checkroom':
      return Icons.checkroom;
    case 'crown':
      return Icons.workspace_premium;
    case 'ship':
      return Icons.directions_boat;
    case 'dance':
      return Icons.accessibility_new;
    case 'music':
      return Icons.music_note;
    case 'home':
      return Icons.home_work;
    case 'food':
      return Icons.restaurant;
    case 'coffee':
      return Icons.coffee;
    case 'cake':
      return Icons.cake;
    default:
      return Icons.category;
  }
}

class ChallengeScreen extends StatelessWidget {
  const ChallengeScreen({super.key, required this.chapterId});
  final String chapterId;
  @override
  Widget build(BuildContext context) => ChapterGuard(
        chapterId: chapterId,
        builder: (_) => _ChallengeBody(chapterId: chapterId),
      );
}

class _ChallengeBody extends ConsumerStatefulWidget {
  const _ChallengeBody({required this.chapterId});
  final String chapterId;
  @override
  ConsumerState<_ChallengeBody> createState() => _ChallengeBodyState();
}

class _ChallengeBodyState extends ConsumerState<_ChallengeBody> {
  // umum
  int _mistakes = 0;
  int _shake = 0;
  String? _message;
  bool _messageGood = true;
  // find
  int _step = 0;
  final Set<String> _found = {};
  // match
  final Map<String, List<ChallengeToken>> _placed = {};
  final Set<String> _placedIds = {};
  List<ChallengeToken>? _tokens;

  void _reset() => setState(() {
        _mistakes = 0;
        _shake = 0;
        _message = null;
        _step = 0;
        _found.clear();
        _placed.clear();
        _placedIds.clear();
        _tokens = null;
      });

  void _miss(String msg) {
    AudioService.instance.sfx('sfx_wrong');
    setState(() {
      _mistakes++;
      _shake++;
      _message = msg;
      _messageGood = false;
    });
  }

  int get _stars => _mistakes == 0 ? 3 : (_mistakes <= 2 ? 2 : 1);

  @override
  Widget build(BuildContext context) {
    final a = ref.watch(chapterProvider(widget.chapterId));
    final b = ref.watch(challengeProvider(widget.chapterId));
    final c = ref.watch(contentsProvider(widget.chapterId));

    if (a.isLoading || b.isLoading || c.isLoading) {
      return const Scaffold(body: LoadingView());
    }
    if (a.hasError || b.hasError || c.hasError) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorView(onRetry: () {
          ref.invalidate(chapterProvider(widget.chapterId));
          ref.invalidate(challengeProvider(widget.chapterId));
          ref.invalidate(contentsProvider(widget.chapterId));
        }),
      );
    }
    final chapter = a.valueOrNull;
    final challenge = b.valueOrNull;
    final contents = c.valueOrNull ?? const [];
    if (chapter == null || challenge == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tantangan')),
        body: EmptyView(
          title: 'Tantangan belum tersedia',
          note: 'Bab ini belum punya tantangan. Kamu bisa langsung mengerjakan kuis.',
          action: SizedBox(
            width: 200,
            child: PrimaryButton(
              label: 'Ke Kuis',
              onPressed: () => context.pushReplacement('/chapter/${widget.chapterId}/quiz'),
            ),
          ),
        ),
      );
    }

    final isFind = challenge.type == 'find';
    final hotspots = contents.isEmpty ? <Hotspot>[] : contents.first.hotspots;
    final byId = {for (final h in hotspots) h.id: h};
    final order = challenge.findIds.where(byId.containsKey).toList();
    _tokens ??= ([...challenge.tokens]..shuffle(math.Random()));

    final done = isFind
        ? (order.isNotEmpty && _step >= order.length)
        : (challenge.tokens.isNotEmpty && _placedIds.length >= challenge.tokens.length);

    return Scaffold(
      appBar: AppBar(title: Text(challenge.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          _InstructionCard(text: challenge.instruction),
          const SizedBox(height: 12),
          if (isFind && order.isEmpty || !isFind && challenge.tokens.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Data tantangan ini belum lengkap.', textAlign: TextAlign.center),
            )
          else if (done)
            _DonePanel(
              stars: _stars,
              mistakes: _mistakes,
              onRetry: _reset,
              onQuiz: () => context.pushReplacement('/chapter/${widget.chapterId}/quiz'),
            )
          else if (isFind)
            ..._buildFind(chapter.theme, hotspots, byId, order)
          else
            ..._buildMatch(challenge),
        ],
      ),
    );
  }

  // ------------------------------------------------------------- find
  List<Widget> _buildFind(
      String theme, List<Hotspot> hotspots, Map<String, Hotspot> byId, List<String> order) {
    final target = byId[order[_step]]!;
    return [
      LinearProgressIndicator(
        value: _step / order.length,
        minHeight: 10,
        color: AppColors.forest,
        backgroundColor: AppColors.sand,
        borderRadius: BorderRadius.circular(8),
      ),
      const SizedBox(height: 8),
      Text('Langkah ${_step + 1} dari ${order.length}',
          style: const TextStyle(color: AppColors.brownSoft, fontWeight: FontWeight.w700)),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.forest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Temukan: ${target.label}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      Shake(
        trigger: _shake,
        child: ChapterScene(
          theme: theme,
          hotspots: hotspots,
          mode: SceneMode.find,
          foundIds: _found,
          onHotspotTap: (h) {
            if (h.id == target.id) {
              AudioService.instance.sfx('sfx_correct');
              setState(() {
                _found.add(h.id);
                _step++;
                _message = 'Tepat sekali!';
                _messageGood = true;
              });
            } else {
              _miss('Itu bukan ${target.label}. Coba lagi!');
            }
          },
          onMiss: () => _miss('Belum tepat. Perhatikan lagi gambarnya!'),
        ),
      ),
      const SizedBox(height: 12),
      _Feedback(message: _message, good: _messageGood),
    ];
  }

  // ------------------------------------------------------------ match
  void _drop(ChallengeTarget t, String tokenId) {
    final token = _tokens!.firstWhere((e) => e.id == tokenId);
    if (_placedIds.contains(tokenId)) return;
    if (token.target == t.id) {
      AudioService.instance.sfx('sfx_correct');
      setState(() {
        _placed.putIfAbsent(t.id, () => []).add(token);
        _placedIds.add(tokenId);
        _message = 'Benar! "${token.label}" cocok dengan ${t.label}.';
        _messageGood = true;
      });
    } else {
      _miss('Belum cocok. Coba pasangkan ke tempat lain!');
    }
  }

  Widget _chip(String label, {bool dragging = false}) => Material(
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 240),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: dragging ? AppColors.goldLight : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gold, width: 1.8),
            boxShadow: [
              BoxShadow(
                  color: AppColors.brown.withValues(alpha: dragging ? .3 : .1),
                  blurRadius: dragging ? 14 : 6,
                  offset: const Offset(0, 3)),
            ],
          ),
          child: Text(label,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        ),
      );

  List<Widget> _buildMatch(ChallengeModel ch) {
    final remaining = _tokens!.where((t) => !_placedIds.contains(t.id)).toList();
    return [
      LinearProgressIndicator(
        value: _placedIds.length / ch.tokens.length,
        minHeight: 10,
        color: AppColors.forest,
        backgroundColor: AppColors.sand,
        borderRadius: BorderRadius.circular(8),
      ),
      const SizedBox(height: 8),
      Text('${_placedIds.length} dari ${ch.tokens.length} berhasil dipasangkan',
          style: const TextStyle(color: AppColors.brownSoft, fontWeight: FontWeight.w700)),
      const SizedBox(height: 14),
      for (final t in ch.targets)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Shake(
            trigger: _shake,
            child: DragTarget<String>(
              onWillAcceptWithDetails: (_) => true,
              onAcceptWithDetails: (d) => _drop(t, d.data),
              builder: (context, candidate, rejected) {
                final hot = candidate.isNotEmpty;
                final items = _placed[t.id] ?? const <ChallengeToken>[];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: hot ? AppColors.goldLight.withValues(alpha: .5) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: hot ? AppColors.gold : AppColors.sand, width: hot ? 2.5 : 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.forest.withValues(alpha: .12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(_iconFor(t.icon), color: AppColors.forest),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(t.label, style: AppTheme.heading(17))),
                          if (items.isEmpty)
                            const Text('Letakkan di sini',
                                style: TextStyle(fontSize: 12, color: AppColors.brownSoft)),
                        ],
                      ),
                      if (items.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final it in items)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: .15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.check_circle,
                                        size: 16, color: AppColors.success),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(it.label,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700, fontSize: 13)),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      const SizedBox(height: 4),
      Text('Seret kartu ke tempat yang sesuai:',
          style: AppTheme.heading(15, color: AppColors.brownSoft)),
      const SizedBox(height: 10),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final tk in remaining)
            Draggable<String>(
              data: tk.id,
              feedback: _chip(tk.label, dragging: true),
              childWhenDragging: Opacity(opacity: .3, child: _chip(tk.label)),
              child: _chip(tk.label),
            ),
        ],
      ),
      const SizedBox(height: 12),
      _Feedback(message: _message, good: _messageGood),
    ];
  }
}

class _InstructionCard extends StatelessWidget {
  const _InstructionCard({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.goldLight.withValues(alpha: .35),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: AppColors.brown),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: const TextStyle(height: 1.4))),
          ],
        ),
      );
}

class _Feedback extends StatelessWidget {
  const _Feedback({required this.message, required this.good});
  final String? message;
  final bool good;
  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: message == null
            ? const SizedBox(height: 24, key: ValueKey('none'))
            : Container(
                key: ValueKey(message),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (good ? AppColors.success : AppColors.error).withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(good ? Icons.check_circle : Icons.error_outline,
                        color: good ? AppColors.success : AppColors.error),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(message!,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: good ? AppColors.success : AppColors.error)),
                    ),
                  ],
                ),
              ),
      );
}

class _DonePanel extends StatelessWidget {
  const _DonePanel({
    required this.stars,
    required this.mistakes,
    required this.onRetry,
    required this.onQuiz,
  });
  final int stars;
  final int mistakes;
  final VoidCallback onRetry;
  final VoidCallback onQuiz;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          const SizedBox(height: 16),
          Text('Tantangan Selesai!', style: AppTheme.heading(26)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < 3; i++)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 500 + i * 250),
                  curve: Curves.elasticOut,
                  builder: (_, v, __) => Transform.scale(
                    scale: v.clamp(0.0, 1.4),
                    child: Icon(
                      i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 64,
                      color: i < stars ? AppColors.gold : AppColors.sand,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            mistakes == 0 ? 'Sempurna, tanpa kesalahan!' : 'Kesalahan: $mistakes',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          PrimaryButton(label: 'Lanjut ke Kuis', icon: Icons.quiz_rounded, onPressed: onQuiz),
          const SizedBox(height: 12),
          PrimaryButton(
              label: 'Ulangi Tantangan', color: AppColors.forest, onPressed: onRetry),
        ],
      );
}

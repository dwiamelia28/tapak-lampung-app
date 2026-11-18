import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../services/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/chapter_guard.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/shake.dart';
import '../../core/widgets/state_views.dart';
import '../../models/quiz_model.dart';
import '../../providers/content_providers.dart';
import '../../providers/providers.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key, required this.chapterId});
  final String chapterId;
  @override
  Widget build(BuildContext context) => ChapterGuard(
        chapterId: chapterId,
        builder: (_) => _QuizBody(chapterId: chapterId),
      );
}

class _QuizBody extends ConsumerStatefulWidget {
  const _QuizBody({required this.chapterId});
  final String chapterId;
  @override
  ConsumerState<_QuizBody> createState() => _QuizBodyState();
}

class _QuizBodyState extends ConsumerState<_QuizBody> {
  int _index = 0;
  int? _selected; // indeks tampilan yang dipilih
  bool _answered = false;
  int _correct = 0;
  bool _submitting = false;
  int _shake = 0;
  List<List<int>>? _orders;

  List<List<int>> _makeOrders(QuizModel q) {
    final r = math.Random();
    return q.questions
        .map((qq) => List<int>.generate(qq.options.length, (i) => i)..shuffle(r))
        .toList();
  }

  void _select(int displayIndex, QuizQuestion q) {
    if (_answered) return;
    final orig = _orders![_index][displayIndex];
    final ok = orig == q.correctIndex;
    AudioService.instance.sfx(ok ? 'sfx_correct' : 'sfx_wrong');
    setState(() {
      _selected = displayIndex;
      _answered = true;
      if (ok) {
        _correct++;
      } else {
        _shake++;
      }
    });
  }

  Future<void> _next(QuizModel quiz) async {
    if (_index < quiz.questions.length - 1) {
      setState(() {
        _index++;
        _selected = null;
        _answered = false;
      });
      return;
    }
    await _finish(quiz);
  }

  Future<void> _finish(QuizModel quiz) async {
    setState(() => _submitting = true);
    try {
      final user = ref.read(authStateProvider).valueOrNull;
      if (user == null) throw StateError('Sesi login berakhir. Silakan masuk lagi.');
      final chapters = ref.read(chaptersProvider).valueOrNull ?? const [];
      final idx = chapters.indexWhere((c) => c.id == widget.chapterId);
      if (idx < 0) throw StateError('Data bab tidak ditemukan.');
      final next = idx + 1 < chapters.length ? chapters[idx + 1] : null;
      final outcome = await ref.read(progressServiceProvider).submitQuiz(
            uid: user.uid,
            chapter: chapters[idx],
            next: next,
            totalChapters: chapters.length,
            quiz: quiz,
            correct: _correct,
          );
      if (mounted) {
        context.pushReplacement('/chapter/${widget.chapterId}/result', extra: outcome);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan hasil. Periksa koneksi lalu coba lagi.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizAsync = ref.watch(quizProvider(widget.chapterId));
    return quizAsync.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorView(onRetry: () => ref.invalidate(quizProvider(widget.chapterId))),
      ),
      data: (quiz) {
        if (quiz == null || quiz.questions.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Kuis')),
            body: const EmptyView(
              title: 'Kuis belum tersedia',
              note: 'Soal untuk bab ini belum diisi. Silakan kembali lagi nanti.',
            ),
          );
        }
        _orders ??= _makeOrders(quiz);
        final total = quiz.questions.length;
        final q = quiz.questions[_index];
        final order = _orders![_index];
        final last = _index == total - 1;

        return Scaffold(
          appBar: AppBar(title: Text(quiz.title)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            children: [
              Row(
                children: [
                  Text('Soal ${_index + 1}/$total',
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  const Spacer(),
                  const Icon(Icons.check_circle, size: 18, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text('$_correct benar', style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 8),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: (_index + (_answered ? 1 : 0)) / total),
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutCubic,
                builder: (_, v, __) => LinearProgressIndicator(
                  value: v,
                  minHeight: 12,
                  color: AppColors.forest,
                  backgroundColor: AppColors.sand,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (c, a) => FadeTransition(
                  opacity: a,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(.08, 0), end: Offset.zero)
                        .animate(a),
                    child: c,
                  ),
                ),
                child: Container(
                  key: ValueKey(_index),
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.sand, width: 1.5),
                  ),
                  child: Text(q.text, style: AppTheme.heading(20)),
                ),
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < order.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _OptionTile(
                    letter: String.fromCharCode(65 + i),
                    text: q.options[order[i]],
                    state: !_answered
                        ? _OptState.idle
                        : (order[i] == q.correctIndex
                            ? _OptState.correct
                            : (_selected == i ? _OptState.wrong : _OptState.dim)),
                    shake: (_answered && _selected == i && order[i] != q.correctIndex)
                        ? _shake
                        : 0,
                    onTap: () => _select(i, q),
                  ),
                ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: _answered
                    ? Container(
                        margin: const EdgeInsets.only(top: 4, bottom: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.goldLight.withValues(alpha: .35),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              _orders![_index][_selected!] == q.correctIndex
                                  ? Icons.celebration
                                  : Icons.lightbulb,
                              color: AppColors.brown,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${_orders![_index][_selected!] == q.correctIndex ? 'Benar! ' : 'Kurang tepat. '}${q.explanation}',
                                style: const TextStyle(height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
              if (_answered)
                PrimaryButton(
                  label: last ? 'Lihat Hasil' : 'Lanjut',
                  icon: last ? Icons.emoji_events : Icons.arrow_forward,
                  loading: _submitting,
                  onPressed: () => _next(quiz),
                ),
            ],
          ),
        );
      },
    );
  }
}

enum _OptState { idle, correct, wrong, dim }

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.letter,
    required this.text,
    required this.state,
    required this.shake,
    required this.onTap,
  });
  final String letter;
  final String text;
  final _OptState state;
  final int shake;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.white;
    Color border = AppColors.sand;
    Color badge = AppColors.sand;
    Widget badgeChild = Text(letter, style: const TextStyle(fontWeight: FontWeight.w800));
    switch (state) {
      case _OptState.correct:
        bg = AppColors.success.withValues(alpha: .14);
        border = AppColors.success;
        badge = AppColors.success;
        badgeChild = const Icon(Icons.check, color: Colors.white, size: 18);
      case _OptState.wrong:
        bg = AppColors.error.withValues(alpha: .12);
        border = AppColors.error;
        badge = AppColors.error;
        badgeChild = const Icon(Icons.close, color: Colors.white, size: 18);
      case _OptState.dim:
        bg = Colors.white.withValues(alpha: .6);
      case _OptState.idle:
        break;
    }
    return Shake(
      trigger: shake,
      child: AnimatedScale(
        scale: state == _OptState.correct ? 1.03 : 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.elasticOut,
        child: GestureDetector(
          onTap: state == _OptState.idle ? onTap : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border, width: 2),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(color: badge, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: badgeChild,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(text,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

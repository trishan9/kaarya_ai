import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/app/routes/app_routes.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_feedback_entity.dart';
import 'package:kaarya/features/interviews/presentation/pages/take_interview_screen.dart';
import 'package:kaarya/features/interviews/presentation/view_model/take_interview_view_model.dart';

class InterviewFeedbackPage extends ConsumerStatefulWidget {
  final String sessionId;
  final String? interviewId;

  /// When true, skip the AI-generation wait (use for already-completed sessions
  /// navigated from history, not from a just-finished live interview).
  final bool immediate;

  const InterviewFeedbackPage({
    super.key,
    required this.sessionId,
    this.interviewId,
    this.immediate = false,
  });

  @override
  ConsumerState<InterviewFeedbackPage> createState() =>
      _InterviewFeedbackPageState();
}

class _InterviewFeedbackPageState extends ConsumerState<InterviewFeedbackPage> {
  late bool _isGenerating;
  // Stays true until the first loadFeedback call completes (success or failure).
  // Ensures the loading spinner is always shown on first render — prevents any
  // flash of empty/stale state before the API response arrives.
  bool _localLoading = true;
  static const _generationDelay = Duration(seconds: 5);
  static const _retryDelay = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    _isGenerating = !widget.immediate;
    // Defer until after first build — Riverpod disallows state updates during
    // the widget mount / _firstBuild phase (would throw a ProviderElement error).
    Future.microtask(_waitThenFetch);
  }

  Future<void> _waitThenFetch() async {
    try {
      if (!widget.immediate) {
        // Give the backend time to finish generating the AI evaluation
        // (only needed right after a live interview completes).
        await Future.delayed(_generationDelay);
        if (!mounted) return;
        setState(() => _isGenerating = false);
      }
      await ref
          .read(takeInterviewViewModelProvider.notifier)
          .loadFeedback(widget.sessionId);
    } finally {
      if (mounted) setState(() => _localLoading = false);
    }
    if (!mounted) return;
    // If scores look like unfinished placeholders, retry once after a short delay
    final feedback = ref.read(takeInterviewViewModelProvider).feedback;
    if (_looksLikePlaceholder(feedback)) {
      await Future.delayed(_retryDelay);
      if (!mounted) return;
      ref
          .read(takeInterviewViewModelProvider.notifier)
          .loadFeedback(widget.sessionId);
    }
  }

  bool _looksLikePlaceholder(dynamic feedback) {
    // null means the API returned an error — show the error state + Retry,
    // don't auto-retry (a second request won't help if evaluation isn't ready).
    if (feedback == null) return false;
    // If totalScore is null or 0, evaluation generation may still be in flight
    if (feedback.totalScore == null || feedback.totalScore == 0) return true;
    // If all category scores are identical it's likely a default placeholder
    final scores = feedback.categoryScores
        .map((c) => c.score)
        .where((s) => s != null)
        .toList();
    if (scores.length >= 2 && scores.toSet().length == 1) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(takeInterviewViewModelProvider);
    final feedback = state.feedback;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Interview Feedback'),
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft),
          onPressed: () => AppRoutes.pop(context),
        ),
      ),
      body: _isGenerating || _localLoading || state.isFeedbackLoading
          ? _buildGeneratingState(_isGenerating)
          : feedback == null
              ? _buildEmptyState(state.error)
              : _buildFeedbackContent(feedback),
    );
  }

  Widget _buildGeneratingState(bool isGenerating) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 20),
            Text(
              isGenerating
                  ? 'Generating your evaluation...'
                  : 'Loading feedback...',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0D6FAE),
              ),
            ),
            if (isGenerating) ...[
              const SizedBox(height: 8),
              const Text(
                'Our AI is analysing your responses. This takes a few seconds.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String? error) {
    final message = error != null && error.isNotEmpty
        ? error
        : 'Your evaluation is still being generated.\nTap Retry in a few seconds.';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.fileSearch, size: 48, color: AppColors.textLight),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textLight,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(takeInterviewViewModelProvider.notifier)
                    .loadFeedback(widget.sessionId);
              },
              icon: Icon(LucideIcons.rotateCcw, size: 15),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackContent(InterviewFeedbackEntity feedback) {
    final totalScore = (feedback.totalScore ?? 0).round().clamp(0, 100);
    final band = _getPerformanceBand(totalScore);
    final benchmark = _getLevelBenchmark(feedback.interviewLevel);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => AppRoutes.pop(context),
                  icon: Icon(LucideIcons.arrowLeft, size: 16),
                  label: const Text('Back'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (widget.interviewId != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => AppRoutes.pushReplacement(
                      context,
                      TakeInterviewScreen(interviewId: widget.interviewId!),
                    ),
                    icon: Icon(LucideIcons.rotateCcw, size: 16),
                    label: const Text('Retake'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Score hero card
          _buildScoreHeroCard(feedback, totalScore, band, benchmark),
          const SizedBox(height: 16),

          // Category scores
          _buildCategoryScores(feedback, band),
          const SizedBox(height: 16),

          // Strengths & Areas for improvement
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildListSection(
                  icon: LucideIcons.circleCheck,
                  iconColor: const Color(0xFF16A34A),
                  title: 'Strengths',
                  items: feedback.strengths,
                  bgColor: const Color(0xFFF3FBF5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildListSection(
                  icon: LucideIcons.triangleAlert,
                  iconColor: const Color(0xFFD97706),
                  title: 'Improve',
                  items: feedback.areasForImprovement,
                  bgColor: const Color(0xFFFFF7F2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildScoreHeroCard(
    InterviewFeedbackEntity feedback,
    int totalScore,
    _PerformanceBand band,
    _LevelBenchmark benchmark,
  ) {
    final scoreAccent = _getScoreAccent(totalScore);
    final rangeMessage = _getScoreRangeMessage(totalScore, benchmark);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D6FAE), Color(0xFF084F7F)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF084F7F).withValues(alpha: 0.35),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badges
          Row(
            children: [
              _whiteBadge('AI Interview Report'),
              const SizedBox(width: 8),
              _whiteBadge('${benchmark.label} level'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            feedback.interviewTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${band.note} $rangeMessage',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 16),

          // Score ring + metrics
          Row(
            children: [
              // Score ring
              _buildScoreRing(totalScore, scoreAccent, band),
              const SizedBox(width: 16),
              // Metrics
              Expanded(
                child: Column(
                  children: [
                    _metricPill(LucideIcons.target, 'Recommended',
                        '${benchmark.min}-${benchmark.max}'),
                    const SizedBox(height: 8),
                    _metricPill(LucideIcons.chartBar, 'Skills Rated',
                        '${feedback.categoryScores.length}'),
                    const SizedBox(height: 8),
                    if (feedback.durationSeconds != null)
                      _metricPill(
                        LucideIcons.clock,
                        'Duration',
                        '${(feedback.durationSeconds! / 60).round()} min',
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRing(int score, Color accent, _PerformanceBand band) {
    return SizedBox(
      width: 100,
      height: 100,
      child: CustomPaint(
        painter: _ScoreRingPainter(
          score: score,
          accentColor: accent,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                'of 100',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryScores(
      InterviewFeedbackEntity feedback, _PerformanceBand band) {
    if (feedback.categoryScores.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Category Analysis',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFECECF0)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Evidence-Based',
                  style: TextStyle(fontSize: 11, color: AppColors.textLight),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...feedback.categoryScores.map((cat) {
            final score = cat.score.round().clamp(0, 100);
            final catBand = _getPerformanceBand(score);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFBFD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFECECF0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        cat.category,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFECECF0)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$score/100',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Score bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: score / 100,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE8EDF3),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(catBand.barColor),
                    ),
                  ),
                  if (cat.feedback != null && cat.feedback!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      cat.feedback!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textLight,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildListSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<String> items,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (items.isNotEmpty)
            ...items.map((item) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textLight,
                      height: 1.3,
                    ),
                  ),
                ))
          else
            Text(
              'No items listed.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textLight.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
    );
  }

  Widget _whiteBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _metricPill(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.85)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ───

  _PerformanceBand _getPerformanceBand(int score) {
    if (score >= 85) {
      return _PerformanceBand(
        label: 'Excellent',
        note: 'Strong readiness for real interviews.',
        barColor: const Color(0xFF10B981),
      );
    }
    if (score >= 70) {
      return _PerformanceBand(
        label: 'Good',
        note: 'Solid baseline with a few areas to sharpen.',
        barColor: const Color(0xFF38BDF8),
      );
    }
    if (score >= 55) {
      return _PerformanceBand(
        label: 'Developing',
        note: 'Improving, but key gaps are still visible.',
        barColor: const Color(0xFFF59E0B),
      );
    }
    return _PerformanceBand(
      label: 'Needs Work',
      note: 'Focus on fundamentals before advanced rounds.',
      barColor: const Color(0xFFFB7185),
    );
  }

  Color _getScoreAccent(int score) {
    if (score >= 85) return const Color(0xFF34D399);
    if (score >= 70) return const Color(0xFF38BDF8);
    if (score >= 55) return const Color(0xFFF59E0B);
    return const Color(0xFFFB7185);
  }

  _LevelBenchmark _getLevelBenchmark(String? level) {
    final normalized = (level ?? '').trim().toLowerCase();
    if (normalized.isEmpty) return _LevelBenchmark('General', 60, 80);
    if (normalized.contains('intern') ||
        normalized.contains('entry') ||
        normalized.contains('fresher') ||
        normalized.contains('junior')) {
      return _LevelBenchmark('Intern/Entry', 55, 72);
    }
    if (normalized.contains('senior') ||
        normalized.contains('lead') ||
        normalized.contains('staff') ||
        normalized.contains('principal')) {
      return _LevelBenchmark('Senior/Lead', 75, 90);
    }
    return _LevelBenchmark('Mid-Level', 65, 82);
  }

  String _getScoreRangeMessage(int score, _LevelBenchmark range) {
    if (score < range.min) return 'You are below the recommended range.';
    if (score > range.max) return 'You are above the recommended range. Great job.';
    return 'You are within the recommended range.';
  }
}

class _PerformanceBand {
  final String label;
  final String note;
  final Color barColor;

  const _PerformanceBand({
    required this.label,
    required this.note,
    required this.barColor,
  });
}

class _LevelBenchmark {
  final String label;
  final int min;
  final int max;

  const _LevelBenchmark(this.label, this.min, this.max);
}

class _ScoreRingPainter extends CustomPainter {
  final int score;
  final Color accentColor;

  _ScoreRingPainter({required this.score, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // Background ring
    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Score arc
    final scorePaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (score / 100) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      scorePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.accentColor != accentColor;
  }
}

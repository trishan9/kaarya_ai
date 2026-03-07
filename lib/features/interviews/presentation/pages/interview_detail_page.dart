import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_entity.dart';
import 'package:kaarya/features/interviews/presentation/pages/interview_feedback_page.dart';
import 'package:kaarya/features/interviews/presentation/pages/take_interview_screen.dart';
import 'package:kaarya/app/routes/app_routes.dart';

class InterviewDetailPage extends ConsumerWidget {
  final InterviewEntity interview;

  const InterviewDetailPage({super.key, required this.interview});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Interview Details'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => AppRoutes.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroCard(context),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoChips(),
                  const SizedBox(height: 20),
                  if (interview.techStack.isNotEmpty) ...[
                    _buildTechStack(),
                    const SizedBox(height: 20),
                  ],
                  if (interview.hasAttempted) ...[
                    _buildAttemptInfo(context),
                    const SizedBox(height: 20),
                  ],
                  _buildFeaturesList(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D6FAE), Color(0xFF084F7F)],
        ),
        borderRadius: BorderRadius.circular(20),
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
          Row(
            children: [
              _badge(
                'AI-Powered Mock Interview',
                Colors.white.withValues(alpha: 0.15),
                Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            interview.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            interview.role,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
          if (interview.companyName.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              interview.companyName,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _badge(
                _formatInterviewType(interview.interviewType),
                Colors.white.withValues(alpha: 0.15),
                Colors.white,
              ),
              const SizedBox(width: 8),
              if (interview.status.isNotEmpty)
                _badge(
                  interview.status[0].toUpperCase() +
                      interview.status.substring(1),
                  Colors.white.withValues(alpha: 0.15),
                  Colors.white,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _infoChip(LucideIcons.clock, '25 min', 'Duration'),
        _infoChip(LucideIcons.messageSquareText, '8 Qs', 'Questions'),
        _infoChip(
          LucideIcons.chartBar,
          '${interview.attemptsCount}',
          'Attempts',
        ),
        if (interview.myLatestScore != null)
          _infoChip(
            LucideIcons.target,
            '${interview.myLatestScore!.round()}',
            'Latest Score',
          ),
      ],
    );
  }

  Widget _infoChip(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7EEF7)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: AppColors.textDark,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildTechStack() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tech Stack',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: interview.techStack.map((tech) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tech,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAttemptInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3FBF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1F5D9)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.circleCheck, color: AppColors.success, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Previously Attempted',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
                if (interview.myLatestScore != null)
                  Text(
                    'Latest score: ${interview.myLatestScore!.round()}/100',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textLight,
                    ),
                  ),
              ],
            ),
          ),
          if (interview.myLatestSessionId != null)
            TextButton(
              onPressed: () => AppRoutes.push(
                context,
                InterviewFeedbackPage(
                  sessionId: interview.myLatestSessionId!,
                  interviewId: interview.id,
                ),
              ),
              child: const Text('View Results'),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      (LucideIcons.mic, 'Voice-Powered AI Interview'),
      (LucideIcons.brain, 'AI-Generated Evaluation & Feedback'),
      (LucideIcons.chartBar, 'Detailed Category Scoring'),
      (LucideIcons.messageSquareText, 'Real-Time Transcript'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What to Expect',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        ...features.map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(f.$1, size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Text(
                f.$2,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => AppRoutes.push(
                context,
                TakeInterviewScreen(
                  interviewId: interview.id,
                  interview: interview,
                ),
              ),
              icon: const Icon(LucideIcons.mic, size: 18),
              label: Text(
                interview.hasAttempted ? 'Retake Interview' : 'Start Interview',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Use a quiet environment and clear audio for better AI evaluation.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textLight.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  String _formatInterviewType(String type) {
    switch (type) {
      case 'technical':
        return 'Technical';
      case 'behavioral':
        return 'Behavioral';
      case 'mixed':
        return 'Mixed';
      case 'system_design':
        return 'System Design';
      case 'custom':
        return 'Custom';
      default:
        return type;
    }
  }
}

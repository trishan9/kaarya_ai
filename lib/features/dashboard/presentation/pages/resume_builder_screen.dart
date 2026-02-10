import 'package:flutter/material.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ResumeBuilderScreen extends StatelessWidget {
  const ResumeBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        _buildHero(),
        const SizedBox(height: 28),
        _buildFeatureCard(
          icon: LucideIcons.sparkles,
          color: AppColors.primary,
          title: 'AI-Powered Resume',
          description:
              'Generate a professional, ATS-optimized resume tailored to your target role using AI.',
        ),
        const SizedBox(height: 14),
        _buildFeatureCard(
          icon: LucideIcons.fileCheck,
          color: const Color(0xFF059669),
          title: 'ATS Score Checker',
          description:
              'Upload your resume and instantly see how well it performs against ATS systems.',
        ),
        const SizedBox(height: 14),
        _buildFeatureCard(
          icon: LucideIcons.pencilLine,
          color: const Color(0xFFD97706),
          title: 'Smart Suggestions',
          description:
              'Get section-by-section feedback and improvement tips powered by AI analysis.',
        ),
        const SizedBox(height: 14),
        _buildFeatureCard(
          icon: LucideIcons.layoutTemplate,
          color: const Color(0xFF7C3AED),
          title: 'Beautiful Templates',
          description:
              'Choose from modern, recruiter-approved templates designed to stand out.',
        ),
        const SizedBox(height: 32),
        _buildEmptyState(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF003D6E), Color(0xFF0471B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(15),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(10),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Resume Builder AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create standout, ATS-friendly resumes with the power of AI. '
                'Get smart suggestions, beautiful templates, and instant feedback.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: const Text(
                    'Create New Resume',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textLight,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: AppColors.bgSecondary,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            LucideIcons.fileText,
            size: 32,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'No resumes yet',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text(
          'Create your first AI-powered resume and\nstart applying to jobs with confidence.',
          style: TextStyle(fontSize: 14, color: AppColors.textMedium),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

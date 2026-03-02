import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/app/theme/theme_utils.dart';
import 'package:kaarya/core/utils/navigation_provider.dart';
import 'package:kaarya/core/widgets/loader_widget.dart';
import 'package:kaarya/features/dashboard/presentation/state/dashboard_state.dart';
import 'package:kaarya/features/dashboard/presentation/view_model/dashboard_view_model.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/deadline_card_widget.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/interview_readiness_chart_widget.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/invitation_card_widget.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/job_recommendation_widget.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/overview_analytics_charts_widget.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/rating_card_widget.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/summary_card_widget.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/tips_banner_widget.dart';

class OverviewScreen extends ConsumerStatefulWidget {
  const OverviewScreen({super.key});

  @override
  ConsumerState<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends ConsumerState<OverviewScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final vm = ref.read(dashboardViewModelProvider.notifier);
      final state = ref.read(dashboardViewModelProvider);
      if (state.overviewStatus != DashboardLoadStatus.loading &&
          state.overviewData == null) {
        vm.loadOverview(forceRefresh: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardViewModelProvider);
    final overviewData = dashboardState.overviewData;
    final status = dashboardState.overviewStatus;

    if (status == DashboardLoadStatus.loading && overviewData == null) {
      return const LoaderWidget();
    }

    if (status == DashboardLoadStatus.error && overviewData == null) {
      return _ErrorState(
        message:
            dashboardState.overviewErrorMessage ?? "Failed to load overview",
        onRetry: () => ref
            .read(dashboardViewModelProvider.notifier)
            .loadOverview(forceRefresh: true),
      );
    }

    if (overviewData == null) {
      return _ErrorState(
        message: "Overview data not available",
        onRetry: () => ref
            .read(dashboardViewModelProvider.notifier)
            .loadOverview(forceRefresh: true),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(dashboardViewModelProvider.notifier)
            .loadOverview(forceRefresh: true);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 20),
        child: Column(
          spacing: 18,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SummaryCardWidget(
              summary: overviewData.summary,
              onMonthChanged: (monthKey) {
                ref
                    .read(dashboardViewModelProvider.notifier)
                    .loadOverview(monthKey: monthKey, forceRefresh: true);
              },
            ),
            InvitationCardWidget(invitation: overviewData.invitation),
            DeadlineCardWidget(job: overviewData.deadlineJob),
            InterviewReadinessChartWidget(
              readinessPoints: overviewData.readinessPoints,
            ),
            OverviewAnalyticsChartsWidget(analytics: overviewData.analytics),
            RatingCardWidget(
              title: "Your Profile Rating",
              rating: overviewData.profileRating,
              badgeLabel: _profileBadge(overviewData.profileRating),
              description: _profileDescription(overviewData.profileRating),
              suggestionTitle: "Our Suggestion",
              suggestionBody: _profileSuggestion(overviewData.profileRating),
              actionLabel: "Improve Profile",
              onActionTap: () {
                ref.read(bottomNavProvider.notifier).state =
                    AppDestination.resumeBuilder;
              },
            ),
            RatingCardWidget(
              title: "Interview Overall Rating",
              rating: overviewData.interviewOverallRating,
              badgeLabel: _interviewBadge(overviewData.interviewOverallRating),
              ratingColor: _interviewRatingColor(
                overviewData.interviewOverallRating,
              ),
              badgeBackground: _interviewBadgeBackground(
                overviewData.interviewOverallRating,
              ),
              badgeTextColor: _interviewRatingColor(
                overviewData.interviewOverallRating,
              ),
              description: _interviewDescription(
                overviewData.interviewOverallRating,
              ),
              suggestionTitle: "Our Suggestion",
              suggestionBody: _interviewSuggestion(
                overviewData.interviewOverallRating,
              ),
              actionLabel: "Take an Interview",
              onActionTap: () {
                ref.read(bottomNavProvider.notifier).state =
                    AppDestination.interviewHub;
              },
            ),
            const TipsBannerWidget(),
            JobRecommendationWidget(
              jobsBucket: overviewData.jobs,
              onSeeAllTap: () {
                ref.read(bottomNavProvider.notifier).state =
                    AppDestination.explore;
              },
            ),
          ],
        ),
      ),
    );
  }

  String _profileBadge(double rating) {
    if (rating >= 90) return "Elite";
    if (rating >= 70) return "Strong";
    if (rating >= 50) return "Good";
    if (rating >= 25) return "Developing";
    return "Starter";
  }

  String _profileDescription(double rating) {
    if (rating >= 90) {
      return "Elite profile! You stand out to recruiters and are ready for top opportunities.";
    }
    if (rating >= 70) {
      return "Strong profile. Fill remaining sections to reach Elite status.";
    }
    if (rating >= 50) {
      return "Good progress. Complete more sections for stronger recruiter matching.";
    }
    if (rating >= 25) {
      return "Your profile is improving. Add more details to unlock better recommendations.";
    }
    return "Complete your profile to improve job recommendations and recruiter visibility.";
  }

  String _profileSuggestion(double rating) {
    if (rating >= 90) {
      return "Keep your resume updated with your latest projects and impact.";
    }
    if (rating >= 70) {
      return "Add certifications, complete your summary, and upload an ATS-optimized resume.";
    }
    if (rating >= 50) {
      return "Add experience with bullet points, certifications, and skills to strengthen your profile.";
    }
    if (rating >= 25) {
      return "Add education, experience, and skills to your profile.";
    }
    return "Fill basic profile, skills, and resume sections to improve visibility.";
  }

  String _interviewBadge(double rating) {
    if (rating >= 80) return "Excellent";
    if (rating >= 65) return "Good";
    if (rating >= 50) return "Average";
    if (rating > 0) return "Below Average";
    return "Not Started";
  }

  String _interviewDescription(double rating) {
    if (rating >= 80) {
      return "Your interview readiness is consistently strong across attempts.";
    }
    if (rating >= 65) {
      return "You have a solid interview baseline with room to sharpen.";
    }
    if (rating >= 50) {
      return "Your fundamentals are visible, but consistency needs work.";
    }
    if (rating > 0) {
      return "Your current performance is below target and needs focused practice.";
    }
    return "No interview attempts yet. Complete one mock to start your rating.";
  }

  String _interviewSuggestion(double rating) {
    if (rating >= 80) {
      return "Keep practicing targeted advanced interviews to maintain your momentum.";
    }
    if (rating >= 65) {
      return "Focus on weak categories from recent feedback and retake similar interviews.";
    }
    if (rating >= 50) {
      return "Give more mock interviews and improve low-scoring categories first.";
    }
    return "Take structured mock interviews and review feedback before each retake.";
  }

  Color _interviewRatingColor(double rating) {
    if (rating >= 80) return const Color(0xFF059669);
    if (rating >= 65) return AppColors.primary;
    if (rating >= 50) return const Color(0xFFD97706);
    if (rating > 0) return AppColors.error;
    return AppColors.textMedium;
  }

  Color _interviewBadgeBackground(double rating) {
    if (isDarkMode(context)) {
      if (rating >= 80) return const Color(0xFF12261C);
      if (rating >= 65) return const Color(0xFF102233);
      if (rating >= 50) return const Color(0xFF2A1E12);
      if (rating > 0) return const Color(0xFF2C1518);
      return const Color(0xFF1B2430);
    }
    if (rating >= 80) return const Color(0xFFECFDF3);
    if (rating >= 65) return AppColors.bgSecondary;
    if (rating >= 50) return const Color(0xFFFFF7ED);
    if (rating > 0) return const Color(0xFFFFF1F2);
    return const Color(0xFFF4F4F5);
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: onRetry, child: const Text("Retry")),
          ],
        ),
      ),
    );
  }
}

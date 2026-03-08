import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/routes/app_routes.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/utils/user_role_provider.dart';
import 'package:kaarya/core/widgets/loader_widget.dart';
import 'package:kaarya/features/colleges/presentation/view_model/college_dashboard_view_model.dart';
import 'package:kaarya/features/dashboard/presentation/state/dashboard_state.dart';
import 'package:kaarya/features/dashboard/presentation/view_model/dashboard_view_model.dart';
import 'package:kaarya/features/interviews/domain/entities/interview_entity.dart';
import 'package:kaarya/features/interviews/presentation/pages/create_interview_page.dart';
import 'package:kaarya/features/interviews/presentation/pages/interview_detail_page.dart';
import 'package:kaarya/features/recruiter/presentation/view_model/recruiter_view_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class InterviewManagementPage extends ConsumerStatefulWidget {
  const InterviewManagementPage({super.key});

  @override
  ConsumerState<InterviewManagementPage> createState() =>
      _InterviewManagementPageState();
}

class _InterviewManagementPageState
    extends ConsumerState<InterviewManagementPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(dashboardViewModelProvider.notifier).loadInterviews();
      if (ref.read(isRecruiterProvider)) {
        ref.read(recruiterViewModelProvider.notifier).loadWorkspaces();
      } else if (ref.read(isCollegeProvider)) {
        ref.read(collegeDashboardViewModelProvider.notifier).loadWorkspaces();
      }
    });
  }

  void _openCreateInterview() {
    final isRecruiter = ref.read(isRecruiterProvider);
    final isCollege = ref.read(isCollegeProvider);
    String? companyId;
    String? collegeId;

    if (isRecruiter) {
      final ws =
          ref.read(recruiterViewModelProvider).selectedWorkspace ??
          ref.read(recruiterViewModelProvider).workspaces?.firstOrNull;
      if (ws != null) companyId = ws.companyId;
    } else if (isCollege) {
      final ws =
          ref.read(collegeDashboardViewModelProvider).selectedWorkspace ??
          ref.read(collegeDashboardViewModelProvider).workspaces?.firstOrNull;
      if (ws != null) collegeId = ws.collegeId;
    }

    AppRoutes.push(
      context,
      CreateInterviewPage(companyId: companyId, collegeId: collegeId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardViewModelProvider);
    final interviews = state.interviewsData?.byYou ?? [];
    final isLoading = state.interviewsStatus == DashboardLoadStatus.loading;
    final hasError = state.interviewsStatus == DashboardLoadStatus.error;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interview Management'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: _openCreateInterview,
            tooltip: 'Create Interview',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(dashboardViewModelProvider.notifier)
            .loadInterviews(forceRefresh: true),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Interviews',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                FilledButton.icon(
                  onPressed: _openCreateInterview,
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: const Text('Create Interview'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isLoading && interviews.isEmpty)
              const SizedBox(height: 200, child: Center(child: LoaderWidget()))
            else if (hasError && interviews.isEmpty)
              _ErrorState(
                message: state.interviewsErrorMessage ?? 'Failed to load',
                onRetry: () => ref
                    .read(dashboardViewModelProvider.notifier)
                    .loadInterviews(forceRefresh: true),
              )
            else if (interviews.isEmpty)
              _EmptyState(onCreate: _openCreateInterview)
            else
              ...interviews.map((i) => _InterviewCard(interview: i)),
          ],
        ),
      ),
    );
  }
}

class _InterviewCard extends StatelessWidget {
  const _InterviewCard({required this.interview});

  final InterviewEntity interview;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () => AppRoutes.push(
            context,
            InterviewDetailPage(interview: interview),
          ),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
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
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    interview.title.isNotEmpty
                        ? interview.title[0].toUpperCase()
                        : 'I',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        interview.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        '${interview.role} • ${interview.interviewType}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMedium,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: interview.status == 'published'
                              ? AppColors.bgLightGreen
                              : AppColors.bgLightOrange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          interview.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: interview.status == 'published'
                                ? AppColors.success2
                                : AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  color: AppColors.textLight,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Icon(LucideIcons.calendarX, size: 64, color: AppColors.textLight),
          const SizedBox(height: 16),
          const Text(
            'No interviews yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first interview using voice or manual setup.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textMedium),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(LucideIcons.plus, size: 18),
            label: const Text('Create Interview'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Icon(LucideIcons.triangleAlert, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMedium),
          ),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/routes/app_routes.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/utils/user_role_provider.dart';
import 'package:kaarya/core/widgets/loader_widget.dart';
import 'package:kaarya/core/widgets/my_button_widget.dart';
import 'package:kaarya/core/widgets/workspace_overview_analytics_widget.dart';
import 'package:kaarya/features/colleges/presentation/view_model/college_dashboard_view_model.dart';
import 'package:kaarya/features/jobs/domain/entities/job_entity.dart';
import 'package:kaarya/features/recruiter/presentation/pages/manage_job_page.dart';
import 'package:kaarya/features/recruiter/presentation/pages/post_new_job_page.dart';
import 'package:kaarya/features/recruiter/presentation/widgets/recruiter_job_card_widget.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CollegeOverviewScreen extends ConsumerStatefulWidget {
  const CollegeOverviewScreen({super.key});

  @override
  ConsumerState<CollegeOverviewScreen> createState() =>
      _CollegeOverviewScreenState();
}

class _CollegeOverviewScreenState extends ConsumerState<CollegeOverviewScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref
          .read(collegeDashboardViewModelProvider.notifier)
          .loadWorkspaces();
      final state = ref.read(collegeDashboardViewModelProvider);
      final ws = state.selectedWorkspace ?? state.workspaces?.firstOrNull;
      if (ws != null) {
        await ref
            .read(collegeDashboardViewModelProvider.notifier)
            .loadCollegeJobs(collegeId: ws.collegeId, forceRefresh: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(collegeDashboardViewModelProvider);
    final isCollege = ref.watch(isCollegeProvider);
    if (!isCollege) return const SizedBox.shrink();

    if (state.workspacesStatus == CollegeDashboardLoadStatus.loading &&
        state.workspaces == null) {
      return const LoaderWidget();
    }

    if (state.workspaces != null && state.workspaces!.isEmpty) {
      return _EmptyCollegeState();
    }

    final workspace = state.selectedWorkspace ?? state.workspaces?.firstOrNull;
    if (workspace == null) {
      return const LoaderWidget();
    }

    if (state.collegeJobsStatus == CollegeDashboardLoadStatus.loading &&
        state.collegeJobs == null) {
      return const LoaderWidget();
    }

    final overview = ref
        .read(collegeDashboardViewModelProvider.notifier)
        .computeOverviewData();

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(collegeDashboardViewModelProvider.notifier)
            .loadWorkspaces(forceRefresh: true);
        final s = ref.read(collegeDashboardViewModelProvider);
        final ws = s.selectedWorkspace ?? s.workspaces?.firstOrNull;
        if (ws != null) {
          await ref
              .read(collegeDashboardViewModelProvider.notifier)
              .loadCollegeJobs(collegeId: ws.collegeId, forceRefresh: true);
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 430;
                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workspace.collegeName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      MyButton(
                        onPressed: () => _pushPostNewJob(context),
                        text: 'Create Job Posting',
                        icon: const Icon(
                          LucideIcons.plus,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        workspace.collegeName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    MyButton(
                      onPressed: () => _pushPostNewJob(context),
                      text: 'Create Job Posting',
                      btnWidth: 170,
                      icon: const Icon(
                        LucideIcons.plus,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            _SummaryCards(overview: overview),
            const SizedBox(height: 20),
            WorkspaceOverviewAnalyticsWidget(
              jobs: overview.jobs,
              variant: WorkspaceAnalyticsVariant.college,
            ),
            const SizedBox(height: 20),
            if (overview.workModeDistribution.any((e) => e.count > 0)) ...[
              _WorkModeSection(items: overview.workModeDistribution),
              const SizedBox(height: 20),
            ],
            if (overview.upcomingDeadlines.isNotEmpty) ...[
              _UpcomingDeadlinesSection(deadlines: overview.upcomingDeadlines),
              const SizedBox(height: 20),
            ],
            _RoleStatusSection(jobs: overview.jobs),
            const SizedBox(height: 20),
            if (overview.jobs.isNotEmpty) ...[
              const Text(
                'Recent Jobs',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              ...overview.jobs
                  .take(5)
                  .map(
                    (j) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: RecruiterJobCardWidget(
                        job: j,
                        onManageTap: () => _pushManageJob(context, j),
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  void _pushPostNewJob(BuildContext context) {
    AppRoutes.pushNoTransition(context, const PostNewJobPage());
  }

  void _pushManageJob(BuildContext context, JobEntity job) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ManageJobPage(jobId: job.id, jobTitle: job.title),
      ),
    );
  }
}

class _EmptyCollegeState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.graduationCap,
              size: 64,
              color: AppColors.textMedium,
            ),
            const SizedBox(height: 16),
            const Text(
              'No college workspace',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Contact support if you need access to your college workspace.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textLight, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.overview});

  final CollegeOverviewData overview;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatCard(
        label: 'OPEN JOBS',
        value: '${overview.openJobsCount}',
        helper: 'Live roles currently hiring',
      ),
      _StatCard(
        label: 'DRAFT JOBS',
        value: '${overview.draftJobsCount}',
        helper: 'Roles saved but not published',
      ),
      _StatCard(
        label: 'TOTAL APPLICANTS',
        value: '${overview.totalApplicants}',
        helper: 'Applicants across tracked roles',
      ),
      _StatCard(
        label: 'JOB VIEWS',
        value: '${overview.totalViews}',
        helper: 'Total visibility across roles',
      ),
      _StatCard(
        label: 'CLOSING SOON',
        value: '${overview.closingSoonCount}',
        helper: 'Open roles closing in 14 days',
      ),
    ];

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => SizedBox(width: 140, child: cards[i]),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.helper,
  });

  final String label;
  final String value;
  final String helper;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textMedium,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            helper,
            style: const TextStyle(fontSize: 10, color: AppColors.textLight),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _WorkModeSection extends StatelessWidget {
  const _WorkModeSection({required this.items});

  final List<WorkModeItem> items;

  @override
  Widget build(BuildContext context) {
    final maxCount = items.map((e) => e.count).reduce((a, b) => a > b ? a : b);
    final maxVal = maxCount > 0 ? maxCount.toDouble() : 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Work Mode Split',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      e.mode,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: e.count / maxVal,
                      backgroundColor: AppColors.bgSecondary,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${e.count}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingDeadlinesSection extends StatelessWidget {
  const _UpcomingDeadlinesSection({required this.deadlines});

  final List<UpcomingDeadlineItem> deadlines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Deadlines',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          ...deadlines
              .take(5)
              .map(
                (d) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            _formatDeadline(d.deadline),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMedium,
                            ),
                          ),
                          Text(
                            '${d.applicants} applicants',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  String _formatDeadline(String deadline) {
    final d = DateTime.tryParse(deadline);
    if (d == null) return deadline;
    return '${d.day} ${_month(d.month)} ${d.year}';
  }

  String _month(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[m - 1];
  }
}

class _RoleStatusSection extends StatelessWidget {
  const _RoleStatusSection({required this.jobs});

  final List<JobEntity> jobs;

  @override
  Widget build(BuildContext context) {
    final open = jobs.where((j) => j.status.toLowerCase() == 'open').length;
    final draft = jobs.where((j) => j.status.toLowerCase() == 'draft').length;
    final closed = jobs.where((j) => j.status.toLowerCase() == 'closed').length;
    final total = open + draft + closed;
    if (total == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Role Status Mix',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (open > 0)
                _StatusChip(
                  label: 'Open',
                  count: open,
                  color: const Color(0xFF059669),
                ),
              if (draft > 0)
                _StatusChip(
                  label: 'Draft',
                  count: draft,
                  color: AppColors.textMedium,
                ),
              if (closed > 0)
                _StatusChip(
                  label: 'Closed',
                  count: closed,
                  color: AppColors.error,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label ($count)',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

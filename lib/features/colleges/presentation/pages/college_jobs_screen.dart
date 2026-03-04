import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/routes/app_routes.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/utils/user_role_provider.dart';
import 'package:kaarya/core/widgets/loader_widget.dart';
import 'package:kaarya/core/widgets/my_button_widget.dart';
import 'package:kaarya/features/colleges/presentation/view_model/college_dashboard_view_model.dart';
import 'package:kaarya/features/jobs/domain/entities/job_entity.dart';
import 'package:kaarya/features/recruiter/presentation/pages/manage_job_page.dart';
import 'package:kaarya/features/recruiter/presentation/pages/post_new_job_page.dart';
import 'package:kaarya/features/recruiter/presentation/widgets/recruiter_job_card_widget.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CollegeJobsScreen extends ConsumerStatefulWidget {
  const CollegeJobsScreen({super.key});

  @override
  ConsumerState<CollegeJobsScreen> createState() => _CollegeJobsScreenState();
}

class _CollegeJobsScreenState extends ConsumerState<CollegeJobsScreen> {
  String _statusFilter = 'all';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(collegeDashboardViewModelProvider.notifier).loadWorkspaces();
      final state = ref.read(collegeDashboardViewModelProvider);
      final ws = state.selectedWorkspace ?? state.workspaces?.firstOrNull;
      if (ws != null) {
        await ref.read(collegeDashboardViewModelProvider.notifier).loadCollegeJobs(
              collegeId: ws.collegeId,
              forceRefresh: true,
            );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(collegeDashboardViewModelProvider);
    final workspace = state.selectedWorkspace ?? state.workspaces?.firstOrNull;
    final isCollege = ref.watch(isCollegeProvider);

    if (!isCollege) return const SizedBox.shrink();

    if (state.workspacesStatus == CollegeDashboardLoadStatus.loading &&
        state.workspaces == null) {
      return const LoaderWidget();
    }

    if (workspace == null || state.workspaces!.isEmpty) {
      return _EmptyCollegeState();
    }

    if (state.collegeJobsStatus == CollegeDashboardLoadStatus.loading &&
        state.collegeJobs == null) {
      return const LoaderWidget();
    }

    final jobs = state.collegeJobs ?? [];
    final filteredJobs = _filterJobs(jobs);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(collegeDashboardViewModelProvider.notifier).loadCollegeJobs(
              collegeId: workspace.collegeId,
              search: _searchController.text.trim().isEmpty
                  ? null
                  : _searchController.text.trim(),
              status: _statusFilter == 'all' ? null : _statusFilter,
              forceRefresh: true,
            );
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
                      const Text(
                        'College Jobs',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
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
                    const Expanded(
                      child: Text(
                        'College Jobs',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
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
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withAlpha(50)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manage Your College\'s Job Pipeline',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Track all openings for your college and post new roles visible only to your college members.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textLight,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 430;
                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search college jobs...',
                          prefixIcon: const Icon(LucideIcons.search, size: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _refreshWithFilters(workspace.collegeId),
                      ),
                      const SizedBox(height: 12),
                      MyButton(
                        onPressed: () => _refreshWithFilters(workspace.collegeId),
                        text: 'Find Job',
                        icon: const Icon(
                          LucideIcons.search,
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
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search college jobs...',
                          prefixIcon: const Icon(LucideIcons.search, size: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _refreshWithFilters(workspace.collegeId),
                      ),
                    ),
                    const SizedBox(width: 12),
                    MyButton(
                      onPressed: () => _refreshWithFilters(workspace.collegeId),
                      text: 'Find Job',
                      btnWidth: 116,
                      icon: const Icon(
                        LucideIcons.search,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildChip('All College Jobs', 'all'),
                  _buildChip('Open Jobs', 'open'),
                  _buildChip('Closed Jobs', 'closed'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (filteredJobs.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text(
                    'No jobs match your filters.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textMedium,
                    ),
                  ),
                ),
              )
            else
              ...filteredJobs.map(
                (j) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: RecruiterJobCardWidget(
                    job: j,
                    onManageTap: () => _pushManageJob(context, j),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, String value) {
    final selected = _statusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: selected ? Colors.white : AppColors.textDark,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        selected: selected,
        onSelected: (_) => setState(() => _statusFilter = value),
        showCheckmark: false,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        labelPadding: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.borderStroke,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  List<JobEntity> _filterJobs(List<JobEntity> jobs) {
    var result = jobs;

    if (_statusFilter == 'open') {
      result = result.where((j) => j.status.toLowerCase() == 'open').toList();
    } else if (_statusFilter == 'closed') {
      result = result.where((j) => j.status.toLowerCase() == 'closed').toList();
    }

    final search = _searchController.text.trim().toLowerCase();
    if (search.isNotEmpty) {
      result = result
          .where((j) =>
              j.title.toLowerCase().contains(search) ||
              j.companyName.toLowerCase().contains(search))
          .toList();
    }

    return result;
  }

  void _refreshWithFilters(String collegeId) {
    ref.read(collegeDashboardViewModelProvider.notifier).loadCollegeJobs(
          collegeId: collegeId,
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          status: _statusFilter == 'all' ? null : _statusFilter,
          forceRefresh: true,
        );
  }

  void _pushPostNewJob(BuildContext context) {
    AppRoutes.pushNoTransition(context, const PostNewJobPage());
  }

  void _pushManageJob(BuildContext context, JobEntity job) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ManageJobPage(
          jobId: job.id,
          jobTitle: job.title,
        ),
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
            Icon(LucideIcons.graduationCap, size: 64, color: AppColors.textMedium),
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

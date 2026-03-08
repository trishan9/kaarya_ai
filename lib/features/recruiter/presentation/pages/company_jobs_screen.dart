import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/routes/app_routes.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/widgets/loader_widget.dart';
import 'package:kaarya/core/widgets/my_button_widget.dart';
import 'package:kaarya/features/jobs/domain/entities/job_entity.dart';
import 'package:kaarya/features/recruiter/presentation/pages/manage_job_page.dart';
import 'package:kaarya/features/recruiter/presentation/pages/post_new_job_page.dart';
import 'package:kaarya/features/recruiter/presentation/view_model/recruiter_view_model.dart';
import 'package:kaarya/features/recruiter/presentation/widgets/recruiter_job_card_widget.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CompanyJobsScreen extends ConsumerStatefulWidget {
  const CompanyJobsScreen({super.key});

  @override
  ConsumerState<CompanyJobsScreen> createState() => _CompanyJobsScreenState();
}

class _CompanyJobsScreenState extends ConsumerState<CompanyJobsScreen> {
  String _statusFilter = 'all';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(recruiterViewModelProvider.notifier).loadWorkspaces();
      final state = ref.read(recruiterViewModelProvider);
      final ws = state.selectedWorkspace ?? state.workspaces?.firstOrNull;
      if (ws != null) {
        await ref
            .read(recruiterViewModelProvider.notifier)
            .loadCompanyJobs(
              companyId: ws.companyId,
              companyName: ws.companyName,
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
    final state = ref.watch(recruiterViewModelProvider);
    final workspace = state.selectedWorkspace ?? state.workspaces?.firstOrNull;

    if (state.workspacesStatus == RecruiterLoadStatus.loading &&
        state.workspaces == null) {
      return const LoaderWidget();
    }

    if (workspace == null || state.workspaces!.isEmpty) {
      return _EmptyWorkspaceState(onCreateJob: () => _pushPostNewJob(context));
    }

    if (state.companyJobsStatus == RecruiterLoadStatus.loading &&
        state.companyJobs == null) {
      return const LoaderWidget();
    }

    final jobs = state.companyJobs ?? [];
    final filteredJobs = _filterJobs(jobs);

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(recruiterViewModelProvider.notifier)
            .loadCompanyJobs(
              companyId: workspace.companyId,
              companyName: workspace.companyName,
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
                        'Company Jobs',
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
                        'Company Jobs',
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
                    'Manage Your Company\'s Job Pipeline',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Track all openings in your selected workspace and post new roles without leaving your dashboard.',
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
                          hintText: 'Search your company jobs...',
                          prefixIcon: const Icon(LucideIcons.search, size: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _refreshWithFilters(
                          workspace.companyId,
                          workspace.companyName,
                        ),
                      ),
                      const SizedBox(height: 12),
                      MyButton(
                        onPressed: () => _refreshWithFilters(
                          workspace.companyId,
                          workspace.companyName,
                        ),
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
                          hintText: 'Search your company jobs...',
                          prefixIcon: const Icon(LucideIcons.search, size: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _refreshWithFilters(
                          workspace.companyId,
                          workspace.companyName,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    MyButton(
                      onPressed: () => _refreshWithFilters(
                        workspace.companyId,
                        workspace.companyName,
                      ),
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
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        'All Company Jobs',
                        style: TextStyle(
                          fontSize: 13,
                          color: _statusFilter == 'all'
                              ? Colors.white
                              : AppColors.textDark,
                          fontWeight: _statusFilter == 'all'
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                      selected: _statusFilter == 'all',
                      onSelected: (_) => setState(() => _statusFilter = 'all'),
                      showCheckmark: false,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: _statusFilter == 'all'
                            ? AppColors.primary
                            : AppColors.borderStroke,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        'Open Jobs',
                        style: TextStyle(
                          fontSize: 13,
                          color: _statusFilter == 'open'
                              ? Colors.white
                              : AppColors.textDark,
                          fontWeight: _statusFilter == 'open'
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                      selected: _statusFilter == 'open',
                      onSelected: (_) => setState(() => _statusFilter = 'open'),
                      showCheckmark: false,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: _statusFilter == 'open'
                            ? AppColors.primary
                            : AppColors.borderStroke,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        'Closed Jobs',
                        style: TextStyle(
                          fontSize: 13,
                          color: _statusFilter == 'closed'
                              ? Colors.white
                              : AppColors.textDark,
                          fontWeight: _statusFilter == 'closed'
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                      selected: _statusFilter == 'closed',
                      onSelected: (_) =>
                          setState(() => _statusFilter = 'closed'),
                      showCheckmark: false,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: _statusFilter == 'closed'
                            ? AppColors.primary
                            : AppColors.borderStroke,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
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
                    style: TextStyle(fontSize: 16, color: AppColors.textMedium),
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
          .where(
            (j) =>
                j.title.toLowerCase().contains(search) ||
                j.companyName.toLowerCase().contains(search),
          )
          .toList();
    }

    return result;
  }

  void _refreshWithFilters(String companyId, String companyName) {
    ref
        .read(recruiterViewModelProvider.notifier)
        .loadCompanyJobs(
          companyId: companyId,
          companyName: companyName,
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
        builder: (_) => ManageJobPage(jobId: job.id, jobTitle: job.title),
      ),
    );
  }
}

class _EmptyWorkspaceState extends StatelessWidget {
  const _EmptyWorkspaceState({required this.onCreateJob});

  final VoidCallback onCreateJob;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.building2, size: 64, color: AppColors.textMedium),
            const SizedBox(height: 16),
            const Text(
              'No workspace yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Join a company workspace to start posting jobs and managing applicants.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textLight, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

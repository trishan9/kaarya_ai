import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:kaarya/app/routes/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/widgets/job_card_widget.dart';
import 'package:kaarya/core/widgets/loader_widget.dart';
import 'package:kaarya/core/widgets/my_button_widget.dart';
import 'package:kaarya/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:kaarya/features/jobs/domain/entities/job_entity.dart';
import 'package:kaarya/features/jobs/presentation/pages/apply_to_job_page.dart';
import 'package:kaarya/features/jobs/presentation/view_model/jobs_view_model.dart';
import 'package:kaarya/features/recruiter/presentation/pages/applicants_pipeline_page.dart';
import 'package:kaarya/features/recruiter/presentation/pages/post_new_job_page.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class JobDetailPage extends ConsumerStatefulWidget {
  final String jobId;
  final String? jobTitle;
  final bool isRecruiterManageView;

  const JobDetailPage({
    super.key,
    required this.jobId,
    this.jobTitle,
    this.isRecruiterManageView = false,
  });

  @override
  ConsumerState<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends ConsumerState<JobDetailPage> {
  bool _descExpanded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(jobsViewModelProvider.notifier).loadJobDetail(widget.jobId);
      ref.read(jobsViewModelProvider.notifier).recordJobView(widget.jobId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobsViewModelProvider);
    final raw = state.jobDetail;
    final job = (raw != null && raw.id == widget.jobId) ? raw : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(job?.title ?? widget.jobTitle ?? 'Job Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildBody(state, job),
      bottomNavigationBar: job != null ? _buildBottomBar(job) : null,
    );
  }

  Widget _buildBody(JobsState state, JobDetailEntity? job) {
    if (job == null &&
        !state.jobDetailLoading &&
        state.jobDetailError == null) {
      return const LoaderWidget();
    }
    if (state.jobDetailLoading && job == null) {
      return const LoaderWidget();
    }
    if (state.jobDetailError != null && job == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.jobDetailError ?? 'Failed to load job details'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref
                  .read(jobsViewModelProvider.notifier)
                  .loadJobDetail(widget.jobId),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (job == null) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(jobsViewModelProvider.notifier).loadJobDetail(widget.jobId),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(job),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHighlights(job),
                  const SizedBox(height: 20),
                  _buildSalary(job),
                  const SizedBox(height: 24),
                  _buildDescription(job),
                  if (job.company != null) ...[
                    const SizedBox(height: 24),
                    _buildCompanySection(job.company!),
                  ],
                  if (!widget.isRecruiterManageView &&
                      _similarJobsForDisplay(job).isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSimilarJobs(job),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(JobDetailEntity job) {
    final daysAgo = _daysAgo(job.createdAt);
    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF003D6E), Color(0xFF0471B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildCompanyAvatar(job),
                      const Spacer(),
                      _actionIcon(LucideIcons.bookmark300, () {}),
                      const SizedBox(width: 8),
                      _actionIcon(LucideIcons.share2300, () {}),
                      const SizedBox(width: 8),
                      _actionIcon(LucideIcons.ellipsis300, () {}),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '$daysAgo  ·  ${job.applicationsCount} applicants',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    job.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${job.companyName}  ·  ${job.location}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyAvatar(JobDetailEntity job) {
    if (job.companyLogo != null && job.companyLogo!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          job.companyLogo!,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackAvatar(job.companyName),
        ),
      );
    }
    return _fallbackAvatar(job.companyName);
  }

  Widget _fallbackAvatar(String name) {
    return Container(
      width: 50,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(40),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'C',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _actionIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(30),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }

  Widget _buildHighlights(JobDetailEntity job) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _highlightChip('Level', job.level),
        _highlightChip('Experience', job.experience),
        _highlightChip('Job Type', job.employmentType),
        _highlightChip('Work Type', job.workMode.replaceAll('_', ' ')),
      ],
    );
  }

  Widget _highlightChip(String label, String value) {
    return Container(
      width: (MediaQuery.of(context).size.width - 52) / 2,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.bgTertiary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textMedium,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalary(JobDetailEntity job) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.bgTertiary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderStroke2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.wallet, size: 14, color: AppColors.textMedium),
              const SizedBox(width: 4),
              const Text(
                'Salary Range',
                style: TextStyle(color: AppColors.textMedium, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            job.salaryRange,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(JobDetailEntity job) {
    final htmlStyle = {
      "body": Style(
        margin: Margins.zero,
        padding: HtmlPaddings.zero,
        fontSize: FontSize(14),
        color: AppColors.textLight,
        lineHeight: const LineHeight(1.7),
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Job Description',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        if (job.description.isNotEmpty) ...[
          AnimatedCrossFade(
            firstChild: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ClipRect(
                child: Html(data: job.description, style: htmlStyle),
              ),
            ),
            secondChild: Html(data: job.description, style: htmlStyle),
            crossFadeState: _descExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _descExpanded = !_descExpanded),
            child: Text(
              _descExpanded ? 'Show Less' : 'Show More',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ] else ...[
          const Text(
            'No description provided.',
            style: TextStyle(color: AppColors.textLight),
          ),
        ],
        if (job.requirements.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 16),
          Text(
            'Qualifications',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...job.requirements.map(
            (req) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6, right: 8),
                    child: Icon(
                      Icons.circle,
                      size: 6,
                      color: AppColors.textMedium,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      req,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompanySection(CompanyDetailEntity company) {
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
          Text(
            'About Company',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (company.logo != null && company.logo!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    company.logo!,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallbackAvatar(company.name),
                  ),
                )
              else
                _fallbackAvatar(company.name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    if (company.location != null)
                      Text(
                        company.location!,
                        style: const TextStyle(
                          color: AppColors.textMedium,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (company.industry != null || company.teamSize != null) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                if (company.industry != null) _infoPill(company.industry!),
                if (company.teamSize != null) _infoPill(company.teamSize!),
              ],
            ),
          ],
          if (company.description != null &&
              company.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              company.description!,
              style: const TextStyle(color: AppColors.textLight, height: 1.5),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: AppColors.primary),
      ),
    );
  }

  List<JobEntity> _similarJobsForDisplay(JobDetailEntity job) {
    if (widget.isRecruiterManageView) {
      return job.similarJobs
          .where((j) =>
              j.companyName.toLowerCase() == job.companyName.toLowerCase())
          .toList();
    }
    return job.similarJobs;
  }

  Widget _buildSimilarJobs(JobDetailEntity job) {
    final similarJobs = _similarJobsForDisplay(job);
    if (similarJobs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Similar Jobs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...similarJobs.map(
          (j) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: JobCardWidget(
              job: j,
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) =>
                        JobDetailPage(jobId: j.id, jobTitle: j.title),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(JobDetailEntity job) {
    if (widget.isRecruiterManageView) {
      return Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: MyButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ApplicantsPipelinePage(
                        jobId: job.id,
                        jobTitle: job.title,
                      ),
                    ),
                  );
                },
                text: 'Manage Applicants',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await AppRoutes.pushNoTransition(
                        context,
                        PostNewJobPage(jobId: job.id, job: job),
                      );
                      if (context.mounted) {
                        ref.read(jobsViewModelProvider.notifier).loadJobDetail(widget.jobId);
                      }
                    },
                    icon: const Icon(LucideIcons.pencil, size: 18),
                    label: const Text('Edit Job'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Back to Jobs'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          onPressed: job.hasApplied
              ? null
              : () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ApplyToJobPage(
                        jobId: job.id,
                        jobTitle: job.title,
                        companyName: job.companyName,
                        companyLogo: job.companyLogo,
                      ),
                    ),
                  );
                },
          child: Text(job.hasApplied ? 'Already Applied' : 'Apply Now'),
        ),
      ),
    );
  }

  String _daysAgo(String createdAt) {
    final date = DateTime.tryParse(createdAt);
    if (date == null) return '';
    final diff = DateTime.now().difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return '1 day ago';
    return '$diff days ago';
  }
}

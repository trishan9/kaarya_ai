import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/routes/app_routes.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/widgets/loader_widget.dart';
import 'package:kaarya/core/widgets/notifications_widget.dart';
import 'package:kaarya/features/applications/domain/entities/application_entity.dart';
import 'package:kaarya/features/applications/presentation/state/application_state.dart';
import 'package:kaarya/features/applications/presentation/view_model/application_view_model.dart';
import 'package:kaarya/features/jobs/presentation/pages/job_detail_page.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

typedef _StatusStyle = ({String label, Color color, Color bg, Color border});

_StatusStyle _statusStyle(String status) {
  switch (status) {
    case 'applied':
      return (
        label: 'Waiting for Approval',
        color: const Color(0xFFA96F10),
        bg: const Color(0xFFFFF9EF),
        border: const Color(0xFFF0BF62),
      );
    case 'reviewing':
      return (
        label: 'Under Review',
        color: const Color(0xFF1C7AB8),
        bg: const Color(0xFFEFF8FF),
        border: const Color(0xFF4BA3DA),
      );
    case 'shortlisted':
      return (
        label: 'Shortlisted',
        color: const Color(0xFF3F8A28),
        bg: const Color(0xFFF3FBEF),
        border: const Color(0xFF80B86B),
      );
    case 'interview_scheduled':
    case 'interview':
      return (
        label: 'Interview Invited',
        color: const Color(0xFF1C7AB8),
        bg: const Color(0xFFEFF8FF),
        border: const Color(0xFF4BA3DA),
      );
    case 'accepted':
    case 'offered':
      return (
        label: 'Accepted',
        color: AppColors.success,
        bg: AppColors.bgLightGreen,
        border: const Color(0xFF80B86B),
      );
    case 'rejected':
      return (
        label: 'Rejected',
        color: const Color(0xFFD84A3A),
        bg: const Color(0xFFFFF6F5),
        border: const Color(0xFFF2A39C),
      );
    case 'withdrawn':
      return (
        label: 'Withdrawn',
        color: AppColors.textMedium,
        bg: AppColors.bgTertiary,
        border: AppColors.borderStroke,
      );
    default:
      return (
        label: 'Applied',
        color: AppColors.textMedium,
        bg: AppColors.bgTertiary,
        border: AppColors.borderStroke,
      );
  }
}

const _timelineSteps = [
  (
    icon: LucideIcons.send,
    label: 'Application Submitted',
    desc: 'Your application was sent to the employer',
  ),
  (
    icon: LucideIcons.search,
    label: 'Application Screening',
    desc: 'Recruiter is reviewing your application',
  ),
  (
    icon: LucideIcons.userRound,
    label: 'HR Interview',
    desc: 'Initial HR interview with the team',
  ),
  (
    icon: LucideIcons.clipboardList,
    label: 'Assessment',
    desc: 'Technical or skills assessment',
  ),
  (
    icon: LucideIcons.users,
    label: 'Second Interview',
    desc: 'Follow-up interview with the team',
  ),
  (
    icon: LucideIcons.fileText,
    label: 'Offering',
    desc: 'Job offer is being prepared',
  ),
  (
    icon: LucideIcons.circleCheck,
    label: 'Accepted',
    desc: 'Congratulations — you got the job!',
  ),
];

int _currentStepIndex(String status) {
  switch (status) {
    case 'applied':
      return 0;
    case 'reviewing':
    case 'shortlisted':
      return 1;
    case 'interview_scheduled':
    case 'interview':
      return 2;
    case 'accepted':
    case 'offered':
      return 6;
    case 'rejected':
    case 'withdrawn':
      return 1;
    default:
      return 0;
  }
}

bool _isTerminalNegative(String status) =>
    status == 'rejected' || status == 'withdrawn';

class MyApplicationsPage extends ConsumerStatefulWidget {
  const MyApplicationsPage({super.key});

  @override
  ConsumerState<MyApplicationsPage> createState() => _MyApplicationsPageState();
}

class _MyApplicationsPageState extends ConsumerState<MyApplicationsPage> {
  int _selectedTab = 0;

  static const _tabs = [
    'All',
    'Screening',
    'Interview',
    'Offering',
    'Rejected',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          ref.read(applicationViewModelProvider.notifier).loadMyApplications(),
    );
  }

  Future<void> _refresh() => ref
      .read(applicationViewModelProvider.notifier)
      .loadMyApplications(forceRefresh: true);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(applicationViewModelProvider);
    final data = state.applicationsData;
    final isLoading = state.applicationsStatus == ApplicationLoadStatus.loading;
    final isError = state.applicationsStatus == ApplicationLoadStatus.error;

    final apps = data?.applications ?? [];
    final filtered = _filtered(apps);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Applications',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 14),
            child: NotificationsWidget(),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            _HeroBanner(data: data),
            const SizedBox(height: 14),
            _TabBar(
              tabs: _tabs,
              selected: _selectedTab,
              counts: _tabCounts(apps),
              onSelected: (i) => setState(() => _selectedTab = i),
            ),
            const SizedBox(height: 14),
            if (isLoading && data == null)
              const SizedBox(height: 260, child: LoaderWidget())
            else if (isError && data == null)
              _ErrorBlock(
                message:
                    state.applicationsErrorMessage ??
                    'Failed to load applications',
                onRetry: _refresh,
              )
            else
              ..._buildList(context, filtered),
          ],
        ),
      ),
    );
  }

  List<ApplicationEntity> _filtered(List<ApplicationEntity> apps) {
    if (_selectedTab == 0) return apps;
    const tabStatuses = [
      <String>[],
      ['applied', 'reviewing', 'shortlisted'],
      ['interview_scheduled', 'interview'],
      ['accepted', 'offered'],
      ['rejected', 'withdrawn'],
    ];
    final statuses = tabStatuses[_selectedTab];
    return apps.where((a) => statuses.contains(a.status)).toList();
  }

  List<int> _tabCounts(List<ApplicationEntity> apps) {
    return [
      apps.length,
      apps
          .where(
            (a) => ['applied', 'reviewing', 'shortlisted'].contains(a.status),
          )
          .length,
      apps
          .where((a) => ['interview_scheduled', 'interview'].contains(a.status))
          .length,
      apps.where((a) => ['accepted', 'offered'].contains(a.status)).length,
      apps.where((a) => ['rejected', 'withdrawn'].contains(a.status)).length,
    ];
  }

  List<Widget> _buildList(BuildContext context, List<ApplicationEntity> apps) {
    if (apps.isEmpty) {
      return [_EmptyState(tab: _tabs[_selectedTab])];
    }
    return apps.map((app) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _ApplicationCard(
          app: app,
          onTrack: () => _showTracking(context, app),
          onViewJob: () => AppRoutes.push(
            context,
            JobDetailPage(jobId: app.jobId, jobTitle: app.jobTitle),
          ),
        ),
      );
    }).toList();
  }

  void _showTracking(BuildContext context, ApplicationEntity app) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TrackingSheet(app: app),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final ApplicationsListEntity? data;
  const _HeroBanner({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF003D6E), Color(0xFF0471B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 110,
              height: 110,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      LucideIcons.briefcase,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Track Your Applications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Monitor every stage from screening to final decision.',
                  style: TextStyle(
                    color: Colors.white.withAlpha(180),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _StatBox(
                      icon: LucideIcons.send,
                      label: 'Total',
                      value: '${data?.totalSubmissions ?? 0}',
                    ),
                    const SizedBox(width: 8),
                    _StatBox(
                      icon: LucideIcons.loader,
                      label: 'In Progress',
                      value: '${data?.inProgressCount ?? 0}',
                    ),
                    const SizedBox(width: 8),
                    _StatBox(
                      icon: LucideIcons.userRound,
                      label: 'Interview',
                      value: '${data?.interviewCount ?? 0}',
                    ),
                    const SizedBox(width: 8),
                    _StatBox(
                      icon: LucideIcons.circleCheck,
                      label: 'Accepted',
                      value: '${data?.acceptedCount ?? 0}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatBox({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(25),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withAlpha(35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 13, color: Colors.white.withAlpha(180)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withAlpha(153),
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final List<String> tabs;
  final int selected;
  final List<int> counts;
  final ValueChanged<int> onSelected;
  const _TabBar({
    required this.tabs,
    required this.selected,
    required this.counts,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, i) {
          final isSelected = selected == i;
          final count = counts[i];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelected(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.borderStroke,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tabs[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.textMedium,
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withAlpha(50)
                              : AppColors.bgSecondary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final ApplicationEntity app;
  final VoidCallback onTrack;
  final VoidCallback onViewJob;
  const _ApplicationCard({
    required this.app,
    required this.onTrack,
    required this.onViewJob,
  });

  @override
  Widget build(BuildContext context) {
    final style = _statusStyle(app.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderStroke2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: style.border,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CompanyAvatar(
                      name: app.companyName,
                      logoUrl: app.companyLogo,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  app.jobTitle,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: style.bg,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: style.border),
                                ),
                                child: Text(
                                  style.label,
                                  style: TextStyle(
                                    color: style.color,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            app.companyName,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMedium,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _Pill(icon: LucideIcons.mapPin, text: app.location),
                    _Pill(
                      icon: LucideIcons.briefcase,
                      text: app.employmentType,
                    ),
                    _Pill(icon: LucideIcons.monitor, text: app.workMode),
                    _Pill(
                      icon: LucideIcons.calendar,
                      text: _fmtDate(app.appliedAt),
                    ),
                    if (app.salaryRange.isNotEmpty && app.salaryRange != '—')
                      _Pill(
                        icon: LucideIcons.indianRupee,
                        text: app.salaryRange,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF5F5F5)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onTrack,
                        icon: const Icon(LucideIcons.gitBranch, size: 14),
                        label: const Text('Track'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onViewJob,
                        icon: const Icon(LucideIcons.externalLink, size: 14),
                        label: const Text('View Job'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textDark,
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(String date) {
    final d = DateTime.tryParse(date)?.toLocal();
    if (d == null) return '—';
    const m = [
      '',
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
    return '${m[d.month]} ${d.day}, ${d.year}';
  }
}

class _CompanyAvatar extends StatelessWidget {
  final String name;
  final String? logoUrl;
  const _CompanyAvatar({required this.name, this.logoUrl});

  @override
  Widget build(BuildContext context) {
    if (logoUrl != null && logoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          logoUrl!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join()
        : 'C';
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Pill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 170),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.bgLight,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.borderStroke),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: AppColors.textLight),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMedium,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackingSheet extends StatelessWidget {
  final ApplicationEntity app;
  const _TrackingSheet({required this.app});

  @override
  Widget build(BuildContext context) {
    final style = _statusStyle(app.status);
    final currentStep = _currentStepIndex(app.status);
    final isNegative = _isTerminalNegative(app.status);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderStroke2,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _CompanyAvatar(
                      name: app.companyName,
                      logoUrl: app.companyLogo,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app.jobTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            app.companyName,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: style.bg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: style.border),
                      ),
                      child: Text(
                        style.label,
                        style: TextStyle(
                          color: style.color,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: AppColors.borderStroke),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.bgSecondary,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: const Icon(
                            LucideIcons.gitBranch,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Application Timeline',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Padding(
                      padding: EdgeInsets.only(left: 38),
                      child: Text(
                        'Your progress through the hiring pipeline',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _Timeline(
                      steps: _timelineSteps,
                      currentStep: currentStep,
                      isNegative: isNegative,
                      appliedAt: app.appliedAt,
                      updatedAt: app.updatedAt,
                      nextStep: app.nextStep,
                    ),
                    const SizedBox(height: 24),
                    _InfoCard(app: app, style: style),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Timeline extends StatelessWidget {
  final List<({IconData icon, String label, String desc})> steps;
  final int currentStep;
  final bool isNegative;
  final String appliedAt;
  final String updatedAt;
  final String? nextStep;

  const _Timeline({
    required this.steps,
    required this.currentStep,
    required this.isNegative,
    required this.appliedAt,
    required this.updatedAt,
    this.nextStep,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (i) {
        final step = steps[i];
        final isLast = i == steps.length - 1;

        final isReached = i <= currentStep;
        final isCurrent = i == currentStep;
        final isRejectedStep = isCurrent && isNegative;

        final Color circleColor;
        final Color circleBg;
        final Color connectorColor;
        final Color textColor;
        final IconData stepIcon;

        if (isRejectedStep) {
          circleColor = const Color(0xFFD84A3A);
          circleBg = const Color(0xFFFFF6F5);
          connectorColor = AppColors.borderStroke;
          textColor = const Color(0xFFD84A3A);
          stepIcon = LucideIcons.x;
        } else if (isCurrent) {
          circleColor = AppColors.primary;
          circleBg = const Color(0xFFEFF8FF);
          connectorColor = AppColors.borderStroke;
          textColor = AppColors.primary;
          stepIcon = step.icon;
        } else if (isReached) {
          circleColor = AppColors.primary;
          circleBg = AppColors.bgSecondary;
          connectorColor = AppColors.primary;
          textColor = AppColors.textDark;
          stepIcon = LucideIcons.check;
        } else {
          circleColor = AppColors.borderStroke2;
          circleBg = AppColors.bgLight;
          connectorColor = AppColors.borderStroke;
          textColor = AppColors.textLight;
          stepIcon = step.icon;
        }

        String? dateLabel;
        if (i == 0 && isReached) dateLabel = _fmtDate(appliedAt);
        if (isCurrent && i > 0) dateLabel = _fmtDate(updatedAt);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: circleBg,
                        border: Border.all(
                          color: circleColor,
                          width: isCurrent ? 2 : 1.5,
                        ),
                      ),
                      child: Icon(stepIcon, size: 14, color: circleColor),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: connectorColor,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              step.label,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isCurrent
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ),
                          if (isCurrent) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isRejectedStep
                                    ? const Color(0xFFFFF6F5)
                                    : AppColors.bgSecondary,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isRejectedStep
                                      ? const Color(0xFFF2A39C)
                                      : const Color(0xFF4BA3DA),
                                ),
                              ),
                              child: Text(
                                isRejectedStep ? 'Stopped here' : 'Current',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isRejectedStep
                                      ? const Color(0xFFD84A3A)
                                      : const Color(0xFF1C7AB8),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isRejectedStep
                            ? 'Your application was not moved forward.'
                            : step.desc,
                        style: TextStyle(
                          fontSize: 12,
                          color: isReached
                              ? AppColors.textMedium
                              : AppColors.textLight,
                        ),
                      ),
                      if (dateLabel != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.clock,
                              size: 11,
                              color: isRejectedStep
                                  ? const Color(0xFFD84A3A)
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dateLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isRejectedStep
                                    ? const Color(0xFFD84A3A)
                                    : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (isCurrent && !isRejectedStep && nextStep != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.arrowRight,
                              size: 11,
                              color: AppColors.textLight,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Next: $nextStep',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  String _fmtDate(String date) {
    final d = DateTime.tryParse(date)?.toLocal();
    if (d == null) return '';
    const m = [
      '',
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
    return '${m[d.month]} ${d.day}, ${d.year}';
  }
}

class _InfoCard extends StatelessWidget {
  final ApplicationEntity app;
  final _StatusStyle style;
  const _InfoCard({required this.app, required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Application Details',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          _row(LucideIcons.calendar, 'Applied on', _fmtDate(app.appliedAt)),
          _row(LucideIcons.refreshCw, 'Last updated', _fmtDate(app.updatedAt)),
          _row(LucideIcons.briefcase, 'Type', app.employmentType),
          _row(LucideIcons.monitor, 'Work mode', app.workMode),
          _row(LucideIcons.mapPin, 'Location', app.location),
          if (app.salaryRange.isNotEmpty && app.salaryRange != '—')
            _row(LucideIcons.indianRupee, 'Compensation', app.salaryRange),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Icon(icon, size: 13, color: AppColors.textLight),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(fontSize: 12, color: AppColors.textLight),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(String date) {
    final d = DateTime.tryParse(date)?.toLocal();
    if (d == null) return '—';
    const m = [
      '',
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
    return '${m[d.month]} ${d.day}, ${d.year}';
  }
}

class _EmptyState extends StatelessWidget {
  final String tab;
  const _EmptyState({required this.tab});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.bgSecondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.briefcase,
                size: 30,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No applications found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your $tab applications will appear here.',
              style: const TextStyle(fontSize: 13, color: AppColors.textMedium),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBlock({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            const Icon(
              LucideIcons.circleAlert,
              size: 36,
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(color: AppColors.textMedium, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw, size: 14),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/widgets/loader_widget.dart';
import 'package:kaarya/core/widgets/notifications_widget.dart';
import 'package:kaarya/features/applications/domain/entities/application_entity.dart';
import 'package:kaarya/features/jobs/presentation/pages/job_detail_page.dart';
import 'package:kaarya/features/dashboard/presentation/state/dashboard_state.dart';
import 'package:kaarya/features/dashboard/presentation/view_model/dashboard_view_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MyApplicationsPage extends ConsumerStatefulWidget {
  const MyApplicationsPage({super.key});

  @override
  ConsumerState<MyApplicationsPage> createState() => _MyApplicationsPageState();
}

class _MyApplicationsPageState extends ConsumerState<MyApplicationsPage> {
  int _selectedTab = 0;
  static const _tabs = [
    'All Applications',
    'Screening',
    'Interview',
    'Offering',
    'Rejected',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(dashboardViewModelProvider.notifier).loadMyApplications(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardViewModelProvider);
    final data = state.applicationsData;
    final status = state.applicationsStatus;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 14),
            child: NotificationsWidget(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(dashboardViewModelProvider.notifier)
            .loadMyApplications(forceRefresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _buildHero(data),
            const SizedBox(height: 16),
            _buildTabs(),
            const SizedBox(height: 14),
            if (status == DashboardLoadStatus.loading && data == null)
              const SizedBox(height: 200, child: LoaderWidget())
            else if (status == DashboardLoadStatus.error && data == null)
              _ErrorBlock(
                message:
                    state.applicationsErrorMessage ??
                    'Failed to load applications',
                onRetry: () => ref
                    .read(dashboardViewModelProvider.notifier)
                    .loadMyApplications(forceRefresh: true),
              )
            else
              ..._buildList(_filtered(data?.applications ?? [])),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(ApplicationsListEntity? data) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Track Your Job Applications',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Monitor every stage of your applications, from screening to interview and final decision.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _statBox('Submissions', '${data?.totalSubmissions ?? 0}'),
                    const SizedBox(width: 8),
                    _statBox('In Progress', '${data?.inProgressCount ?? 0}'),
                    const SizedBox(width: 8),
                    _statBox('Interview', '${data?.interviewCount ?? 0}'),
                    const SizedBox(width: 8),
                    _statBox('Accepted', '${data?.acceptedCount ?? 0}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(30),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withAlpha(40)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final selected = _selectedTab == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                _tabs[index],
                style: TextStyle(
                  fontSize: 13,
                  color: selected ? Colors.white : AppColors.textDark,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              selected: selected,
              showCheckmark: false,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              labelPadding: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              side: BorderSide(
                color: selected ? AppColors.primary : const Color(0xFFE0E0E0),
              ),
              onSelected: (_) => setState(() => _selectedTab = index),
            ),
          );
        },
      ),
    );
  }

  List<ApplicationEntity> _filtered(List<ApplicationEntity> apps) {
    if (_selectedTab == 0) return apps;
    final statusMap = {
      1: ['reviewing', 'shortlisted'],
      2: ['interview_scheduled', 'interview'],
      3: ['accepted', 'offered'],
      4: ['rejected'],
    };
    final statuses = statusMap[_selectedTab] ?? [];
    return apps.where((a) => statuses.contains(a.status)).toList();
  }

  List<Widget> _buildList(List<ApplicationEntity> apps) {
    if (apps.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 40),
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
                    size: 32,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'No applications found',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Applications in this category will appear here.',
                  style: TextStyle(fontSize: 14, color: AppColors.textMedium),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ];
    }
    return apps.map((app) => _applicationCard(app)).toList();
  }

  Widget _applicationCard(ApplicationEntity app) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _companyAvatar(app),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.jobTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${app.companyName}  ·  ${app.location}',
                      style: const TextStyle(
                        color: AppColors.textMedium,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _statusBadge(app.status),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _pill(LucideIcons.calendar300, _formatDate(app.appliedAt)),
              _pill(LucideIcons.briefcase300, app.employmentType),
              _pill(LucideIcons.mapPin300, app.workMode),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            app.salaryRange,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => JobDetailPage(
                        jobId: app.jobId,
                        jobTitle: app.jobTitle,
                      ),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text('View Job'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _companyAvatar(ApplicationEntity app) {
    if (app.companyLogo != null && app.companyLogo!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          app.companyLogo!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(app.companyName),
        ),
      );
    }
    return _fallback(app.companyName);
  }

  Widget _fallback(String name) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'C',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final (label, color, bg) = _statusStyle(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  (String, Color, Color) _statusStyle(String status) {
    switch (status) {
      case 'applied':
        return (
          'Waiting for Approval',
          AppColors.warning,
          AppColors.bgLightOrange,
        );
      case 'reviewing':
        return ('Reviewing', AppColors.primary, AppColors.bgSecondary);
      case 'shortlisted':
        return ('Shortlisted', const Color(0xFF059669), AppColors.bgLightGreen);
      case 'interview_scheduled':
      case 'interview':
        return ('Interview Invited', AppColors.primary, AppColors.bgSecondary);
      case 'accepted':
      case 'offered':
        return ('Accepted', AppColors.success, AppColors.bgLightGreen);
      case 'rejected':
        return ('Rejected', AppColors.error, const Color(0xFFFFF1F2));
      default:
        return ('Applied', AppColors.textMedium, AppColors.bgTertiary);
    }
  }

  Widget _pill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textLight),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    final d = DateTime.tryParse(date)?.toLocal();
    if (d == null) return '-';
    final months = [
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
    return '${months[d.month]} ${d.day}, ${d.year}';
  }
}

class _ErrorBlock extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBlock({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Text(
            message,
            style: const TextStyle(color: AppColors.textMedium),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

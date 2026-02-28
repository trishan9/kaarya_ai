import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kaarya/app/routes/app_routes.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/services/storage/user_session_service.dart';
import 'package:kaarya/core/utils/navigation_provider.dart';
import 'package:kaarya/core/utils/user_role_provider.dart';
import 'package:kaarya/features/colleges/presentation/view_model/college_dashboard_view_model.dart';
import 'package:kaarya/features/dashboard/presentation/pages/my_applications_page.dart';
import 'package:kaarya/features/dashboard/presentation/state/dashboard_state.dart';
import 'package:kaarya/features/dashboard/presentation/view_model/dashboard_view_model.dart';
import 'package:kaarya/features/recruiter/presentation/view_model/recruiter_view_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum _NotificationKind { interview, deadline, application, workspace }

class _AppNotificationItem {
  const _AppNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timeLabel,
    required this.kind,
    this.emphasis,
  });

  final String id;
  final String title;
  final String message;
  final String timeLabel;
  final _NotificationKind kind;
  final String? emphasis;
}

final notificationReadIdsProvider =
    NotifierProvider<_NotificationReadIdsNotifier, Set<String>>(
      _NotificationReadIdsNotifier.new,
    );

class _NotificationReadIdsNotifier extends Notifier<Set<String>> {
  static const _key = 'notification_read_ids_v1';

  @override
  Set<String> build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return {...?prefs.getStringList(_key)};
  }

  Future<void> markRead(String id) async {
    if (state.contains(id)) {
      return;
    }
    state = {...state, id};
    await _persist();
  }

  Future<void> markAllRead(Iterable<String> ids) async {
    state = {...state, ...ids};
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setStringList(_key, state.toList());
  }
}

final appNotificationItemsProvider = Provider<List<_AppNotificationItem>>((
  ref,
) {
  final isRecruiter = ref.watch(isRecruiterProvider);
  final isCollege = ref.watch(isCollegeProvider);

  if (isRecruiter) {
    return _buildRecruiterNotifications(ref);
  }
  if (isCollege) {
    return _buildCollegeNotifications(ref);
  }
  return _buildCandidateNotifications(ref);
});

final notificationPanelLoadingProvider = Provider<bool>((ref) {
  final isRecruiter = ref.watch(isRecruiterProvider);
  final isCollege = ref.watch(isCollegeProvider);

  if (isRecruiter) {
    final state = ref.watch(recruiterViewModelProvider);
    final waitingForWorkspaces =
        state.workspaces == null &&
        state.workspacesStatus == RecruiterLoadStatus.loading;
    final waitingForJobs =
        state.selectedWorkspace != null &&
        state.companyJobs == null &&
        state.companyJobsStatus == RecruiterLoadStatus.loading;
    return waitingForWorkspaces || waitingForJobs;
  }

  if (isCollege) {
    final state = ref.watch(collegeDashboardViewModelProvider);
    final waitingForWorkspaces =
        state.workspaces == null &&
        state.workspacesStatus == CollegeDashboardLoadStatus.loading;
    final waitingForJobs =
        state.selectedWorkspace != null &&
        state.collegeJobs == null &&
        state.collegeJobsStatus == CollegeDashboardLoadStatus.loading;
    return waitingForWorkspaces || waitingForJobs;
  }

  final state = ref.watch(dashboardViewModelProvider);
  final waitingForOverview =
      state.overviewData == null &&
      state.overviewStatus == DashboardLoadStatus.loading;
  final waitingForApplications =
      state.applicationsData == null &&
      state.applicationsStatus == DashboardLoadStatus.loading;
  return waitingForOverview || waitingForApplications;
});

List<_AppNotificationItem> _buildCandidateNotifications(Ref ref) {
  final dashboardState = ref.watch(dashboardViewModelProvider);
  final overview = dashboardState.overviewData;
  final applications =
      dashboardState.applicationsData?.applications ?? const [];

  final items = <_AppNotificationItem>[];
  final now = DateTime.now();

  final invitation = overview?.invitation;
  if (invitation != null) {
    final scheduled = DateTime.tryParse(invitation.interviewScheduledAt ?? '');
    items.add(
      _AppNotificationItem(
        id: 'candidate-invite-${invitation.interviewScheduledAt ?? invitation.companyName ?? invitation.title}',
        title: invitation.title,
        message: invitation.description,
        timeLabel: scheduled == null
            ? 'Upcoming'
            : _relativeTime(scheduled, now: now),
        kind: _NotificationKind.interview,
        emphasis: invitation.companyName,
      ),
    );
  }

  final deadlineJob = overview?.deadlineJob;
  final deadline = DateTime.tryParse(deadlineJob?.deadline ?? '');
  if (deadlineJob != null &&
      deadline != null &&
      !deadline.isBefore(now) &&
      deadline.difference(now).inDays <= 14) {
    items.add(
      _AppNotificationItem(
        id: 'candidate-deadline-${deadlineJob.id}-${deadlineJob.deadline}',
        title: 'Application deadline approaching',
        message:
            '${deadlineJob.title} at ${deadlineJob.companyName} closes ${_deadlineLabel(deadline, now)}.',
        timeLabel: _relativeTime(deadline, now: now),
        kind: _NotificationKind.deadline,
        emphasis: deadlineJob.companyName,
      ),
    );
  }

  final notableApplications =
      applications
          .where(
            (app) => const {
              'shortlisted',
              'interview_scheduled',
              'interview',
              'accepted',
              'offered',
              'rejected',
            }.contains(app.status.toLowerCase()),
          )
          .toList()
        ..sort((a, b) {
          final left =
              DateTime.tryParse(a.updatedAt) ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final right =
              DateTime.tryParse(b.updatedAt) ??
              DateTime.fromMillisecondsSinceEpoch(0);
          return right.compareTo(left);
        });

  for (final app in notableApplications.take(4)) {
    final updatedAt = DateTime.tryParse(app.updatedAt) ?? now;
    items.add(
      _AppNotificationItem(
        id: 'candidate-app-${app.id}-${app.status}-${app.updatedAt}',
        title: _applicationTitle(app.status),
        message: '${app.jobTitle} at ${app.companyName}.',
        timeLabel: _relativeTime(updatedAt, now: now),
        kind: _NotificationKind.application,
        emphasis: app.companyName,
      ),
    );
  }

  if (items.isEmpty && overview != null) {
    if (overview.summary.interviewCount > 0) {
      items.add(
        _AppNotificationItem(
          id: 'candidate-summary-interview-${overview.summary.monthKey}',
          title: 'Interview activity available',
          message:
              'You have ${overview.summary.interviewCount} interview-related application updates to review.',
          timeLabel: 'This month',
          kind: _NotificationKind.interview,
        ),
      );
    }
    if (overview.summary.shortlistedCount > 0) {
      items.add(
        _AppNotificationItem(
          id: 'candidate-summary-shortlisted-${overview.summary.monthKey}',
          title: 'Shortlisted applications',
          message:
              '${overview.summary.shortlistedCount} of your applications have reached the shortlist stage.',
          timeLabel: 'This month',
          kind: _NotificationKind.application,
        ),
      );
    }
  }

  return items;
}

List<_AppNotificationItem> _buildRecruiterNotifications(Ref ref) {
  final state = ref.watch(recruiterViewModelProvider);
  final overview = ref
      .read(recruiterViewModelProvider.notifier)
      .computeOverviewData();
  final now = DateTime.now();
  final items = <_AppNotificationItem>[];

  if (state.selectedWorkspace != null) {
    final urgentDeadlines = overview.upcomingDeadlines.take(3);
    for (final deadline in urgentDeadlines) {
      final parsed = DateTime.tryParse(deadline.deadline) ?? now;
      items.add(
        _AppNotificationItem(
          id: 'recruiter-deadline-${deadline.id}-${deadline.deadline}',
          title: 'Job deadline approaching',
          message:
              '${deadline.title} closes ${_deadlineLabel(parsed, now)} with ${deadline.applicants} applicants so far.',
          timeLabel: _relativeTime(parsed, now: now),
          kind: _NotificationKind.deadline,
          emphasis: state.selectedWorkspace?.companyName,
        ),
      );
    }

    final highTrafficJobs = [...overview.jobs]
      ..sort((a, b) => b.applicationsCount.compareTo(a.applicationsCount));
    for (final job
        in highTrafficJobs.where((job) => job.applicationsCount > 0).take(2)) {
      items.add(
        _AppNotificationItem(
          id: 'recruiter-applicants-${job.id}-${job.applicationsCount}',
          title: 'Applicant activity on ${job.title}',
          message:
              '${job.applicationsCount} applicants are currently in the pipeline for this role.',
          timeLabel: 'Live',
          kind: _NotificationKind.application,
          emphasis: job.companyName,
        ),
      );
    }
  }

  return items;
}

List<_AppNotificationItem> _buildCollegeNotifications(Ref ref) {
  final state = ref.watch(collegeDashboardViewModelProvider);
  final overview = ref
      .read(collegeDashboardViewModelProvider.notifier)
      .computeOverviewData();
  final now = DateTime.now();
  final items = <_AppNotificationItem>[];

  if (state.selectedWorkspace != null) {
    for (final deadline in overview.upcomingDeadlines.take(3)) {
      final parsed = DateTime.tryParse(deadline.deadline) ?? now;
      items.add(
        _AppNotificationItem(
          id: 'college-deadline-${deadline.id}-${deadline.deadline}',
          title: 'Placement deadline approaching',
          message:
              '${deadline.title} closes ${_deadlineLabel(parsed, now)} and already has ${deadline.applicants} applicants.',
          timeLabel: _relativeTime(parsed, now: now),
          kind: _NotificationKind.deadline,
          emphasis: state.selectedWorkspace?.collegeName,
        ),
      );
    }

    final highTrafficJobs = [...overview.jobs]
      ..sort((a, b) => b.applicationsCount.compareTo(a.applicationsCount));
    for (final job
        in highTrafficJobs.where((job) => job.applicationsCount > 0).take(2)) {
      items.add(
        _AppNotificationItem(
          id: 'college-applicants-${job.id}-${job.applicationsCount}',
          title: 'Student application activity',
          message:
              '${job.title} has ${job.applicationsCount} student applications in progress.',
          timeLabel: 'Live',
          kind: _NotificationKind.application,
          emphasis: state.selectedWorkspace?.collegeName,
        ),
      );
    }
  }

  return items;
}

String _applicationTitle(String status) {
  switch (status.toLowerCase()) {
    case 'shortlisted':
      return 'You were shortlisted';
    case 'interview_scheduled':
    case 'interview':
      return 'Interview scheduled';
    case 'accepted':
    case 'offered':
      return 'Offer update received';
    case 'rejected':
      return 'Application update';
    default:
      return 'Application activity';
  }
}

String _relativeTime(DateTime date, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final diff = date.difference(current);
  if (diff.inSeconds.abs() < 60) {
    return 'Just now';
  }
  if (diff.isNegative) {
    final past = current.difference(date);
    if (past.inHours < 1) return '${past.inMinutes}m ago';
    if (past.inDays < 1) return '${past.inHours}h ago';
    if (past.inDays < 7) return '${past.inDays}d ago';
    return DateFormat('MMM d').format(date);
  }
  if (diff.inHours < 1) return 'In ${diff.inMinutes}m';
  if (diff.inDays < 1) return 'In ${diff.inHours}h';
  if (diff.inDays < 7) return 'In ${diff.inDays}d';
  return DateFormat('MMM d').format(date);
}

String _deadlineLabel(DateTime deadline, DateTime now) {
  final days = deadline.difference(now).inDays;
  if (days <= 0) return 'today';
  if (days == 1) return 'tomorrow';
  return 'in $days days';
}

class NotificationsWidget extends ConsumerStatefulWidget {
  const NotificationsWidget({super.key});

  @override
  ConsumerState<NotificationsWidget> createState() =>
      _NotificationsWidgetState();
}

class _NotificationsWidgetState extends ConsumerState<NotificationsWidget> {
  bool _hasPrefetched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hasPrefetched) return;
      _hasPrefetched = true;
      unawaited(_prepareNotificationData());
    });
  }

  Future<void> _prepareNotificationData() async {
    try {
      final isRecruiter = ref.read(isRecruiterProvider);
      final isCollege = ref.read(isCollegeProvider);

      if (isRecruiter) {
        final state = ref.read(recruiterViewModelProvider);
        final vm = ref.read(recruiterViewModelProvider.notifier);
        if (state.workspaces == null &&
            state.workspacesStatus != RecruiterLoadStatus.loading) {
          await vm.loadWorkspaces();
        }
        final refreshed = ref.read(recruiterViewModelProvider);
        final workspace = refreshed.selectedWorkspace;
        if (workspace != null &&
            refreshed.companyJobs == null &&
            refreshed.companyJobsStatus != RecruiterLoadStatus.loading) {
          await vm.loadCompanyJobs(
            companyId: workspace.companyId,
            companyName: workspace.companyName,
          );
        }
        return;
      }

      if (isCollege) {
        final state = ref.read(collegeDashboardViewModelProvider);
        final vm = ref.read(collegeDashboardViewModelProvider.notifier);
        if (state.workspaces == null &&
            state.workspacesStatus != CollegeDashboardLoadStatus.loading) {
          await vm.loadWorkspaces();
        }
        final refreshed = ref.read(collegeDashboardViewModelProvider);
        final workspace = refreshed.selectedWorkspace;
        if (workspace != null &&
            refreshed.collegeJobs == null &&
            refreshed.collegeJobsStatus != CollegeDashboardLoadStatus.loading) {
          await vm.loadCollegeJobs(collegeId: workspace.collegeId);
        }
        return;
      }

      final state = ref.read(dashboardViewModelProvider);
      final vm = ref.read(dashboardViewModelProvider.notifier);
      if (state.overviewData == null &&
          state.overviewStatus != DashboardLoadStatus.loading) {
        await vm.loadOverview();
      }
      final refreshed = ref.read(dashboardViewModelProvider);
      if (refreshed.applicationsData == null &&
          refreshed.applicationsStatus != DashboardLoadStatus.loading) {
        await vm.loadMyApplications();
      }
    } catch (_) {}
  }

  Future<void> _showNotificationsSurface() async {
    if (!mounted) {
      return;
    }

    final width = MediaQuery.sizeOf(context).width;
    if (width < 640) {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const _NotificationsSheet(),
      );
      return;
    }

    await showGeneralDialog<void>(
      context: context,
      barrierLabel: 'Notifications',
      barrierDismissible: true,
      barrierColor: Colors.black.withAlpha(25),
      pageBuilder: (context, _, __) {
        return const SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(top: 16, right: 16, left: 16),
              child: _NotificationsPopover(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openNotifications() async {
    unawaited(_prepareNotificationData());
    await _showNotificationsSurface();
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(appNotificationItemsProvider);
    final isLoading = ref.watch(notificationPanelLoadingProvider);
    final readIds = ref.watch(notificationReadIdsProvider);
    final unreadCount = items
        .where((item) => !readIds.contains(item.id))
        .length;

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(LucideIcons.bell, size: 24),
          onPressed: _openNotifications,
        ),
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                unreadCount > 9 ? '9+' : '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        if (isLoading && unreadCount == 0)
          Positioned(
            right: 10,
            top: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class _NotificationsSheet extends StatelessWidget {
  const _NotificationsSheet();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return Container(
      height: math.min(height * 0.8, 620),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: const _NotificationsPanel(isBottomSheet: true),
    );
  }
}

class _NotificationsPopover extends StatelessWidget {
  const _NotificationsPopover();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 360,
        constraints: const BoxConstraints(maxHeight: 560),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderStroke2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(18),
              blurRadius: 28,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: const _NotificationsPanel(),
      ),
    );
  }
}

class _NotificationsPanel extends ConsumerWidget {
  const _NotificationsPanel({this.isBottomSheet = false});

  final bool isBottomSheet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(appNotificationItemsProvider);
    final isLoading = ref.watch(notificationPanelLoadingProvider);
    final readIds = ref.watch(notificationReadIdsProvider);
    final unreadCount = items
        .where((item) => !readIds.contains(item.id))
        .length;

    return Column(
      children: [
        if (isBottomSheet)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderStroke,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      unreadCount == 0
                          ? 'Everything is caught up.'
                          : '$unreadCount unread updates from live app activity.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              if (items.isNotEmpty)
                TextButton(
                  onPressed: unreadCount == 0
                      ? null
                      : () {
                          ref
                              .read(notificationReadIdsProvider.notifier)
                              .markAllRead(items.map((item) => item.id));
                        },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textLight,
                  ),
                  child: const Text('Mark all read'),
                ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderStroke2),
        Expanded(
          child: isLoading && items.isEmpty
              ? const _NotificationsLoadingState()
              : items.isEmpty
              ? const _NotificationsEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(14),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isRead = readIds.contains(item.id);
                    return _NotificationTile(item: item, isRead: isRead);
                  },
                ),
        ),
      ],
    );
  }
}

class _NotificationsLoadingState extends StatelessWidget {
  const _NotificationsLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(14),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderStroke2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 12,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.bgSecondary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 12,
                      width: 210,
                      decoration: BoxDecoration(
                        color: AppColors.bgTertiary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 12,
                      width: 120,
                      decoration: BoxDecoration(
                        color: AppColors.bgTertiary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
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

class _NotificationsEmptyState extends StatelessWidget {
  const _NotificationsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(LucideIcons.bellRing, size: 34, color: AppColors.textMedium),
            SizedBox(height: 14),
            Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Once interviews, deadlines, or application activity show up in the app, they will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textLight,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.item, required this.isRead});

  final _AppNotificationItem item;
  final bool isRead;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = switch (item.kind) {
      _NotificationKind.interview => AppColors.primary,
      _NotificationKind.deadline => AppColors.warning,
      _NotificationKind.application => AppColors.success2,
      _NotificationKind.workspace => AppColors.textDark,
    };

    final icon = switch (item.kind) {
      _NotificationKind.interview => LucideIcons.calendarClock,
      _NotificationKind.deadline => LucideIcons.timerReset,
      _NotificationKind.application => LucideIcons.briefcaseBusiness,
      _NotificationKind.workspace => LucideIcons.users,
    };

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        await ref.read(notificationReadIdsProvider.notifier).markRead(item.id);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
        if (!context.mounted) {
          return;
        }
        _handleNotificationTap(context, ref, item);
      },
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : accent.withAlpha(12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead ? AppColors.borderStroke2 : accent.withAlpha(40),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accent.withAlpha(18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accent, size: 20),
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
                          item.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isRead
                                ? FontWeight.w600
                                : FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.timeLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.message,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textLight,
                      height: 1.45,
                    ),
                  ),
                  if (item.emphasis != null &&
                      item.emphasis!.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.borderStroke2),
                      ),
                      child: Text(
                        item.emphasis!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: accent,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!isRead) ...[
              const SizedBox(width: 10),
              Container(
                width: 9,
                height: 9,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    WidgetRef ref,
    _AppNotificationItem item,
  ) {
    final isRecruiter = ref.read(isRecruiterProvider);
    final isCollege = ref.read(isCollegeProvider);

    if (isRecruiter) {
      ref.read(recruiterNavProvider.notifier).state =
          RecruiterDestination.companyJobs;
      return;
    }
    if (isCollege) {
      ref.read(collegeNavProvider.notifier).state =
          CollegeDestination.collegeJobs;
      return;
    }

    if (item.kind == _NotificationKind.deadline) {
      ref.read(bottomNavProvider.notifier).state = AppDestination.explore;
      return;
    }

    AppRoutes.push(context, const MyApplicationsPage());
  }
}

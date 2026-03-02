import 'package:flutter/material.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/app/theme/theme_utils.dart';
import 'package:kaarya/features/dashboard/domain/entities/dashboard_overview_entity.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/status_filter_widget.dart';

enum ApplicationStatus {
  all,
  applied,
  reviewing,
  shortlisted,
  interview,
  accepted,
  rejected,
}

class SummaryCardWidget extends StatefulWidget {
  const SummaryCardWidget({
    super.key,
    required this.summary,
    this.onMonthChanged,
  });

  final DashboardApplicationsSummaryEntity summary;
  final ValueChanged<String>? onMonthChanged;

  @override
  State<SummaryCardWidget> createState() => SummaryCardWidgetState();
}

class SummaryCardWidgetState extends State<SummaryCardWidget> {
  ApplicationStatus selectedStatus = ApplicationStatus.all;

  int get applicationsCount {
    switch (selectedStatus) {
      case ApplicationStatus.all:
        return widget.summary.total;
      case ApplicationStatus.applied:
        return widget.summary.appliedCount;
      case ApplicationStatus.reviewing:
        return widget.summary.reviewingCount;
      case ApplicationStatus.shortlisted:
        return widget.summary.shortlistedCount;
      case ApplicationStatus.interview:
        return widget.summary.interviewCount;
      case ApplicationStatus.accepted:
        return widget.summary.acceptedCount;
      case ApplicationStatus.rejected:
        return widget.summary.rejectedCount + widget.summary.withdrawnCount;
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthKey = _resolvedMonthKey(widget.summary.monthKey);
    final monthLabel = widget.summary.monthLabel.isEmpty
        ? _formatMonthLabel(monthKey)
        : widget.summary.monthLabel;
    final monthOptions = _buildMonthOptions();
    final recentCompanies = widget.summary.recentCompanies;

    return Card(
      color: appSurfaceColor(context),
      elevation: 0,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: appBorderColor(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Applications Summary",
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Live application pipeline snapshot.",
                        style: TextStyle(
                          fontSize: 12,
                          color: appTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: widget.onMonthChanged,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 4,
                  color: appSurfaceColor(context),
                  surfaceTintColor: appSurfaceColor(context),
                  itemBuilder: (_) => monthOptions
                      .map(
                        (item) => PopupMenuItem<String>(
                          value: item.key,
                          child: Text(
                            item.label,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      )
                      .toList(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: appMutedSurfaceColor(context),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          monthLabel.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.keyboard_arrow_down, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            StatusFilterWidget(
              selectedStatus: selectedStatus,
              countResolver: _countForStatus,
              onChanged: (status) {
                setState(() {
                  selectedStatus = status;
                });
              },
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  applicationsCount.toString(),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _RecentCompaniesAvatars(companies: recentCompanies),
                ),
              ],
            ),
            Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text:
                        "${widget.summary.delta >= 0 ? '+' : ''}${widget.summary.delta}",
                    style: TextStyle(
                      color: widget.summary.delta >= 0
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                  TextSpan(
                    text:
                        " compared to last month. ${widget.summary.todayCount} applications submitted today.",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (recentCompanies.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: appMutedSurfaceColor(context),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: appSubtleBorderColor(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "RECENTLY APPLIED COMPANIES",
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMedium,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: recentCompanies
                          .map(
                            (company) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: appSurfaceColor(context),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: appSubtleBorderColor(context),
                                ),
                              ),
                              child: Text(
                                "${company.name} (${company.applicationsCount})",
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  int _countForStatus(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.all:
        return widget.summary.total;
      case ApplicationStatus.applied:
        return widget.summary.appliedCount;
      case ApplicationStatus.reviewing:
        return widget.summary.reviewingCount;
      case ApplicationStatus.shortlisted:
        return widget.summary.shortlistedCount;
      case ApplicationStatus.interview:
        return widget.summary.interviewCount;
      case ApplicationStatus.accepted:
        return widget.summary.acceptedCount;
      case ApplicationStatus.rejected:
        return widget.summary.rejectedCount + widget.summary.withdrawnCount;
    }
  }

  String _resolvedMonthKey(String rawMonthKey) {
    final regex = RegExp(r'^\d{4}-(0[1-9]|1[0-2])$');
    if (regex.hasMatch(rawMonthKey)) {
      return rawMonthKey;
    }

    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  List<_MonthOption> _buildMonthOptions() {
    final now = DateTime.now();
    return List.generate(6, (index) {
      final date = DateTime(now.year, now.month - index);
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      return _MonthOption(key: key, label: _formatMonthLabel(key));
    });
  }

  String _formatMonthLabel(String monthKey) {
    final parsed = monthKey.split('-');
    if (parsed.length != 2) {
      return 'Current Month';
    }

    final year = int.tryParse(parsed[0]);
    final month = int.tryParse(parsed[1]);
    if (year == null || month == null || month < 1 || month > 12) {
      return 'Current Month';
    }

    return '${_monthName(month)} $year';
  }

  String _monthName(int month) {
    switch (month) {
      case DateTime.january:
        return 'January';
      case DateTime.february:
        return 'February';
      case DateTime.march:
        return 'March';
      case DateTime.april:
        return 'April';
      case DateTime.may:
        return 'May';
      case DateTime.june:
        return 'June';
      case DateTime.july:
        return 'July';
      case DateTime.august:
        return 'August';
      case DateTime.september:
        return 'September';
      case DateTime.october:
        return 'October';
      case DateTime.november:
        return 'November';
      default:
        return 'December';
    }
  }
}

class _MonthOption {
  final String key;
  final String label;

  const _MonthOption({required this.key, required this.label});
}

class _RecentCompaniesAvatars extends StatelessWidget {
  const _RecentCompaniesAvatars({required this.companies});

  final List<DashboardRecentCompanyEntity> companies;

  @override
  Widget build(BuildContext context) {
    final visible = companies.take(4).toList();
    final extraCount = companies.length > 4 ? companies.length - 4 : 0;

    if (visible.isEmpty) {
      return const SizedBox.shrink();
    }

    const avatarSize = 24.0;
    const overlap = 18.0;
    final totalWidth =
        (visible.length * overlap) +
        avatarSize +
        (extraCount > 0 ? overlap : 0);

    return SizedBox(
      width: totalWidth,
      height: avatarSize,
      child: Stack(
        children: [
          for (int i = 0; i < visible.length; i++)
            Positioned(
              left: i * overlap,
              child: _CompanyAvatar(company: visible[i], size: avatarSize),
            ),
          if (extraCount > 0)
            Positioned(
              left: visible.length * overlap,
              child: CircleAvatar(
                radius: avatarSize / 2,
                backgroundColor: AppColors.bgSecondary,
                child: Text(
                  '+$extraCount',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CompanyAvatar extends StatelessWidget {
  const _CompanyAvatar({required this.company, required this.size});

  final DashboardRecentCompanyEntity company;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: appSurfaceColor(context),
      child: ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: company.logo != null
              ? Image.network(
                  company.logo!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallback(),
                )
              : _fallback(),
        ),
      ),
    );
  }

  Widget _fallback() {
    final initial = company.name.isEmpty ? 'K' : company.name[0].toUpperCase();
    return Container(
      color: AppColors.bgSecondary,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}

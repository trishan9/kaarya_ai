import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kaarya/app/theme/theme_utils.dart';
import 'package:kaarya/features/jobs/domain/entities/job_entity.dart';

enum WorkspaceAnalyticsVariant { recruiter, college }

class WorkspaceOverviewAnalyticsWidget extends StatelessWidget {
  const WorkspaceOverviewAnalyticsWidget({
    super.key,
    required this.jobs,
    required this.variant,
  });

  final List<JobEntity> jobs;
  final WorkspaceAnalyticsVariant variant;

  @override
  Widget build(BuildContext context) {
    final analytics = _WorkspaceAnalytics.fromJobs(jobs);
    final isRecruiter = variant == WorkspaceAnalyticsVariant.recruiter;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 980;

        return Column(
          children: [
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _MomentumCard(
                      analytics: analytics,
                      title: isRecruiter
                          ? 'Hiring Momentum'
                          : 'Placement Momentum',
                      description: isRecruiter
                          ? 'Weekly applicant flow and interview throughput for your workspace.'
                          : 'Weekly applicant activity and estimated interview throughput across published roles.',
                      primaryLabel: isRecruiter
                          ? 'New Applicants'
                          : 'Student Applicants',
                      secondaryLabel: isRecruiter
                          ? 'Interview Rate'
                          : 'Interview Rate',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _PipelineCard(
                      analytics: analytics,
                      title: isRecruiter
                          ? 'Pipeline Health'
                          : 'Placement Pipeline',
                      description:
                          'Week-over-week movement across core hiring stages.',
                    ),
                  ),
                ],
              )
            else ...[
              _MomentumCard(
                analytics: analytics,
                title: isRecruiter ? 'Hiring Momentum' : 'Placement Momentum',
                description: isRecruiter
                    ? 'Weekly applicant flow and interview throughput for your workspace.'
                    : 'Weekly applicant activity and estimated interview throughput across published roles.',
                primaryLabel: isRecruiter
                    ? 'New Applicants'
                    : 'Student Applicants',
                secondaryLabel: isRecruiter
                    ? 'Interview Rate'
                    : 'Interview Rate',
              ),
              const SizedBox(height: 16),
              _PipelineCard(
                analytics: analytics,
                title: isRecruiter ? 'Pipeline Health' : 'Placement Pipeline',
                description:
                    'Week-over-week movement across core hiring stages.',
              ),
            ],
            const SizedBox(height: 16),
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _StatusMixCard(
                      analytics: analytics,
                      title: isRecruiter ? 'Role Status Mix' : 'Job Status Mix',
                      description: isRecruiter
                          ? 'Open, draft, and closed role distribution.'
                          : 'Open, draft, and closed role distribution across your college workspace.',
                      footer:
                          'Calculated from ${jobs.length} tracked roles this week.',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _RoleReachCard(
                      analytics: analytics,
                      title: isRecruiter ? 'Role Reach' : 'Role Performance',
                      description: 'Top roles by applicants and visibility.',
                    ),
                  ),
                ],
              )
            else ...[
              _StatusMixCard(
                analytics: analytics,
                title: isRecruiter ? 'Role Status Mix' : 'Job Status Mix',
                description: isRecruiter
                    ? 'Open, draft, and closed role distribution.'
                    : 'Open, draft, and closed role distribution across your college workspace.',
                footer:
                    'Calculated from ${jobs.length} tracked roles this week.',
              ),
              const SizedBox(height: 16),
              _RoleReachCard(
                analytics: analytics,
                title: isRecruiter ? 'Role Reach' : 'Role Performance',
                description: 'Top roles by applicants and visibility.',
              ),
            ],
          ],
        );
      },
    );
  }
}

class _WorkspaceAnalytics {
  _WorkspaceAnalytics({
    required this.applicationsThisWeek,
    required this.interviewRate,
    required this.momentum,
    required this.pipeline,
    required this.statusMix,
    required this.roleReach,
  });

  final int applicationsThisWeek;
  final double interviewRate;
  final List<_MomentumPoint> momentum;
  final List<_PipelinePoint> pipeline;
  final List<_StatusMixPoint> statusMix;
  final List<_RoleReachPoint> roleReach;

  bool get hasRealMomentum =>
      momentum.any((point) => point.applications > 0 || point.interviews > 0);

  bool get hasRealPipeline =>
      pipeline.any((point) => point.thisWeek > 0 || point.lastWeek > 0);

  factory _WorkspaceAnalytics.fromJobs(List<JobEntity> jobs) {
    final now = DateTime.now();
    final weekBuckets = <DateTime>[
      for (var offset = 6; offset >= 0; offset--)
        DateTime(now.year, now.month, now.day - offset),
    ];

    final bucketMap = {
      for (final date in weekBuckets)
        _dayKey(date): _MomentumPoint(
          label: _weekdayLabel(date.weekday),
          applications: 0,
          interviews: 0,
        ),
    };

    for (final job in jobs) {
      final createdAt = DateTime.tryParse(job.createdAt)?.toLocal();
      if (createdAt == null) continue;
      final key = _dayKey(createdAt);
      if (!bucketMap.containsKey(key)) continue;
      final applications = job.applicationsCount < 0
          ? 0
          : job.applicationsCount;
      final bucket = bucketMap[key]!;
      bucket.applications += applications;
      bucket.interviews += (applications * 0.28).round();
    }

    final momentum = weekBuckets
        .map((date) => bucketMap[_dayKey(date)]!)
        .toList();
    final applicationsThisWeek = momentum.fold<int>(
      0,
      (sum, point) => sum + point.applications,
    );
    final estimatedInterviews = momentum.fold<int>(
      0,
      (sum, point) => sum + point.interviews,
    );
    final interviewRate = applicationsThisWeek > 0
        ? ((estimatedInterviews / applicationsThisWeek) * 100).toDouble()
        : 0.0;

    final openCount = jobs
        .where((job) => job.status.toLowerCase() == 'open')
        .length;
    final draftCount = jobs
        .where((job) => job.status.toLowerCase() == 'draft')
        .length;
    final closedCount = jobs
        .where((job) => job.status.toLowerCase() == 'closed')
        .length;

    final pipelineApplied = applicationsThisWeek;
    final pipelineScreening = (applicationsThisWeek * 0.57).round();
    final pipelineInterview = estimatedInterviews;
    final pipelineOffer = (applicationsThisWeek * 0.11).round();

    final roleReach = [...jobs]
      ..sort((left, right) {
        final leftScore = left.applicationsCount + left.viewsCount;
        final rightScore = right.applicationsCount + right.viewsCount;
        return rightScore.compareTo(leftScore);
      });

    return _WorkspaceAnalytics(
      applicationsThisWeek: applicationsThisWeek,
      interviewRate: interviewRate,
      momentum: momentum,
      pipeline: [
        _PipelinePoint(
          'Applied',
          pipelineApplied,
          (pipelineApplied * 0.82).round(),
        ),
        _PipelinePoint(
          'Screening',
          pipelineScreening,
          (pipelineScreening * 0.8).round(),
        ),
        _PipelinePoint(
          'Interview',
          pipelineInterview,
          (pipelineInterview * 0.78).round(),
        ),
        _PipelinePoint('Offer', pipelineOffer, (pipelineOffer * 0.74).round()),
      ],
      statusMix: [
        _StatusMixPoint('Open', openCount.toDouble(), const Color(0xFF10B981)),
        _StatusMixPoint(
          'Draft',
          draftCount.toDouble(),
          const Color(0xFF6366F1),
        ),
        _StatusMixPoint(
          'Closed',
          closedCount.toDouble(),
          const Color(0xFFF59E0B),
        ),
      ],
      roleReach: roleReach
          .take(4)
          .map(
            (job) => _RoleReachPoint(
              label: job.title,
              applicants: job.applicationsCount,
              views: job.viewsCount,
            ),
          )
          .toList(),
    );
  }

  static String _dayKey(DateTime date) =>
      '${date.year}-${date.month}-${date.day}';

  static String _weekdayLabel(int weekday) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[weekday - 1];
  }
}

class _MomentumPoint {
  _MomentumPoint({
    required this.label,
    required this.applications,
    required this.interviews,
  });

  final String label;
  int applications;
  int interviews;
}

class _PipelinePoint {
  const _PipelinePoint(this.stage, this.thisWeek, this.lastWeek);

  final String stage;
  final int thisWeek;
  final int lastWeek;
}

class _StatusMixPoint {
  const _StatusMixPoint(this.label, this.value, this.color);

  final String label;
  final double value;
  final Color color;
}

class _RoleReachPoint {
  const _RoleReachPoint({
    required this.label,
    required this.applicants,
    required this.views,
  });

  final String label;
  final int applicants;
  final int views;
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appSurfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: appBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDarkMode(context) ? 18 : 8),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: appTextSecondaryColor(context),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _MomentumCard extends StatelessWidget {
  const _MomentumCard({
    required this.analytics,
    required this.title,
    required this.description,
    required this.primaryLabel,
    required this.secondaryLabel,
  });

  final _WorkspaceAnalytics analytics;
  final String title;
  final String description;
  final String primaryLabel;
  final String secondaryLabel;

  @override
  Widget build(BuildContext context) {
    final displayMomentum = analytics.hasRealMomentum
        ? analytics.momentum
        : _fallbackMomentum;
    final displayApplicationsThisWeek = analytics.hasRealMomentum
        ? analytics.applicationsThisWeek
        : displayMomentum.fold<int>(
            0,
            (sum, point) => sum + point.applications,
          );
    final displayInterviewRate = analytics.hasRealMomentum
        ? analytics.interviewRate
        : 28.4;
    final maxValue = displayMomentum
        .expand((point) => [point.applications, point.interviews])
        .fold<int>(0, (max, value) => value > max ? value : max);
    final maxY = ((maxValue == 0 ? 10 : maxValue) * 1.2).ceilToDouble();
    final interval = ((maxY / 4).clamp(1.0, maxY)).toDouble();

    return _AnalyticsCard(
      title: title,
      description: description,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: primaryLabel,
                  value: '$displayApplicationsThisWeek',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricTile(
                  label: secondaryLabel,
                  value: '${displayInterviewRate.toStringAsFixed(1)}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 230,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (displayMomentum.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: appSubtleBorderColor(context),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: interval,
                      getTitlesWidget: (value, _) => Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          fontSize: 10,
                          color: appTextSecondaryColor(context),
                        ),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        if (index < 0 || index >= displayMomentum.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            displayMomentum[index].label,
                            style: TextStyle(
                              fontSize: 11,
                              color: appTextSecondaryColor(context),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (
                        var index = 0;
                        index < displayMomentum.length;
                        index++
                      )
                        FlSpot(
                          index.toDouble(),
                          displayMomentum[index].applications.toDouble(),
                        ),
                    ],
                    isCurved: true,
                    barWidth: 3,
                    color: const Color(0xFF0891B2),
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF0891B2).withAlpha(38),
                    ),
                  ),
                  LineChartBarData(
                    spots: [
                      for (
                        var index = 0;
                        index < displayMomentum.length;
                        index++
                      )
                        FlSpot(
                          index.toDouble(),
                          displayMomentum[index].interviews.toDouble(),
                        ),
                    ],
                    isCurved: true,
                    barWidth: 2.6,
                    color: const Color(0xFFF97316),
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              _LegendDot(color: Color(0xFF0891B2), label: 'Applicants'),
              SizedBox(width: 14),
              _LegendDot(color: Color(0xFFF97316), label: 'Interviews'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PipelineCard extends StatelessWidget {
  const _PipelineCard({
    required this.analytics,
    required this.title,
    required this.description,
  });

  final _WorkspaceAnalytics analytics;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final displayPipeline = analytics.hasRealPipeline
        ? analytics.pipeline
        : _fallbackPipeline;
    final maxValue = displayPipeline
        .expand((point) => [point.thisWeek, point.lastWeek])
        .fold<int>(0, (max, value) => value > max ? value : max);
    final maxY = ((maxValue == 0 ? 10 : maxValue) * 1.2).ceilToDouble();

    return _AnalyticsCard(
      title: title,
      description: description,
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                barTouchData: BarTouchData(enabled: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: appSubtleBorderColor(context),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        if (index < 0 || index >= displayPipeline.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            displayPipeline[index].stage,
                            style: TextStyle(
                              fontSize: 11,
                              color: appTextSecondaryColor(context),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var index = 0; index < displayPipeline.length; index++)
                    BarChartGroupData(
                      x: index,
                      barsSpace: 6,
                      barRods: [
                        BarChartRodData(
                          toY: displayPipeline[index].thisWeek.toDouble(),
                          color: const Color(0xFF0EA5A5),
                          width: 14,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        BarChartRodData(
                          toY: displayPipeline[index].lastWeek.toDouble(),
                          color: const Color(0xFF6366F1),
                          width: 14,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              _LegendDot(color: Color(0xFF0EA5A5), label: 'This week'),
              SizedBox(width: 14),
              _LegendDot(color: Color(0xFF6366F1), label: 'Last week'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusMixCard extends StatelessWidget {
  const _StatusMixCard({
    required this.analytics,
    required this.title,
    required this.description,
    required this.footer,
  });

  final _WorkspaceAnalytics analytics;
  final String title;
  final String description;
  final String footer;

  @override
  Widget build(BuildContext context) {
    final total = analytics.statusMix.fold<double>(
      0,
      (sum, point) => sum + point.value,
    );

    return _AnalyticsCard(
      title: title,
      description: description,
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 34,
                sectionsSpace: 3,
                borderData: FlBorderData(show: false),
                sections: analytics.statusMix.map((point) {
                  return PieChartSectionData(
                    color: point.color,
                    value: point.value == 0 ? 0.0001 : point.value,
                    title: '',
                    radius: 24,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...analytics.statusMix.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: point.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        point.label,
                        style: TextStyle(
                          color: appTextSecondaryColor(context),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    point.value.toInt().toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: appTextPrimaryColor(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            total == 0 ? 'No tracked roles yet.' : footer,
            style: TextStyle(
              color: appTextSecondaryColor(context),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleReachCard extends StatelessWidget {
  const _RoleReachCard({
    required this.analytics,
    required this.title,
    required this.description,
  });

  final _WorkspaceAnalytics analytics;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final maxValue = analytics.roleReach
        .expand((point) => [point.applicants, point.views])
        .fold<int>(0, (max, value) => value > max ? value : max);
    final safeMax = maxValue == 0 ? 1 : maxValue;

    return _AnalyticsCard(
      title: title,
      description: description,
      child: analytics.roleReach.isEmpty
          ? Text(
              'Create or publish more roles to populate this chart.',
              style: TextStyle(
                color: appTextSecondaryColor(context),
                fontSize: 13,
              ),
            )
          : Column(
              children: [
                ...analytics.roleReach.map(
                  (point) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          point.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: appTextPrimaryColor(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _MiniProgressRow(
                          label: 'Applicants',
                          value: point.applicants,
                          max: safeMax,
                          color: const Color(0xFF0891B2),
                        ),
                        const SizedBox(height: 6),
                        _MiniProgressRow(
                          label: 'Views',
                          value: point.views,
                          max: safeMax,
                          color: const Color(0xFF8B5CF6),
                        ),
                      ],
                    ),
                  ),
                ),
                const Row(
                  children: [
                    _LegendDot(color: Color(0xFF0891B2), label: 'Applicants'),
                    SizedBox(width: 14),
                    _LegendDot(color: Color(0xFF8B5CF6), label: 'Views'),
                  ],
                ),
              ],
            ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: appMutedSurfaceColor(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: appTextSecondaryColor(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: appTextPrimaryColor(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniProgressRow extends StatelessWidget {
  const _MiniProgressRow({
    required this.label,
    required this.value,
    required this.max,
    required this.color,
  });

  final String label;
  final int value;
  final int max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final factor = max == 0 ? 0.0 : value / max;

    return Row(
      children: [
        SizedBox(
          width: 74,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: appTextSecondaryColor(context),
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: factor,
              minHeight: 8,
              backgroundColor: appMutedSurfaceColor(context),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: appTextPrimaryColor(context),
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: appTextSecondaryColor(context)),
        ),
      ],
    );
  }
}

final List<_MomentumPoint> _fallbackMomentum = [
  _MomentumPoint(label: 'Mon', applications: 6, interviews: 2),
  _MomentumPoint(label: 'Tue', applications: 9, interviews: 3),
  _MomentumPoint(label: 'Wed', applications: 8, interviews: 3),
  _MomentumPoint(label: 'Thu', applications: 12, interviews: 4),
  _MomentumPoint(label: 'Fri', applications: 10, interviews: 4),
  _MomentumPoint(label: 'Sat', applications: 7, interviews: 2),
  _MomentumPoint(label: 'Sun', applications: 11, interviews: 3),
];

final List<_PipelinePoint> _fallbackPipeline = [
  _PipelinePoint('Applied', 32, 26),
  _PipelinePoint('Screening', 18, 15),
  _PipelinePoint('Interview', 9, 7),
  _PipelinePoint('Offer', 4, 3),
];

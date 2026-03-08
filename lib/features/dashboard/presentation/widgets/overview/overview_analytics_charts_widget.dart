import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/app/theme/theme_utils.dart';
import 'package:kaarya/features/dashboard/domain/entities/dashboard_overview_entity.dart';

class OverviewAnalyticsChartsWidget extends StatelessWidget {
  const OverviewAnalyticsChartsWidget({super.key, required this.analytics});

  final DashboardAnalyticsEntity analytics;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMomentumCard(context),
        const SizedBox(height: 14),
        _buildProgressCard(context),
        const SizedBox(height: 14),
        _buildInvitationMixCard(context),
      ],
    );
  }

  Widget _buildMomentumCard(BuildContext context) {
    final momentum = analytics.momentum;
    final hasPoints = momentum.isNotEmpty;
    final maxY = _momentumMaxY();

    return Card(
      color: appSurfaceColor(context),
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: appBorderColor(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Application Momentum",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 2),
            const Text(
              "Weekly activity overview with interview conversion trend.",
              style: TextStyle(color: AppColors.textMedium),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _metricTile(
                    context,
                    "This Week Applications",
                    "${analytics.applicationsThisWeek}",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _metricTile(
                    context,
                    "Interview Conversion",
                    "${analytics.interviewConversion.toStringAsFixed(1)}%",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!hasPoints)
              const Text(
                "No momentum data available.",
                style: TextStyle(color: AppColors.textMedium),
              )
            else
              SizedBox(
                height: 210,
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: (momentum.length - 1).toDouble(),
                    minY: 0,
                    maxY: maxY.toDouble(),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: (maxY / 5).clamp(1, maxY).toDouble(),
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: appSubtleBorderColor(context),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          interval: (maxY / 5).clamp(1, maxY).toDouble(),
                          getTitlesWidget: (value, _) => Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontSize: 10,
                              color: appTextSecondaryColor(context),
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, _) {
                            final index = value.toInt();
                            final label = index >= 0 && index < momentum.length
                                ? momentum[index].label
                                : "";
                            return Text(
                              label,
                              style: TextStyle(
                                fontSize: 10,
                                color: appTextSecondaryColor(context),
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(momentum.length, (index) {
                          return FlSpot(
                            index.toDouble(),
                            momentum[index].applications.toDouble(),
                          );
                        }),
                        isCurved: true,
                        barWidth: 2.8,
                        color: const Color(0xFF0891B2),
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: const Color(0xFF0891B2).withAlpha(50),
                        ),
                      ),
                      LineChartBarData(
                        spots: List.generate(momentum.length, (index) {
                          return FlSpot(
                            index.toDouble(),
                            momentum[index].interviews.toDouble(),
                          );
                        }),
                        isCurved: true,
                        barWidth: 2.3,
                        color: const Color(0xFFF97316),
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: const [
                _LegendDot(color: Color(0xFF0891B2), label: "Applications"),
                SizedBox(width: 14),
                _LegendDot(color: Color(0xFFF97316), label: "Interviews"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    final pipeline = analytics.pipeline;
    final maxY = _pipelineMaxY().toDouble();

    return Card(
      color: appSurfaceColor(context),
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: appBorderColor(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Application Progress",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 2),
            const Text(
              "Week-over-week progress by hiring stage.",
              style: TextStyle(color: AppColors.textMedium),
            ),
            const SizedBox(height: 16),
            if (pipeline.isEmpty)
              const Text(
                "No progress data available.",
                style: TextStyle(color: AppColors.textMedium),
              )
            else
              SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    maxY: maxY,
                    barGroups: List.generate(pipeline.length, (index) {
                      final point = pipeline[index];
                      return BarChartGroupData(
                        x: index,
                        barsSpace: 6,
                        barRods: [
                          BarChartRodData(
                            toY: point.thisWeek.toDouble(),
                            color: const Color(0xFF0EA5A5),
                            width: 12,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          BarChartRodData(
                            toY: point.lastWeek.toDouble(),
                            color: const Color(0xFF6366F1),
                            width: 12,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ],
                      );
                    }),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: appSubtleBorderColor(context),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                          reservedSize: 26,
                        ),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) {
                            final index = value.toInt();
                            final label = index >= 0 && index < pipeline.length
                                ? pipeline[index].stage
                                : "";
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                label,
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
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: const [
                _LegendDot(color: Color(0xFF0EA5A5), label: "This week"),
                SizedBox(width: 14),
                _LegendDot(color: Color(0xFF6366F1), label: "Last week"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvitationMixCard(BuildContext context) {
    final mix = analytics.invitationMix;
    final total = mix.fold<double>(0, (sum, item) => sum + item.value);

    return Card(
      color: appSurfaceColor(context),
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: appBorderColor(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Invitation Responses",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 2),
            const Text(
              "Response status distribution for recent invites.",
              style: TextStyle(color: AppColors.textMedium),
            ),
            const SizedBox(height: 16),
            if (mix.isEmpty)
              const Text(
                "No invitation data available.",
                style: TextStyle(color: AppColors.textMedium),
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 130,
                    width: 130,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 32,
                        sections: mix.map((item) {
                          final color =
                              _parseHexColor(item.fill) ?? AppColors.primary;
                          return PieChartSectionData(
                            color: color,
                            value: item.value,
                            title: '',
                            radius: 28,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: mix.map((item) {
                        final color =
                            _parseHexColor(item.fill) ?? AppColors.primary;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 9,
                                    height: 9,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    item.name,
                                    style: TextStyle(
                                      color: AppColors.textMedium,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "${item.value.toStringAsFixed(item.value % 1 == 0 ? 0 : 1)}%",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 4),
            Text(
              "Based on ${total.toStringAsFixed(total % 1 == 0 ? 0 : 1)} invitations from the last 30 days.",
              style: TextStyle(
                color: appTextSecondaryColor(context),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricTile(BuildContext context, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: appMutedSurfaceColor(context),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: appTextSecondaryColor(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  int _momentumMaxY() {
    final values = analytics.momentum
        .expand((item) => [item.applications, item.interviews])
        .toList();
    if (values.isEmpty) return 10;
    final maxValue = values.reduce(
      (left, right) => left > right ? left : right,
    );
    return (maxValue * 1.2).ceil().clamp(10, 99999);
  }

  int _pipelineMaxY() {
    final values = analytics.pipeline
        .expand((item) => [item.thisWeek, item.lastWeek])
        .toList();
    if (values.isEmpty) return 10;
    final maxValue = values.reduce(
      (left, right) => left > right ? left : right,
    );
    return (maxValue * 1.2).ceil().clamp(10, 99999);
  }

  Color? _parseHexColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final normalized = hex.replaceFirst('#', '');
    if (normalized.length != 6) return null;
    final value = int.tryParse(normalized, radix: 16);
    if (value == null) return null;
    return Color(0xFF000000 | value);
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
          style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
        ),
      ],
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/features/dashboard/domain/entities/dashboard_overview_entity.dart';

class InterviewReadinessChartWidget extends StatelessWidget {
  const InterviewReadinessChartWidget({
    super.key,
    required this.readinessPoints,
  });

  final List<DashboardInterviewReadinessPointEntity> readinessPoints;

  @override
  Widget build(BuildContext context) {
    final spots = _buildChartSpots();
    final labels = readinessPoints.map((item) => item.label).toList();
    final growth = _growthPercent();

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Interview Readiness",
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const Text(
              "Your AI mock interview performance over time",
              style: TextStyle(color: AppColors.textMedium),
            ),

            const SizedBox(height: 20),

            if (spots.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  "Complete your first interview to view readiness trend.",
                  style: TextStyle(color: AppColors.textMedium),
                ),
              )
            else
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    minX: 1,
                    maxX: spots.length.toDouble(),
                    minY: 0,
                    maxY: 100,

                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 20,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: AppColors.borderStroke2,
                        strokeWidth: 1,
                      ),
                    ),

                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 20,
                          getTitlesWidget: (value, _) {
                            return Text(
                              "${value.toInt()}%",
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMedium,
                              ),
                            );
                          },
                          reservedSize: 40,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, _) {
                            final index = value.toInt() - 1;
                            final label = index >= 0 && index < labels.length
                                ? labels[index]
                                : "";

                            return Text(
                              label,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMedium,
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

                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (spots) {
                          return spots.map((spot) {
                            return LineTooltipItem(
                              '${spot.y.toInt()}%',
                              const TextStyle(color: Colors.white),
                            );
                          }).toList();
                        },
                      ),
                    ),

                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 3,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, bar, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: Colors.white,
                              strokeWidth: 3,
                              strokeColor: AppColors.primary,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withAlpha(64),
                              AppColors.primary.withAlpha(12),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 12),

            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 13, color: AppColors.textMedium),
                children: [
                  const TextSpan(text: "Your interview readiness changed by "),
                  TextSpan(
                    text:
                        "${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(1)}%",
                    style: TextStyle(
                      color: growth >= 0 ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(
                    text:
                        " based on your recent AI mock sessions. Keep practicing!",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _buildChartSpots() {
    if (readinessPoints.isEmpty) {
      return const <FlSpot>[];
    }

    return List.generate(
      readinessPoints.length,
      (index) => FlSpot(index + 1, readinessPoints[index].score),
    );
  }

  double _growthPercent() {
    if (readinessPoints.length < 2) {
      return 0;
    }

    final first = readinessPoints.first.score;
    final last = readinessPoints.last.score;
    if (first == 0) {
      return last == 0 ? 0 : 100;
    }

    return ((last - first) / first) * 100;
  }
}

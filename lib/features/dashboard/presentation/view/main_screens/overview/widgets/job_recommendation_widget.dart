import 'package:flutter/material.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/features/dashboard/presentation/view/main_screens/overview/widgets/job_filter_widget.dart';
import 'package:kaarya/widgets/job_card_widget.dart';

enum JobFilter { forYou, trending, newThisWeek, urgent, remote }

class JobRecommendationWidget extends StatefulWidget {
  const JobRecommendationWidget({super.key});

  @override
  State<JobRecommendationWidget> createState() =>
      _JobRecommendationWidgetState();
}

class _JobRecommendationWidgetState extends State<JobRecommendationWidget> {
  JobFilter selectedFilter = JobFilter.forYou;

  int get jobs {
    switch (selectedFilter) {
      case JobFilter.forYou:
        return 124;
      case JobFilter.trending:
        return 18;
      case JobFilter.newThisWeek:
        return 42;
      case JobFilter.urgent:
        return 9;
      case JobFilter.remote:
        return 9;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Job Recommendations",
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                Text(
                  "See All",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            SizedBox(height: 18),

            JobFilterWidget(
              selectedFilter: selectedFilter,
              onChanged: (filter) {
                setState(() {
                  selectedFilter = filter;
                });
              },
            ),

            SizedBox(height: 18),

            JobCardWidget(),
          ],
        ),
      ),
    );
  }
}

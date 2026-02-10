import 'package:flutter/material.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/features/jobs/domain/entities/job_entity.dart';
import 'package:kaarya/features/jobs/domain/entities/jobs_section_entity.dart'
    show JobsBucketEntity;
import 'package:kaarya/features/dashboard/presentation/widgets/overview/job_filter_widget.dart';
import 'package:kaarya/core/widgets/job_card_widget.dart';

enum JobFilter { forYou, trending, newThisWeek, urgent, remote }

class JobRecommendationWidget extends StatefulWidget {
  const JobRecommendationWidget({
    super.key,
    required this.jobsBucket,
    this.onSeeAllTap,
  });

  final JobsBucketEntity jobsBucket;
  final VoidCallback? onSeeAllTap;

  @override
  State<JobRecommendationWidget> createState() =>
      _JobRecommendationWidgetState();
}

class _JobRecommendationWidgetState extends State<JobRecommendationWidget> {
  JobFilter selectedFilter = JobFilter.forYou;

  List<JobEntity> get jobs {
    switch (selectedFilter) {
      case JobFilter.forYou:
        return widget.jobsBucket.forYou;
      case JobFilter.trending:
        return widget.jobsBucket.trending;
      case JobFilter.newThisWeek:
        return widget.jobsBucket.newThisWeek;
      case JobFilter.urgent:
        return widget.jobsBucket.urgent;
      case JobFilter.remote:
        return widget.jobsBucket.remote;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
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

                InkWell(
                  onTap: widget.onSeeAllTap,
                  child: Text(
                    "See All",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
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

            if (jobs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "No jobs found for this filter.",
                  style: TextStyle(color: AppColors.textMedium),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: jobs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return JobCardWidget(job: jobs[index]);
                },
              ),
          ],
        ),
      ),
    );
  }
}

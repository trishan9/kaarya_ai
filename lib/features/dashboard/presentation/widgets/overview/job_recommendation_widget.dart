import 'package:flutter/material.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/features/dashboard/data/models/job_model.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/job_filter_widget.dart';
import 'package:kaarya/core/widgets/job_card_widget.dart';

enum JobFilter { forYou, trending, newThisWeek, urgent, remote }

final List<JobModel> jobDummyData = [
  JobModel(
    id: 1,
    badge: "Suit You Best!",
    badgeType: "best",
    title: "AI Engineer",
    company: "OpenAI",
    logo: "assets/images/openai_logo.png",
    location: "Remote",
    jobType: "Full-Time",
    experience: "2+ Years",
    salary: "USD 10,00,000 - USD 15,00,000",
    postedAgo: "4d ago",
  ),
  JobModel(
    id: 2,
    badge: "Still Hiring",
    badgeType: "hiring",
    title: "Software Engineer",
    company: "AWS (Amazon Web Services)",
    logo: "assets/images/aws_logo.png",
    location: "Kathmandu, Bagmati",
    jobType: "Full-Time",
    experience: "Internship",
    salary: "NPR 10,00,000 - NPR 15,00,000",
    postedAgo: "3d ago",
  ),
];

final List<JobModel> trendingJobDummyData = [
  JobModel(
    id: 1,
    badge: "Still Hiring",
    badgeType: "hiring",
    title: "Software Engineer",
    company: "AWS (Amazon Web Services)",
    logo: "assets/images/aws_logo.png",
    location: "Kathmandu, Bagmati",
    jobType: "Full-Time",
    experience: "Internship",
    salary: "NPR 10,00,000 - NPR 15,00,000",
    postedAgo: "3d ago",
  ),
];

final List<JobModel> remoteJobDummyData = [
  JobModel(
    id: 1,
    badge: "Suit You Best!",
    badgeType: "best",
    title: "AI Engineer",
    company: "OpenAI",
    logo: "assets/images/openai_logo.png",
    location: "Remote",
    jobType: "Full-Time",
    experience: "2+ Years",
    salary: "USD 10,00,000 - USD 15,00,000",
    postedAgo: "4d ago",
  ),
];

class JobRecommendationWidget extends StatefulWidget {
  const JobRecommendationWidget({super.key});

  @override
  State<JobRecommendationWidget> createState() =>
      _JobRecommendationWidgetState();
}

class _JobRecommendationWidgetState extends State<JobRecommendationWidget> {
  JobFilter selectedFilter = JobFilter.forYou;

  List<JobModel> get jobs {
    switch (selectedFilter) {
      case JobFilter.forYou:
        return jobDummyData;
      case JobFilter.trending:
        return trendingJobDummyData;
      case JobFilter.newThisWeek:
        return jobDummyData;
      case JobFilter.urgent:
        return jobDummyData;
      case JobFilter.remote:
        return remoteJobDummyData;
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

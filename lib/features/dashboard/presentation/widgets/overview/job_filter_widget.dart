import 'package:flutter/material.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/job_recommendation_widget.dart';

class JobFilterWidget extends StatelessWidget {
  const JobFilterWidget({
    super.key,
    required this.selectedFilter,
    required this.onChanged,
  });

  final JobFilter selectedFilter;
  final ValueChanged<JobFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: JobFilter.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = JobFilter.values[index];
          final bool isSelected = filter == selectedFilter;

          return ChoiceChip(
            label: Text(
              _labelForFilter(filter),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textMedium,
              ),
            ),
            selected: isSelected,
            onSelected: (_) => onChanged(filter),
            showCheckmark: false,
            backgroundColor: Colors.white,
            selectedColor: AppColors.primary,
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.borderStroke,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            padding: EdgeInsets.all(1),
          );
        },
      ),
    );
  }

  String _labelForFilter(JobFilter filter) {
    switch (filter) {
      case JobFilter.forYou:
        return 'For You';
      case JobFilter.trending:
        return 'Trending Jobs';
      case JobFilter.newThisWeek:
        return 'New This Week';
      case JobFilter.urgent:
        return 'Urgent Hiring';
      case JobFilter.remote:
        return 'Remote Opportunities';
    }
  }
}

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
          final selected = filter == selectedFilter;

          return ChoiceChip(
            label: Text(
              _labelForFilter(filter),
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
            side: BorderSide(
              color: selected ? AppColors.primary : const Color(0xFFE0E0E0),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            onSelected: (_) => onChanged(filter),
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

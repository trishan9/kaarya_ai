import 'package:flutter/material.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/summary_card_widget.dart';

class StatusFilterWidget extends StatelessWidget {
  const StatusFilterWidget({
    super.key,
    required this.selectedStatus,
    required this.onChanged,
  });

  final ApplicationStatus selectedStatus;
  final ValueChanged<ApplicationStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ApplicationStatus.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = ApplicationStatus.values[index];
          final bool isSelected = status == selectedStatus;

          return ChoiceChip(
            label: Text(
              _labelForStatus(status),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textMedium,
              ),
            ),
            selected: isSelected,
            onSelected: (_) => onChanged(status),
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

  String _labelForStatus(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.all:
        return 'All Applications';
      case ApplicationStatus.mock:
        return 'Mock Interviews';
      case ApplicationStatus.screening:
        return 'Accepted';
      case ApplicationStatus.interview:
        return 'Rejected';
    }
  }
}

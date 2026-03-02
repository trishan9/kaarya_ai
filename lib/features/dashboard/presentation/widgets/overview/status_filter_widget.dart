import 'package:flutter/material.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/app/theme/theme_utils.dart';
import 'package:kaarya/features/dashboard/presentation/widgets/overview/summary_card_widget.dart';

class StatusFilterWidget extends StatelessWidget {
  const StatusFilterWidget({
    super.key,
    required this.selectedStatus,
    required this.onChanged,
    this.countResolver,
  });

  final ApplicationStatus selectedStatus;
  final ValueChanged<ApplicationStatus> onChanged;
  final int Function(ApplicationStatus status)? countResolver;

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
          final selected = status == selectedStatus;

          return ChoiceChip(
            label: Text(
              _buildLabel(status),
              style: TextStyle(
                fontSize: 13,
                color: selected ? Colors.white : appTextPrimaryColor(context),
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
            backgroundColor: appSurfaceColor(context),
            side: BorderSide(
              color: selected ? AppColors.primary : appBorderColor(context),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            onSelected: (_) => onChanged(status),
          );
        },
      ),
    );
  }

  String _labelForStatus(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.all:
        return 'All Applications';
      case ApplicationStatus.applied:
        return 'Applied';
      case ApplicationStatus.reviewing:
        return 'Reviewing';
      case ApplicationStatus.shortlisted:
        return 'Shortlisted';
      case ApplicationStatus.interview:
        return 'Interview';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.rejected:
        return 'Rejected';
    }
  }

  String _buildLabel(ApplicationStatus status) {
    final count = countResolver?.call(status);
    if (count == null) {
      return _labelForStatus(status);
    }

    return '${_labelForStatus(status)} ($count)';
  }
}

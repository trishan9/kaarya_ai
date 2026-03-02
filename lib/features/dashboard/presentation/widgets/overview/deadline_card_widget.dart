import 'package:flutter/material.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/app/theme/theme_utils.dart';
import 'package:kaarya/core/utils/build_icon.dart';
import 'package:kaarya/features/jobs/domain/entities/job_entity.dart';

class DeadlineCardWidget extends StatelessWidget {
  const DeadlineCardWidget({super.key, required this.job});

  final JobEntity? job;

  @override
  Widget build(BuildContext context) {
    final deadlineJob = job;
    if (deadlineJob == null) {
      return Card(
        color: appSurfaceColor(context),
        elevation: 0,
        margin: const EdgeInsets.all(0),
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
                "Deadline Today!",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 12),
              Card(
                color: appMutedSurfaceColor(context),
                elevation: 0,
                margin: const EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(color: appSubtleBorderColor(context)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 9, 12, 9),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.bgSecondary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "AI",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF5F3D1D),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "No upcoming deadlines",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "Check saved jobs",
                              style: TextStyle(color: AppColors.textMedium),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "One of your saved jobs has a deadline today,",
                style: TextStyle(color: AppColors.textMedium, fontSize: 14),
              ),
              Text(
                "apply now!",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      color: appSurfaceColor(context),
      elevation: 0,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: appBorderColor(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Deadline Today!",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Icon(Icons.more_horiz),
              ],
            ),
            SizedBox(height: 18),
            Card(
              color: appMutedSurfaceColor(context),
              elevation: 0,
              margin: const EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(color: appSubtleBorderColor(context)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 9, 12, 9),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: deadlineJob.companyLogo != null
                              ? Image.network(
                                  deadlineJob.companyLogo!,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _logoFallback(deadlineJob.companyName),
                                )
                              : _logoFallback(deadlineJob.companyName),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              deadlineJob.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              deadlineJob.companyName,
                              style: TextStyle(
                                color: appTextSecondaryColor(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    buildIcon(
                      assetPath: "assets/icons/bookmark.svg",
                      isActive: deadlineJob.isSaved,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: appTextSecondaryColor(context),
                ),
                children: [
                  TextSpan(
                    text:
                        "A saved job has deadline ${_deadlineLabel(deadlineJob.deadline)}. Don't miss out, ",
                  ),
                  TextSpan(
                    text: "apply now!",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoFallback(String companyName) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        companyName.isEmpty ? 'K' : companyName[0].toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }

  String _deadlineLabel(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return "soon";

    final now = DateTime.now();
    if (parsed.year == now.year &&
        parsed.month == now.month &&
        parsed.day == now.day) {
      return "today";
    }

    final month = parsed.month.toString().padLeft(2, '0');
    final day = parsed.day.toString().padLeft(2, '0');
    return "on ${parsed.year}-$month-$day";
  }
}

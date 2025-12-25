import 'package:flutter/material.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/features/dashboard/presentation/view/main_screens/overview/overlapping_avatars_widget.dart';
import 'package:kaarya/features/dashboard/presentation/view/main_screens/overview/status_filter_widget.dart';

enum ApplicationStatus { all, mock, screening, interview }

class SummaryCardWidget extends StatefulWidget {
  const SummaryCardWidget({super.key});

  @override
  State<SummaryCardWidget> createState() => SummaryCardWidgetState();
}

class SummaryCardWidgetState extends State<SummaryCardWidget> {
  ApplicationStatus selectedStatus = ApplicationStatus.all;

  int get applicationsCount {
    switch (selectedStatus) {
      case ApplicationStatus.all:
        return 124;
      case ApplicationStatus.mock:
        return 18;
      case ApplicationStatus.screening:
        return 42;
      case ApplicationStatus.interview:
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
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Applications",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
                ),
                IconButton(onPressed: () {}, icon: Icon(Icons.more_horiz)),
              ],
            ),

            Transform.translate(
              offset: Offset(0, -6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 10,
                children: [
                  Text(
                    "Summary",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: AppColors.borderStroke2,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "DECEMBER, 2025",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 18),

            StatusFilterWidget(
              selectedStatus: selectedStatus,
              onChanged: (status) {
                setState(() {
                  selectedStatus = status;
                });
              },
            ),

            SizedBox(height: 4),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 6,
              children: [
                Text(
                  applicationsCount.toString(),
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.w500),
                ),
                Transform.translate(
                  offset: const Offset(0, -15),
                  child: OverlappingAvatars(
                    avatars: [
                      'assets/images/aws_logo.png',
                      'assets/images/north_face_logo.png',
                      'assets/images/anthropic_logo.png',
                      'assets/images/openai_logo.png',
                    ],
                    extraCount: 9,
                  ),
                ),
              ],
            ),

            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMedium,
                  fontFamily: "GeneralSans",
                ),
                children: [
                  TextSpan(
                    text: "+12",
                    style: TextStyle(color: AppColors.success),
                  ),
                  TextSpan(
                    text:
                        " applications has been sent to the recruiters today, great work, hope the best for you!",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

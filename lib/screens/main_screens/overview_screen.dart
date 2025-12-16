import 'package:flutter/material.dart';
import 'package:kaarya/theme/app_colors.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 20),
      child: Column(
        spacing: 18,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [ApplicationsSummaryWidget(), ApplicationsSummaryWidget()],
      ),
    );
  }
}

class ApplicationsSummaryWidget extends StatelessWidget {
  const ApplicationsSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, bottom: 16, top: 8, right: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Column(
            spacing: -6,
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
              Row(
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
            ],
          ),
          // Tabs: wip
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 10,
            children: [
              Text(
                "124",
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.w500),
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:kaarya/common/build_icon.dart';
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
        children: [ApplicationsSummaryCardWidget(), DeadlineCardWidget()],
      ),
    );
  }
}

class ApplicationsSummaryCardWidget extends StatelessWidget {
  const ApplicationsSummaryCardWidget({super.key});

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

            Row(), // tabs : todo
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 6,
              children: [
                Text(
                  "124",
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

class OverlappingAvatars extends StatelessWidget {
  const OverlappingAvatars({
    super.key,
    required this.avatars,
    this.extraCount = 0,
  });

  final List<String> avatars;
  final int extraCount;

  @override
  Widget build(BuildContext context) {
    const double avatarSize = 28;
    const double overlap = 20;

    final double width = (avatars.length * overlap) + avatarSize;

    return SizedBox(
      height: avatarSize,
      width: width,
      child: Stack(
        children: [
          for (int i = 0; i < avatars.length; i++)
            Positioned(
              left: i * overlap,
              child: CircleAvatar(
                radius: avatarSize / 2,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage(avatars[i]),
              ),
            ),

          Positioned(
            left: avatars.length * overlap,
            child: CircleAvatar(
              radius: avatarSize / 2,
              backgroundColor: AppColors.bgSecondary,
              child: Text(
                '+$extraCount',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DeadlineCardWidget extends StatelessWidget {
  const DeadlineCardWidget({super.key});

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
              color: AppColors.bgTertiary,
              elevation: 0,
              margin: const EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
                side: BorderSide(color: AppColors.borderStroke2),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 9, 12, 9),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      spacing: 12,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(
                            "assets/images/anthropic_logo.png",
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Marketing Manager",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              "Anthropic AI",
                              style: TextStyle(
                                color: AppColors.textMedium,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    buildIcon(
                      assetPath: "assets/icons/bookmark.svg",
                      isActive: true,
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
                  color: AppColors.textMedium,
                  fontFamily: "GeneralSans",
                ),
                children: [
                  TextSpan(
                    text:
                        "One of your saved jobs has a deadline today, don’t miss out, ",
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
}

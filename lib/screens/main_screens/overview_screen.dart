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
          Row(),
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
                    'assets/images/github_logo.png',
                    'assets/images/google_logo.png',
                    'assets/images/github_logo.png',
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
    const double overlap = 18;

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

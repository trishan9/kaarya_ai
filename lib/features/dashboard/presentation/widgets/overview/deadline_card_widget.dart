import 'package:flutter/material.dart';
import 'package:kaarya/app/theme/app_colors.dart';
import 'package:kaarya/core/utils/build_icon.dart';

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

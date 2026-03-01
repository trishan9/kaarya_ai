import 'package:flutter/material.dart';
import 'package:kaarya/app/theme/app_colors.dart';

class HeadingWithSubheadingWidget extends StatelessWidget {
  const HeadingWithSubheadingWidget({
    super.key,
    required this.heading,
    required this.subheading,
  });

  final String heading;
  final String subheading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30),
      child: Column(
        children: [
          Text(
            heading,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subheading,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 16,
              color: AppColors.textLight,
              height: 1.55,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

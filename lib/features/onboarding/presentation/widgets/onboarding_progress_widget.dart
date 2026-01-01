import 'package:flutter/material.dart';
import 'package:kaarya/app/theme/app_colors.dart';

class OnboardingProgress extends StatelessWidget {
  final int index;
  const OnboardingProgress({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(4, (i) {
          final bool isActive = i == index;

          if (isActive) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),

              child: Container(
                key: ValueKey("bar_$i"),
                height: 8,
                width: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            );
          }

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              color: Color(0xFFD1E4F2),
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}
